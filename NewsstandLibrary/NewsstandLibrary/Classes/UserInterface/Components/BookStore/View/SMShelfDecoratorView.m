//
//  SMShelfDecoratorView.m
//  Newsstand
//
//  Created by Suleyman Melikoglu on 08/11/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import "SMShelfDecoratorView.h"

@implementation SMShelfDecoratorView
{
    UIImageView *backgroundImageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NewsletterDefault.bundle/book-shelf/shelf-background"]];
        //backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shelf-background"]];
        //backgroundImageView.frame = CGRectMake(padding, 0.0f, CGRectGetWidth(frame) - padding * 2.0f, CGRectGetHeight(frame));
        backgroundImageView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
        //backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        /*
        backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin     |
        UIViewAutoresizingFlexibleHeight          |
        UIViewAutoresizingFlexibleLeftMargin      |
        UIViewAutoresizingFlexibleRightMargin     |
        UIViewAutoresizingFlexibleTopMargin       |
        UIViewAutoresizingFlexibleWidth;
         */
        [self addSubview:backgroundImageView];
    }
    return self;
}

+ (NSString *)kind
{
    return @"SMShelfView";
}

@end
