//
//  SMBookStore.m
//  Newsstand
//
//  Created by Suleyman Melikoglu on 07/11/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import "SMBookStore.h"
#import "SMIssue.h"


@implementation SMBookStore
@synthesize title, navbarIcon, issues, backgroundImageUrl, imageUrl;

- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self) {
        title = [attributes objectForKey:@"title"];
        imageUrl = [attributes objectForKey:@"image"];
        navbarIcon = [attributes objectForKey:@"navbar_icon"];
        backgroundImageUrl = [attributes objectForKey:@"bg_image"];
        NSArray *rawIssues = [attributes objectForKey:@"issues"];
        if (![rawIssues isKindOfClass:[NSArray class]]) {
            NSLog(@"must have set dictionaries for issues!");
            exit(0);
        }
        
        NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:[rawIssues count]];
        for (NSDictionary *rawIssue in rawIssues) {
            SMIssue *issue = [[SMIssue alloc] initWithAttributes:rawIssue];
            [tmp addObject:issue];
        }
        issues = [NSArray arrayWithArray:tmp];
    }
    return self;
}

+ (void)fetchWithURLString:(NSString *)urlString
                completion:(void(^)(SMBookStore *contentPage, SMServerError *error))completion
{
    
}

@end
