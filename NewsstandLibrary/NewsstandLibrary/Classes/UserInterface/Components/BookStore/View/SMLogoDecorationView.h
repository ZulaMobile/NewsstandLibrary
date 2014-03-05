//
//  SMLogoCell.h
//  Newsstand
//
//  Created by Suleyman Melikoglu on 13/11/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMLogoDecorationView : UICollectionReusableView

@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, strong) UILabel *text;

+ (NSString *)kind;

/**
 *  Returns the logo image size
 *
 *  @return CGSize
 */
+ (CGSize)logoSize;

@end
