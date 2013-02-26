//
//  WeakStore.m
//  Karapuz
//
//  Created by krasylnikov on 2/26/13.
//  Copyright (c) 2013 Design and Test lab. All rights reserved.
//

#import "WeakStore.h"

@implementation WeakStore

-(id)initWithObj:(id)obj
{
    self = [super init];
	if (self)
	{
        self.store = obj;
    }
    return self;
}

@end
