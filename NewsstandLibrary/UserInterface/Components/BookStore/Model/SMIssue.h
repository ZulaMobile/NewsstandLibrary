//
//  SMIssue.h
//  Newsstand
//
//  Created by Suleyman Melikoglu on 07/11/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import <ZulaLibrary/SMModel.h>

typedef NS_ENUM(NSInteger, SMIssueType) {
    SMIssueTypeUnknown,
    SMIssueTypePdf,
    SMIssueTypeHtml
};

typedef NS_ENUM(NSInteger, SMIssueState) {
    SMIssueDefault, // not downloaded
    SMIssueAvailable, // downloaded
    SMIssueIsDownloading,
    SMIssuePaused,
    SMIssueMarked
};

typedef void (^IssueDownloadCompletionBlock) (BOOL success);
typedef void (^IssueDownloadProgressBlock) (float percentage);

@interface SMIssue : SMModel

/**
 *  Title of the issue. Title may be visible in ui
 */
@property (nonatomic, readonly) NSString *title;

/**
 *  The unique identifier of the issue
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 *  The cover url of the issue. If not set, the default 
 *  url will be used
 */
@property (nonatomic, readonly) NSURL *coverUrl;

/**
 *  The download url is the pdf url if the issue if a PDF.
 *  It is the HTML page url if the issue is a HTML Page
 */
@property (nonatomic, readonly) NSURL *downloadUrl;

/**
 *  The issue type is automatically determined from download url.
 */
@property (nonatomic, readonly) SMIssueType type;

/**
 *
 */
@property (nonatomic) SMIssueState state;

/**
 *  The percentage of the download. If not 0.0f, it indicated that the state of the
 *  issue is in `downloading` and the value of download is determined by this property.
 *  it is between 0.0f and 0.1f.
 */
@property (nonatomic) float downloadPercentage;

@property (nonatomic, copy) IssueDownloadCompletionBlock downloadCompletionBlock;
@property (nonatomic, copy) IssueDownloadProgressBlock downloadProgressBlock;

/**
 *  The local file path
 *
 *  @return NSString local path
 */
- (NSString *)localFilePath;

/**
 * Checks if download url is valid
 */
- (BOOL)isDownloadUrlValid;

/**
 * Checks if the issue is downloaded before and readable from the disk
 *
 * @return NO if it hasn't been downloaded before
 */
- (BOOL)isAvailableToRead;

/**
 * Reads the file from disk
 */
- (void)read;

/**
 *  reset the state to available if it is a downloaded issue,
 *  or default state.
 */
- (void)resetState;

/**
 * downloads the pdf
 */
- (void)download;

- (void)pauseDownload;

- (void)resumeDownload;

/**
 * cancels download operation
 */
- (void)cancelDownload;

/**
 *  Sets the cover image as the newsstand icon for the app
 */
- (void)setNewsstandIconFromCoverImage;

/**
 *  Removes the file locally, if exists
 *  Returns YES if the file is deleted.
 *  Returns NO if operation fails or there is no file
 *
 *  @return 
 */
- (BOOL)removeFromFilesystem;

@end
