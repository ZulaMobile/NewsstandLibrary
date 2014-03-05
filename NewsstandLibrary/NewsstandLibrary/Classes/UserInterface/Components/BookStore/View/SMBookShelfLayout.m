//
//  SMBookShelfLayout.m
//  Newsstand
//
//  Created by Suleyman Melikoglu on 09/11/13.
//  Most parts are developed by Mark Pospesel
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "SMBookShelfLayout.h"
#import "SMShelfDecoratorView.h"
#import "SMLogoDecorationView.h"
#import "SMShelfLayoutAttributes.h"

@interface SMBookShelfLayout ()

/**
 *  A dictionary which holds the CGRects for shelf objects
 */
@property (nonatomic, strong) NSDictionary *shelfRects;

/**
 *  A value object which holds the CGRect for the logo (will be displayed on top)
 */
@property (nonatomic, strong) NSValue *logoRect;

- (BOOL)isEditModeOn;

@end

@implementation SMBookShelfLayout

- (id)init
{
    self = [super init];
    if (self) {
        
        self.itemSize = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ?
        CGSizeMake(124, 204) : CGSizeMake(62, 102);
        self.minimumInteritemSpacing = 32.0f; // horizontal space between each item (column) in a row, default: 32.0f;
        self.minimumLineSpacing = 32.0f; // vertical space between each row, default: 32.0f
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.sectionInset = UIEdgeInsetsMake(32.0f, 32.0f, 32.0f, 32.0f);
        //self.headerReferenceSize = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? (CGSize){50, 50} : (CGSize){43, 43}; // 100
        self.headerReferenceSize = (CGSize){0, 0};
        //self.footerReferenceSize = (CGSize){44, 44}; // 88
        self.footerReferenceSize = (CGSize){0, 0};
        
        [self registerClass:[SMShelfDecoratorView class] forDecorationViewOfKind:[SMShelfDecoratorView kind]];
        [self registerClass:[SMLogoDecorationView class] forDecorationViewOfKind:[SMLogoDecorationView kind]];
    }
    return self;
}

+ (Class)layoutAttributesClass
{
    return [SMShelfLayoutAttributes class];
}

// Do all the calculations for determining where shelves go here
- (void)prepareLayout
{
    // call super so flow layout can do all the math for cells, headers, and footers
    [super prepareLayout];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical)
    {
        // Calculate where shelves go in a vertical layout
        int sectionCount = [self.collectionView numberOfSections];
        
        CGFloat y = 0;
        CGFloat availableWidth = self.collectionViewContentSize.width - (self.sectionInset.left + self.sectionInset.right);
        int itemsAcross = floorf((availableWidth + self.minimumInteritemSpacing) / (self.itemSize.width + self.minimumInteritemSpacing));
        
        // calculate shelf rects
        for (int section = 0; section < sectionCount; section++)
        {
            y += self.headerReferenceSize.height;
            y += self.sectionInset.top;
            
            int itemCount = [self.collectionView numberOfItemsInSection:section];
            int rows = ceilf(itemCount/(float)itemsAcross);
            for (int row = 0; row < rows; row++)
            {
                y += self.itemSize.height;
                dictionary[[NSIndexPath indexPathForItem:row inSection:section]] =
                [NSValue valueWithCGRect:CGRectMake(0, y, self.collectionViewContentSize.width, self.itemSize.height + self.minimumLineSpacing)];
                
                if (row < rows - 1)
                    y += self.minimumLineSpacing;
            }
            
            y += self.sectionInset.bottom;
            y += self.footerReferenceSize.height;
        }
        
        // calculate logo rect
        CGSize logoSize = [SMLogoDecorationView logoSize];
        //float logoPaddingTop = (isPad()) ? 120.0f : 70.0f;
        self.logoRect = [NSValue valueWithCGRect:CGRectMake(-6.0f,
                                                            self.collectionViewContentSize.height - logoSize.height - 6.0f,
                                                            self.collectionViewContentSize.width,
                                                            logoSize.height)];
        
    }
    else
    {
        // Calculate where shelves go in a horizontal layout
        CGFloat y = self.sectionInset.top;
        CGFloat availableHeight = self.collectionViewContentSize.height - (self.sectionInset.top + self.sectionInset.bottom);
        int itemsAcross = floorf((availableHeight + self.minimumInteritemSpacing) / (self.itemSize.height + self.minimumInteritemSpacing));
        CGFloat interval = ((availableHeight - self.itemSize.height) / (itemsAcross <= 1? 1 : itemsAcross - 1)) - self.itemSize.height;
        for (int row = 0; row < itemsAcross; row++)
        {
            y += self.itemSize.height;
            dictionary[[NSIndexPath indexPathForItem:row inSection:0]] = [NSValue valueWithCGRect:CGRectMake(0, roundf(y - 32), self.collectionViewContentSize.width, 42)];
            
            y += interval;
        }
    }
    
    self.shelfRects = [NSDictionary dictionaryWithDictionary:dictionary];
}

