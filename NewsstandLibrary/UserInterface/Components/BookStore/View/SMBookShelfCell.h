//
//  SMBookShelfCell.h
//  Newsstand
//
//  Created by Suleyman Melikoglu on 08/11/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMIssue.h"


@class SMDownloadProgressView;

/**
 *  A collection view cell that looks like a book cover
 */
@interface SMBookShelfCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *coverImage;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) SMDownloadProgressView *progressView;
@property (nonatomic, strong) UIImageView *markView;

@property (nonatomic, copy) IssueDownloadCompletionBlock downloadCompletionBlock;
@property (nonatomic, copy) IssueDownloadProgressBlock downloadProgressBlock;

- (void)changeState:(SMIssueState)state;

/**
 *  Updates the preloader's progress bar. 
 *  Displays it if it is hidden
 *
 *  @param percentage
 */
- (void)displayPreloaderWithPercentage:(float)percentage;

@end
