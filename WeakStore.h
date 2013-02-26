//
//  WeakStore.h
//  Karapuz
//
//  Created by krasylnikov on 2/26/13.
//  Copyright (c) 2013 Design and Test lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeakStore : NSObject

@property (nonatomic, weak) id store;

-(id)initWithObj:(id)obj;

@end
