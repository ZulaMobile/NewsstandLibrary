//
//  SMShelfLayoutAttributes.h
//  Newsstand
//
//  Created by Suleyman Melikoglu on 04/12/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Custom layout attributes for the shelf item
 */
@interface SMShelfLayoutAttributes : UICollectionViewLayoutAttributes

/**
 *  Changes the behavior of the shelf item.
 *  In edit mode, the tap on the item will mark the cell
 */
@property (nonatomic, getter = isInEditMode) BOOL inEditMode;

/**
 *  Displays/Hides the mark button. Only available in marking mode
 */
@property (nonatomic, getter = isMarkButtonHidden) BOOL markButtonHidden;

@end
