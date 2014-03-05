//
//  SMBookStore.h
//  Newsstand
//
//  Created by Suleyman Melikoglu on 07/11/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import <ZulaLibrary/SMModel.h>

/**
 *  A model that represents a Book Store Component
 *  A book store is a page that displays a list of issues
 */
@interface SMBookStore : SMModel

/**
 The header title value of the content.
 */
@property (nonatomic, readonly) NSString *title;

/**
 *  A list of SMIssue objects
 */
@property (nonatomic, strong) NSArray *issues;

/**
 *  An optional image to show on top of the page
 */
@property (nonatomic) NSURL *imageUrl;

/**
 Optional background image
 */
@property (nonatomic) NSURL *backgroundImageUrl;

/**
 Optional navigation bar image that replaces the title
 */
@property (nonatomic) NSURL *navbarIcon;

/**
 *  Fetches the component data
 *
 *  @param urlString  the component rest api endpoint
 *  @param completion result of the api request
 */
+ (void)fetchWithURLString:(NSString *)urlString
                completion:(void(^)(SMBookStore *contentPage, SMServerError *error))completion;

@end
