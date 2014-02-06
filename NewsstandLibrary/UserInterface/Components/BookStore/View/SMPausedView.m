//
//  SMPausedView.m
//  Newsstand
//
//  Created by Suleyman Melikoglu on 23/11/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import "SMPausedView.h"
#import <QuartzCore/QuartzCore.h>


@implementation SMPausedView
@synthesize color;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if ([self color] == nil)
        [self setColor:[UIColor blackColor]];
    
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
    
    // get the initial context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // save the current state
    CGContextSaveGState(context);
    
    //const CGFloat* components = CGColorGetComponents(self.color.CGColor);
    //CGContextSetRGBFillColor(context, components[0], components[1], components[2], CGColorGetAlpha(self.color.CGColor));
    
    // draw 2 vertical rectangles
    float gap = 5.0f;
    CGSize size = (CGSize){ rect.size.width / 2 - gap / 2, rect.size.height };
    CGContextAddRect(context, CGRectMake(center.x - size.width - gap / 2, 0.0f, size.width, size.height));
    CGContextAddRect(context, CGRectMake(center.x + gap / 2, 0.0f, size.width, size.height));
    
    [[self color] setFill];
    
    // do the actual drawing
    CGContextFillPath(context);
    
    // restore the state back after drawing on it.
    CGContextRestoreGState(context);
}

@end
