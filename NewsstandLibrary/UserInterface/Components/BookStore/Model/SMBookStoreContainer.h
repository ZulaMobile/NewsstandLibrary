//
//  SMBookStoreContainer.h
//  Newsstand
//
//  Created by Suleyman Melikoglu on 29/01/14.
//  Copyright (c) 2014 ZulaMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMBookStore;

@interface SMBookStoreContainer : NSObject

+ (instancetype)sharedObject;

- (SMBookStore *)bookStoreForKey:(id)key;

- (void)addBookStore:(SMBookStore *)bookStore forKey:(id)key;

@end
