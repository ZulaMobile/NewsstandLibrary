//
//  SMIssue.m
//  Newsstand
//
//  Created by Suleyman Melikoglu on 07/11/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import "SMIssue.h"

#define kDownloadedIssuesList @"kDownloadedIssues"
#define kDownloadingIssuesList @"kDownloadingIssues"
#define kPausedIssuesList @"kPausedIssues"

@interface SMIssuePersistanceManager : NSObject

@property (nonatomic, strong) SMIssue *issue;
@property (nonatomic, strong) NSString *dbName;

- (id)initWithIssue:(SMIssue *)issue databaseName:(NSString *)databaseName;
- (NSDictionary *)issuesFromUserDatabase;
- (void)markIssue;
- (BOOL)isMarked;
- (void)unmarkIssue;

@end

@implementation SMIssuePersistanceManager
@synthesize issue, dbName;

- (id)initWithIssue:(SMIssue *)anIssue databaseName:(NSString *)databaseName
{
    self = [super init];
    if (self) {
        self.issue = anIssue;
        self.dbName = databaseName;
    }
    return self;
}

- (NSDictionary *)issuesFromUserDatabase
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *arr = [defaults objectForKey:self.dbName];
    if (!arr) {
        arr = [[NSDictionary alloc] init];
    }
    return arr;
}

- (void)markIssue
{
    // add the issue to the user database
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self issuesFromUserDatabase]];
    if (![self isMarked]) {
        [dict setObject:[issue localFilePath] forKey:issue.identifier];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSDictionary dictionaryWithDictionary:dict] forKey:self.dbName];
        [defaults synchronize];
    }
}

- (BOOL)isMarked
{
    // check if the issue is in user database
    NSDictionary *dict = [self issuesFromUserDatabase];
    id hasObj = [dict objectForKey:issue.identifier];
    return hasObj != nil;
}

- (void)unmarkIssue
{
    // remove the issue from the user database
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self issuesFromUserDatabase]];
    if ([self isMarked]) {
        [dict removeObjectForKey:issue.identifier];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSDictionary dictionaryWithDictionary:dict] forKey:self.dbName];
        [defaults synchronize];
    }
}

@end


@interface SMIssue ()

@property (nonatomic, strong) SMIssuePersistanceManager *downloadedManager;
@property (nonatomic, strong) SMIssuePersistanceManager *downloadingManager;
@property (nonatomic, strong) SMIssuePersistanceManager *pausedManager;

@property (nonatomic, strong) SMDownloadSession *downloadSession;

- (void)addToDownloadingList;
- (void)removeFromDownloadingList;
- (NSDictionary *)downloadedIssuesFromUserDatabase;

- (void)markIssueAsDownloaded;

/**
 *  Determines if the download finished successfully
 */
- (BOOL)isDownloadedSuccessfully;

/**
 *  If user chose to delete the issue, unmark it from the downloaded issues
 *  so we can download it again.
 */
- (void)unmarkIssueAsDownloaded;

@end

@implementation SMIssue
@synthesize title=_title, identifier=_identifier, coverUrl=_coverUrl, downloadUrl=_downloadUrl, type=_type;

- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self) {
        _identifier = [NSString stringWithFormat:@"%@", [attributes objectForKey:@"identifier"]];
        _title = [NSString stringWithFormat:@"%@", [attributes objectForKey:@"title"]];
        _coverUrl = [NSURL URLWithString:[attributes objectForKey:@"cover_url"]];
        _downloadUrl = [NSURL URLWithString:[attributes objectForKey:@"download_url"]];
        
        // guess the type of the document
        if (!_downloadUrl) {
            _type = SMIssueTypeUnknown;
        } else if ([[_downloadUrl pathExtension] isEqualToString:@"pdf"]) {
            _type = SMIssueTypePdf;
        } else {
            _type = SMIssueTypeHtml;
        }
        
        self.downloadedManager = [[SMIssuePersistanceManager alloc] initWithIssue:self databaseName:kDownloadedIssuesList];
        self.downloadingManager = [[SMIssuePersistanceManager alloc] initWithIssue:self databaseName:kDownloadingIssuesList];
        self.pausedManager = [[SMIssuePersistanceManager alloc] initWithIssue:self databaseName:kPausedIssuesList];
        
        self.downloadPercentage = 0.0f;
        
        [self resetState];
    }
    return self;
}

- (void)dealloc
{
    if ([self isDownloading]) {
        [self pauseDownload];
    }
}

- (void)resetState
{
    if ([self isAvailableToRead]) {
        self.state = SMIssueAvailable;
    } else if (self.downloadPercentage > 0.0f) {
        self.state = SMIssueIsDownloading;
    } else {
        self.state = SMIssueDefault;
    }
}

- (NSString *)documentsDirectory {
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    return [paths objectAtIndex:0];
}

- (NSString *)filename
{
    return [self.downloadUrl lastPathComponent];
}

