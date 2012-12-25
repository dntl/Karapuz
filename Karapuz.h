//
//  Karapuz.h
//  Karapuz
//
//  Created by Vladimir Obrizan on 19.12.12.
//  Copyright (c) 2012 Design and Test Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Karapuz : NSObject

@property (nonatomic, retain) NSMutableArray *bindings;

+(Karapuz *)instance;

+(void)dest:(id)dest pty:(NSString *)pty src:(id)src pty:(NSString *)pty2;

@end
