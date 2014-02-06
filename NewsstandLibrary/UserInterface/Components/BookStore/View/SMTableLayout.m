//
//  SMTableLayout.m
//  Newsstand
//
//  Created by Suleyman Melikoglu on 30/01/14.
//  Copyright (c) 2014 ZulaMobile. All rights reserved.
//

#import "SMTableLayout.h"

@implementation SMTableLayout

- (id)init
{
    self = [super init];
    if (self) {
        CGRect bounds = [[UIScreen mainScreen] bounds];
        self.itemSize = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ?
        CGSizeMake(CGRectGetWidth(bounds), 44.0f) : CGSizeMake(CGRectGetWidth(bounds), 44.0f);
        self.minimumInteritemSpacing = 0.0f; // horizontal space between each item (column) in a row, default: 32.0f;
        self.minimumLineSpacing = 2.0f; // vertical space between each row, default: 32.0f
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        //self.headerReferenceSize = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? (CGSize){50, 50} : (CGSize){43, 43}; // 100
        self.headerReferenceSize = (CGSize){0, 0};
        //self.footerReferenceSize = (CGSize){44, 44}; // 88
        self.footerReferenceSize = (CGSize){0, 0};
        
        //[self registerClass:[SMShelfDecoratorView class] forDecorationViewOfKind:[SMShelfDecoratorView kind]];
        //[self registerClass:[SMLogoDecorationView class] forDecorationViewOfKind:[SMLogoDecorationView kind]];
    }
    return self;
}

@end
