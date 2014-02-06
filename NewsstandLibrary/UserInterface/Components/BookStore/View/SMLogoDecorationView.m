//
//  SMLogoCell.m
//  Newsstand
//
//  Created by Suleyman Melikoglu on 13/11/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import "SMLogoDecorationView.h"

@interface SMLogoDecorationView ()
- (void)onPullToRefreshDidStartNotification:(NSNotification *)notification;
- (void)onPullToRefreshDidStopNotification:(NSNotification *)notification;
@end

@implementation SMLogoDecorationView
@synthesize logo;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGSize logoSize = [SMLogoDecorationView logoSize];
        self.logo = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) / 2 - logoSize.width / 2,
                                                                  0.0f, logoSize.width, logoSize.height)];
        self.logo.backgroundColor = [UIColor clearColor];
        self.logo.image = [UIImage imageNamed:@"zularesources.bundle/icon_alternate-50"];
        self.logo.alpha = 0.5f;
        
        [self addSubview:self.logo];
        
        // register notifications for display/hide the logo
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onPullToRefreshDidStartNotification:)
                                                     name:kZulaNotificationPullToRefreshDidStartRefreshing
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onPullToRefreshDidStopNotification:)
                                                     name:kZulaNotificationPullToRefreshDidStopRefreshing
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSString *)kind
{
    return @"SMLogoDecorationView";
}

+ (CGSize)logoSize
{
    return (CGSize){25.0f, 25.0f};
}

#pragma mark - private methods

- (void)onPullToRefreshDidStartNotification:(NSNotification *)notification
{
    //[self setHidden:YES];
}

- (void)onPullToRefreshDidStopNotification:(NSNotification *)notification
{
    //[self setHidden:NO];
}

@end
