//
//  SMBookStoreContainer.m
//  Newsstand
//
//  Created by Suleyman Melikoglu on 29/01/14.
//  Copyright (c) 2014 ZulaMobile. All rights reserved.
//

#import "SMBookStoreContainer.h"
#import "SMBookStore.h"

@interface SMBookStoreContainer ()
@property (nonatomic, strong) NSMutableDictionary *bookStores;
@end

@implementation SMBookStoreContainer

+ (instancetype)sharedObject
{
    static SMBookStoreContainer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SMBookStoreContainer new];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.bookStores = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (SMBookStore *)bookStoreForKey:(id)key
{
    return [self.bookStores objectForKey:key];
}

- (void)addBookStore:(SMBookStore *)bookStore forKey:(id)key
{
    [self.bookStores setObject:bookStore forKey:key];
}

@end
