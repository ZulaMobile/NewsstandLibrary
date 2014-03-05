//
//  SMShelfLayoutAttributes.m
//  Newsstand
//
//  Created by Suleyman Melikoglu on 04/12/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import "SMShelfLayoutAttributes.h"

@implementation SMShelfLayoutAttributes

- (id)copyWithZone:(NSZone *)zone
{
    SMShelfLayoutAttributes *attributes = [super copyWithZone:zone];
    attributes.inEditMode = _inEditMode;
    attributes.markButtonHidden = _markButtonHidden;
    
    return attributes;
}

@end
