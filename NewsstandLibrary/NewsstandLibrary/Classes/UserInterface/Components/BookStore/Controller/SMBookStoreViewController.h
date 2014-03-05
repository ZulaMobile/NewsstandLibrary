//
//  SMBookStoreViewController.h
//  Newsstand
//
//  Created by Suleyman Melikoglu on 07/11/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZulaLibrary/SMPullToRefreshComponentViewController.h>


@class SMBookStore;

/**
 *  Book Store Component displays a list of issues.
 *  Each issue has a cover and when touched, it displays the contents (pdf or html)
 */
@interface SMBookStoreViewController : SMPullToRefreshComponentViewController 

/**
 *  The model object for this component.
 *  It is responsible to hold the issues
 */
@property (nonatomic, strong) SMBookStore *bookStore;

/**
 *  The main collection view that will hold the issue covers
 */
@property (nonatomic, strong) UICollectionView *collectionView;

@end