- (NSString *)localFilePath
{
    NSString *filename = [self filename];
    
    NSString *directory = [self documentsDirectory];
    NSString *destPath = [directory stringByAppendingPathComponent:filename];
    return destPath;
}

- (UIImage *)coverImage
{
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.coverUrl]];
    return image;
}

- (void)setNewsstandIconFromCoverImage
{
    UIImage *img = [self coverImage];
    if(img) {
        [[UIApplication sharedApplication] setNewsstandIconImage:img];
        //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    }
}

// tries to read the file from the disk
- (BOOL)isAvailableToRead
{
    if ([self type] == SMIssueTypeHtml) {
        return YES;
    }
    
    if (![self isDownloadUrlValid]) {
        return NO;
    }
    
    if ([self isDownloading] || [self isPaused]) {
        return NO;
    }
    
    // check if the file exists
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self localFilePath]];

    if (!exists) {
        [self unmarkIssueAsDownloaded];
        return NO;
    }
    
    //NSLog(@"file exists at %@", [[self localFilePath] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "]);
    
    return YES;
    //return [self isDownloadedSuccessfully];
}

- (BOOL)isDownloadUrlValid
{
    return _downloadUrl != nil;
}

- (void)read
{
    
}

- (BOOL)isDownloading
{
    // check the user defaults db, if the issue is downloading
    return [self.downloadingManager isMarked];
}

- (void)pauseDownload
{
    [self removeFromDownloadingList];
    [self.pausedManager markIssue];
    [self.downloadSession pause];
    self.state = SMIssuePaused;
    self.downloadPercentage = 0.0f;
}

- (BOOL)isPaused
{
    return [self.pausedManager isMarked];
}

- (void)resumeDownload
{
    self.state = SMIssueIsDownloading;
    [self.pausedManager unmarkIssue];
    [self addToDownloadingList];
    
    if ([self.downloadSession canResume]) {
        [self.downloadSession resume];
    } else {
        [self download];
    }
}

- (void)cancelDownload
{
    [self.downloadSession cancel];
    [self removeFromDownloadingList];
    [self.pausedManager unmarkIssue];
}

- (void)download
{
    if (![self isDownloadUrlValid]) {
        if (self.downloadCompletionBlock) {
            self.downloadCompletionBlock(NO);
        }
        return;
    }
    
    self.state = SMIssueIsDownloading;
    
    SMApiClient *client = [SMApiClient sharedClient];
    __block id weakSelf = self;
    self.downloadSession = [client downloadToPath:[self localFilePath]
                                          getPath:[self.downloadUrl absoluteString]
                                       parameters:nil
                                          success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        SMIssue *strongSelf = weakSelf;
        
        // download finished notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationIssueDownloadDidFinish object:self];
        
        [strongSelf removeFromDownloadingList];
        [strongSelf markIssueAsDownloaded];
        
        strongSelf.state = SMIssueAvailable;
        
        if (self.downloadCompletionBlock) {
            self.downloadCompletionBlock(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        SMIssue *strongSelf = weakSelf;
        
        // download finished notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationIssueDownloadDidFinish object:self];
        
        [strongSelf removeFromDownloadingList];
        
        strongSelf.state = SMIssueDefault;
        
        if (self.downloadCompletionBlock) {
            self.downloadCompletionBlock(NO);
        }
    } progress:^(float percentage) {
        
        self.downloadPercentage = percentage;
        
        // progress
        if (self.downloadProgressBlock) {
            self.downloadProgressBlock(percentage);
        }
    }];
    
    [self addToDownloadingList];
    
    // download start notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationIssueDownloadDidStart object:self];
    
}

- (BOOL)removeFromFilesystem
{
    if ([self.downloadedManager isMarked]) {
        [self cancelDownload];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:[self localFilePath] isDirectory:NO])
        return NO;
    
    NSError *err;
    if([fileManager removeItemAtPath:[self localFilePath] error:&err]) {
        [self removeFromDownloadingList];
        [self.pausedManager unmarkIssue];
        self.state = SMIssueDefault;
        return YES;
    }
    
    // remove is not successful
    NSLog(@"remove issue failed: %@", err);
    return NO;
}

#pragma mark - private methods

- (NSDictionary *)downloadedIssuesFromUserDatabase
{
    return [self.downloadedManager issuesFromUserDatabase];
}

- (void)markIssueAsDownloaded
{
    self.state = SMIssueAvailable;
    [self.downloadedManager markIssue];
}

/**
 *  Determines if the download finished successfully
 */
- (BOOL)isDownloadedSuccessfully
{
    return [self.downloadedManager isMarked];
}

/**
 *  If user chose to delete the issue, unmark it from the downloaded issues
 *  so we can download it again.
 */
- (void)unmarkIssueAsDownloaded
{
    [self.downloadedManager unmarkIssue];
}

- (void)addToDownloadingList
{
    [self.downloadingManager markIssue];
}

- (void)removeFromDownloadingList
{
    [self.downloadingManager unmarkIssue];
}

@end


