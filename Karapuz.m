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
    WeakStore *weakBlc = [[WeakStore alloc] initWithBlo:block];
    
	NSDictionary *d = @{@"dst": weakDst,
                     @"block": weakBlc,
                     @"src": weakSrc,
                     @"pty2": pty2,
                     @"dstAddr": [NSString stringWithFormat:@"%p",dst],
                     @"srcAddr": [NSString stringWithFormat:@"%p",src]};
	[Karapuz.instance.bindings addObject:d];
	[src addObserver:Karapuz.instance forKeyPath:pty2 options:0 context:nil];
}


//==============================================================================


+(void)dst:(id)dst selector:(NSString *)selector withParams:(NSDictionary *)params src:(id)src pty:(NSString *)pty2
{
    WeakStore *weakDst = [[WeakStore alloc] initWithObj:dst];
    WeakStore *weakSrc = [[WeakStore alloc] initWithObj:src];
    
    if (!params)
        params = [NSDictionary dictionaryWithObject:@"" forKey:@"testParam"];
    
    NSDictionary *d = @{@"dst": weakDst,
                        @"selector": selector,
                        @"params" : params,
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
			WeakStore *weakDst = (WeakStore *)binding[@"dst"];
            if ([Karapuz exists:weakDst])
            {
                id dst = weakDst.store;
                
                NSString *pty = binding[@"pty"];
                if (pty)
                {
                    id value = objc_msgSend(object, NSSelectorFromString(keyPath));
                    NSString *selectorName = [NSString stringWithFormat:@"set%@:", [pty stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[pty substringToIndex:1] capitalizedString]]];
                    objc_msgSend(dst, NSSelectorFromString(selectorName), value);
                }
                
                WeakStore *weakBlc = (WeakStore *)binding[@"block"];
                if (weakBlc)
                    if ([Karapuz exists:weakBlc])
                    {
                        KarapuzBlock block = weakBlc.storeBlock;
                        if (block)
                            block(object, keyPath);
                    }
                
                NSString *selector = binding[@"selector"];
                if (selector)
                    objc_msgSend(dst, NSSelectorFromString(selector), binding[@"params"]);
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
    
    [Karapuz.instance check];
}


//==============================================================================


+(void)removeAll
{
	NSArray *objectsToBeRemoved = [Karapuz.instance.bindings copy];
	
	for (NSDictionary *d in objectsToBeRemoved)
    {
        WeakStore *weakDst = (WeakStore *)d[@"dst"];
        if ([Karapuz exists:weakDst])
        {
            id dst = weakDst.store;
            [Karapuz remove:dst];
        }
    }
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
    BOOL isExist = [weakStore store] ? YES : NO;
    
    if (isExist)
        return isExist;
    else
        isExist = [weakStore storeBlock] ? YES : NO;
    
    return isExist;
}

@end


//==============================================================================


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

-(id)initWithBlo:(KarapuzBlock)blo
{
    self = [super init];
	if (self)
	{
        self.storeBlock = blo;
    }
    return self;
}


//==============================================================================


@end