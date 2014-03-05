//
//  SMBookShelfLayout.h
//  Newsstand
//
//  Created by Suleyman Melikoglu on 09/11/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMBookShelfLayoutDelegate;

@interface SMBookShelfLayout : UICollectionViewFlowLayout

@end

@protocol SMBookShelfLayoutDelegate <UICollectionViewDelegateFlowLayout>

- (BOOL)isEditModeActiveForCollectionView:(UICollectionView *)collectionView layout:(SMBookShelfLayout *)layout;

@end
