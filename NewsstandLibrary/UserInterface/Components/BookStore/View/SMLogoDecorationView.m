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
        self.logo = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - 68.0f,
                                                                  0.0f, 68.0f, logoSize.height)];
        self.logo.backgroundColor = [UIColor clearColor];
        self.logo.image = [UIImage imageNamed:@"zularesources.bundle/signature"];
        self.logo.alpha = 0.5f;
        
        self.text = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - CGRectGetWidth(self.logo.frame) - 46.0f,
                                                             2.0f, 46.0f, logoSize.height)];
        self.text.backgroundColor = [UIColor clearColor];
        self.text.font = [UIFont systemFontOfSize:8.0f];
        self.text.textColor = [UIColor grayColor];
        self.text.text = @"Powered by";
        
        [self addSubview:self.logo];
        [self addSubview:self.text];
        
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
    return (CGSize){108.0f, 12.0f};
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