// Return attributes of all items (cells, supplementary views, decoration views) that appear within this rect
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // call super so flow layout can return default attributes for all cells, headers, and footers
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    // tweak the attributes slightly
    for (SMShelfLayoutAttributes *attributes in array)
    {
        attributes.zIndex = 1;
        //if (attributes.representedElementCategory != UICollectionElementCategoryCell)
        /*if (attributes.representedElementCategory != UICollectionElementCategorySupplementaryView || [attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader])
         attributes.alpha = 0.5;
         else if (attributes.indexPath.row > 0 || attributes.indexPath.section > 0)
         attributes.alpha = 0.5; // for single cell closeup*/
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal &&
            attributes.representedElementCategory == UICollectionElementCategorySupplementaryView)
        {
            // make label vertical if scrolling is horizontal
            attributes.transform3D = CATransform3DMakeRotation(-90 * M_PI / 180, 0, 0, 1);
            attributes.size = CGSizeMake(attributes.size.height, attributes.size.width);
        }
        /*
        if (attributes.representedElementCategory == UICollectionElementCategorySupplementaryView && [attributes isKindOfClass:[ConferenceLayoutAttributes class]])
        {
            ConferenceLayoutAttributes *conferenceAttributes = (ConferenceLayoutAttributes *)attributes;
            conferenceAttributes.headerTextAlignment = NSTextAlignmentLeft;
        }
         */
        
        // is edit mode
        BOOL isEditModeOn = [self isEditModeOn];
        attributes.inEditMode = isEditModeOn;
    }
    
    // Add our decoration views (shelves)
    NSMutableArray *newArray = [array mutableCopy];
    
    [self.shelfRects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (CGRectIntersectsRect([obj CGRectValue], rect))
        {
            UICollectionViewLayoutAttributes *attributes =
            [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[SMShelfDecoratorView kind]
                                                                        withIndexPath:key];
            CGRect fr = [obj CGRectValue];
            fr.origin.y -= CGRectGetHeight([obj CGRectValue] );
            attributes.frame = fr;
            attributes.zIndex = 0; // send it to back
            //attributes.alpha = 0.5; // screenshots
            [newArray addObject:attributes];
        }
    }];
    
    // Add a logo view
    UICollectionViewLayoutAttributes *logoAttrs =
    [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[SMLogoDecorationView kind]
                                                                withIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    logoAttrs.frame = [self.logoRect CGRectValue];
    [newArray addObject:logoAttrs];
    
    // return are modifier array
    array = [NSArray arrayWithArray:newArray];
    return array;
}

// Layout attributes for a specific cell
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SMShelfLayoutAttributes *attributes = (SMShelfLayoutAttributes *)[super layoutAttributesForItemAtIndexPath:indexPath];
    
    // cell items needs to be on top of the decoration view
    attributes.zIndex = 1;
    
    BOOL isEditModeOn = [self isEditModeOn];
    attributes.inEditMode = isEditModeOn;
    
    return attributes;
}

// layout attributes for a specific header or footer
/*
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:[SmallConferenceHeader kind]])
        return nil;
    
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    attributes.zIndex = 1;
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal)
    {
        // make label vertical if scrolling is horizontal
        attributes.transform3D = CATransform3DMakeRotation(-90 * M_PI / 180, 0, 0, 1);
        attributes.size = CGSizeMake(attributes.size.height, attributes.size.width);
    }
    
    if ([attributes isKindOfClass:[ConferenceLayoutAttributes class]])
    {
        ConferenceLayoutAttributes *conferenceAttributes = (ConferenceLayoutAttributes *)attributes;
        conferenceAttributes.headerTextAlignment = NSTextAlignmentLeft;
    }
    
    return attributes;
}
*/
// layout attributes for a specific decoration view
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    id shelfRect = self.shelfRects[indexPath];
    if (!shelfRect)
        return nil; // no shelf at this index (this is probably an error)
    
    UICollectionViewLayoutAttributes *attributes =
    [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[SMShelfDecoratorView kind]
                                                                withIndexPath:indexPath];
    attributes.frame = [shelfRect CGRectValue];
    attributes.zIndex = 0; // shelves go behind other views
    
    return attributes;
}

#pragma mark - private methods

- (BOOL)isEditModeOn
{
    if ([self.collectionView.delegate conformsToProtocol:@protocol(SMBookShelfLayoutDelegate)]) {
        return [(id)self.collectionView.delegate isEditModeActiveForCollectionView:self.collectionView
                                                                            layout:self];
    }
    return NO;
}

@end
