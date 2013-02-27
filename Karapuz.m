//==============================================================================
//
//
//  Karapuz.m
//  Karapuz
//
//  Created by Vladimir Obrizan on 19.12.12.
//  Copyright (c) 2012 Design and Test Lab. All rights reserved.
//
//
//==============================================================================


#import "Karapuz.h"
#import <objc/message.h>
#import "WeakStore.h"


//==============================================================================


@implementation Karapuz


//==============================================================================


static Karapuz *gInstance = NULL;


//==============================================================================


+(Karapuz *)instance
{
	@synchronized(self)
    {
        if (gInstance == NULL)
		{
            gInstance = [self new];
		}
    }
	
    return gInstance;
}


//==============================================================================


-(id)init
{
	self = [super init];
	if (self)
	{
		self.bindings = [NSMutableArray array];
	}
	return self;
}


//==============================================================================


+(void)dst:(id)dst pty:(NSString *)pty src:(id)src pty:(NSString *)pty2;
{
    WeakStore *weakDst = [[WeakStore alloc] initWithObj:dst];
    WeakStore *weakSrc = [[WeakStore alloc] initWithObj:src];
    
	NSDictionary *d = @{@"dst": weakDst,
                     @"pty": pty,
                     @"src": weakSrc,
                     @"pty2": pty2,
                     @"dstAddr": [NSString stringWithFormat:@"%p",dst],
                     @"srcAddr": [NSString stringWithFormat:@"%p",src]};
	[Karapuz.instance.bindings addObject:d];
	[src addObserver:Karapuz.instance forKeyPath:pty2 options:0 context:nil];
}


//==============================================================================


+(void)dst:(id)dst block:(KarapuzBlock)block src:(id)src pty:(NSString *)pty2
{
    WeakStore *weakDst = [[WeakStore alloc] initWithObj:dst];
    WeakStore *weakSrc = [[WeakStore alloc] initWithObj:src];
    
	NSDictionary *d = @{@"dst": weakDst,
                     @"block": block,
                     @"src": weakSrc,
                     @"pty2": pty2,
                     @"dstAddr": [NSString stringWithFormat:@"%p",dst],
                     @"srcAddr": [NSString stringWithFormat:@"%p",src]};
	[Karapuz.instance.bindings addObject:d];
	[src addObserver:Karapuz.instance forKeyPath:pty2 options:0 context:nil];
}


//==============================================================================


#pragma mark - Observers

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	for (NSDictionary *binding in self.bindings)
	{
		if ([binding[@"pty2"] isEqualToString:keyPath] && ([binding[@"srcAddr"] isEqualToString:[NSString stringWithFormat:@"%p",object]]))
		{            
			NSString *pty = binding[@"pty"];
			
			if (pty)
			{				
				id value = objc_msgSend(object, NSSelectorFromString(keyPath));
                WeakStore *weakDst = (WeakStore *)binding[@"dst"];
                if ([Karapuz exists:weakDst])
                {
                    id dst = weakDst.store;
                    NSString *selectorName = [NSString stringWithFormat:@"set%@:", [pty stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[pty substringToIndex:1] capitalizedString]]];
                    objc_msgSend(dst, NSSelectorFromString(selectorName), value);
                    continue;
                }
			}
			
			KarapuzBlock block = binding[@"block"];
			if (block)
			{
				block(object, keyPath);
				continue;
			}
			
		}
	}
    
    [self check];
}


//==============================================================================


+(void)remove:(id)dst
{
	NSMutableArray *objectsToBeRemoved = [NSMutableArray array];
	for (NSDictionary *d in Karapuz.instance.bindings)
	{
		if ([d[@"dstAddr"] isEqualToString:[NSString stringWithFormat:@"%p",dst]])
		{
            WeakStore *weakSrc = (WeakStore *)d[@"src"];
            if ([Karapuz exists:weakSrc])
            {
                id obj = weakSrc.store;
                [obj removeObserver:Karapuz.instance forKeyPath:d[@"pty2"]];
            }
			[objectsToBeRemoved addObject:d];
		}
	}
	
	for (NSDictionary *d in objectsToBeRemoved)
		[Karapuz.instance.bindings removeObject:d];
}


//==============================================================================


-(void)check
{
    NSMutableArray *objectsToBeRemoved = [NSMutableArray array];
	for (NSDictionary *d in Karapuz.instance.bindings)
	{
        WeakStore *weakDst = (WeakStore *)d[@"dst"];
        WeakStore *weakSrc = (WeakStore *)d[@"src"];
        
		if (![Karapuz exists:weakSrc] || ![Karapuz exists:weakDst])
		{
            if ([Karapuz exists:weakSrc])
            {
                id obj = weakSrc.store;
                [obj removeObserver:Karapuz.instance forKeyPath:d[@"pty2"]];
            }
            [objectsToBeRemoved addObject:d];
		}
	}
	
	for (NSDictionary *d in objectsToBeRemoved)
		[Karapuz.instance.bindings removeObject:d];
}


//==============================================================================


+(BOOL)exists:(WeakStore *)weakStore
{
    BOOL isExist = YES;
    @try
    {
        [weakStore store];
    }
    @catch (NSException * e)
    {
        NSLog(@"Exception: %@", e);
        isExist = NO;
    }
    
    if (isExist)
    {
        if (weakStore.store)
            isExist = YES;
        else
            isExist = NO;
    }

    return isExist;
}

@end