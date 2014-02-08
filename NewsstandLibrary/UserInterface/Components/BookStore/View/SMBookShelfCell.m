//
//  SMBookShelfCell.m
//  Newsstand
//
//  Created by Suleyman Melikoglu on 08/11/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import "SMBookShelfCell.h"
#import "SMDownloadProgressView.h"
#import "SMPausedView.h"
#import <QuartzCore/QuartzCore.h>
#import "SMShelfLayoutAttributes.h"


#define MARGIN 2


@interface SMBookShelfCell ()

/**
 *  The mask view that will stay on top of the cover image
 *  to give disabled look on the book
 */
@property (nonatomic, strong) UIView *mask;

/**
 *  The pause view which has 2 white rectengles
 */
@property (nonatomic, strong) SMPausedView *pauseView;

@end

@implementation SMBookShelfCell
@synthesize label, coverImage, mask, progressView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIColor *preloaderColor = [UIColor whiteColor];
        
        float labelHeight = 7.0f;
        
        // label
        self.label = [[UILabel alloc] initWithFrame:
                      CGRectMake(0.0f, CGRectGetHeight(self.bounds) - labelHeight + 5.0f, CGRectGetWidth(self.bounds), labelHeight)];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = [UIFont fontWithName:@"Helvetica-Light" size:8.0f];
        self.label.textColor = [UIColor grayColor];
        self.label.shadowColor = [UIColor whiteColor];
        self.label.shadowOffset = (CGSize){0.0f, 1.0f};
        self.label.backgroundColor = [UIColor clearColor];
        
        // cover image
        self.coverImage = [[UIImageView alloc] initWithFrame:
                           CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        self.coverImage.contentMode = UIViewContentModeScaleAspectFill;
        self.coverImage.clipsToBounds = YES;
        self.coverImage.backgroundColor = [UIColor clearColor];
        
        // mask
        self.mask = [[UIView alloc] initWithFrame:self.coverImage.frame];
        [self.mask setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.7]];
        
        // preloader
        CGSize progressViewSize = (CGSize){ 40.0f, 40.0f };
        self.progressView = [[SMDownloadProgressView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2 - progressViewSize.width / 2,
                                                                                     CGRectGetHeight(self.frame) / 2 - progressViewSize.height / 2,
                                                                                     progressViewSize.width, progressViewSize.height)];
        [self.progressView setColor:preloaderColor];
        [self.progressView setTag:54];
        
        // pause view
        CGSize pauseViewSize = (CGSize){ 20.0f, 20.0f };
        self.pauseView = [[SMPausedView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2 - pauseViewSize.width / 2,
                                                                            CGRectGetHeight(self.frame) / 2 - pauseViewSize.height / 2,
                                                                             pauseViewSize.width, pauseViewSize.height)];
        [self.pauseView setColor:preloaderColor];
        [self.pauseView setTag:55];
        
        //self.markView = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/16, frame.size.width/16, frame.size.width/4, frame.size.width/4)];
        self.markView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NewsletterDefault.bundle/book-shelf/todo"]];
        CGSize markViewSize = (CGSize){18.0f, 19.0f};
        self.markView.frame = CGRectMake(CGRectGetWidth(frame) - markViewSize.width - 10.0f,
                                         CGRectGetHeight(frame) - markViewSize.height - 10.0f,
                                         markViewSize.width,
                                         markViewSize.height);
        self.markView.hidden = YES;
        
        // put them in the view
        //[self.contentView addSubview:self.label];
        [self.contentView addSubview:self.coverImage];
        [self.contentView addSubview:self.mask];
        [self.contentView addSubview:self.progressView];
        [self.contentView addSubview:self.pauseView];
        [self.contentView addSubview:self.markView];
        
        __block id weakSelf = self;
        self.downloadCompletionBlock = ^(BOOL success) {
            SMBookShelfCell *strongSelf = weakSelf;
            [strongSelf changeState:SMIssueAvailable];
        };
        
        self.downloadProgressBlock = ^(float progress) {
            SMBookShelfCell *strongSelf = weakSelf;
            [strongSelf displayPreloaderWithPercentage:progress];
        };
    }
    return self;
}

- (void)changeState:(SMIssueState)state
{
    // defaults
    [self.mask setHidden:YES];
    [self.progressView setHidden:YES];
    [self.pauseView setHidden:YES];
    [self.markView setHidden:YES];
    
    if (state == SMIssueDefault) {
        [self.mask setHidden:NO];
        [self.mask setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.7]];
    } else if (state == SMIssueAvailable) {
        
    } else if (state == SMIssueIsDownloading) {
        [self.mask setHidden:NO];
        [self.mask setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.5]];
        [self.progressView setHidden:NO];
    } else if (state == SMIssueMarked) {
        [self.mask setHidden:NO];
        [self.markView setHidden:NO];
        [self.mask setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.7]];
    } else if (state == SMIssuePaused) {
        [self.pauseView setHidden:NO];
        [self.mask setHidden:NO];
        [self.mask setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.5]];
    }
}

- (void)displayPreloaderWithPercentage:(float)percentage
{
    [self.progressView setProgress:percentage];
}

- (void)applyLayoutAttributes:(SMShelfLayoutAttributes *)layoutAttributes
{
    if (layoutAttributes.isInEditMode) {
        [self changeState:SMIssueDefault];
    }
}

@end
