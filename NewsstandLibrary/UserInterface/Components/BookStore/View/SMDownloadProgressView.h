//
//  SMDownloadProgressView.h
//  NewsstandLibrary
//
//  Created by Suleyman Melikoglu on 08/02/14.
//  Copyright (c) 2014 ZulaMobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SMDownloadProgressView : UIView

@property (nonatomic) CGFloat progress;
@property (strong, nonatomic) UIColor *color UI_APPEARANCE_SELECTOR;

@end
