//
//  SMDownloadProgressView.m
//  NewsstandLibrary
//
//  Created by Suleyman Melikoglu on 08/02/14.
//  Copyright (c) 2014 ZulaMobile. All rights reserved.
//

#import "SMDownloadProgressView.h"
#import <LLACircularProgressView/LLACircularProgressView.h>

@interface SMDownloadProgressView ()
@property (nonatomic, strong) LLACircularProgressView *progressView;
@end


@implementation SMDownloadProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.progressView = [[LLACircularProgressView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        self.progressView.backgroundColor = [UIColor clearColor];
        
        // we don't want any user actions on this view.
        // actions are handled via collection views didSelect method.
        self.userInteractionEnabled = NO;
        
        [self addSubview:self.progressView];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    [self.progressView setProgress:progress animated:YES];
}

- (CGFloat)progress
{
    return self.progressView.progress;
}

- (void)setColor:(UIColor *)color
{
    [self.progressView setProgressTintColor:color];
}

- (UIColor *)color
{
    return self.progressView.tintColor;
}

@end
