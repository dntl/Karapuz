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
	NSDictionary *d = @{@"dst": [NSValue valueWithNonretainedObject:dst],
                     @"pty": pty,
                     @"src": [NSValue valueWithNonretainedObject:src],
                     @"pty2": pty2,
                     @"dstAddr": [NSString stringWithFormat:@"%p",dst],
                     @"srcAddr": [NSString stringWithFormat:@"%p",src]};
	[Karapuz.instance.bindings addObject:d];
	[src addObserver:Karapuz.instance forKeyPath:pty2 options:0 context:nil];
}


//==============================================================================


+(void)dst:(id)dst block:(KarapuzBlock)block src:(id)src pty:(NSString *)pty2
{
	NSDictionary *d = @{@"dst": [NSValue valueWithNonretainedObject:dst],
                     @"block": block,
                     @"src": [NSValue valueWithNonretainedObject:src],
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
				id dst = [binding[@"dst"] nonretainedObjectValue];
				NSString *selectorName = [NSString stringWithFormat:@"set%@:", pty.capitalizedString];
				objc_msgSend(dst, NSSelectorFromString(selectorName), value);
				continue;
			}
			
			KarapuzBlock block = binding[@"block"];
			if (block)
			{
				block(object, keyPath);
				continue;
			}
			
		}
	}
}


//==============================================================================


+(void)remove:(id)dst
{
	NSMutableArray *objectsToBeRemoved = [NSMutableArray array];
	for (NSDictionary *d in Karapuz.instance.bindings)
	{
		if ([d[@"dstAddr"] isEqualToString:[NSString stringWithFormat:@"%p",dst]])
		{
			id obj = [d[@"src"] nonretainedObjectValue];
			[obj removeObserver:Karapuz.instance forKeyPath:d[@"pty2"]];
			[objectsToBeRemoved addObject:d];
		}
	}
	
	for (id d in objectsToBeRemoved)
		[Karapuz.instance.bindings removeObject:d];
}


//==============================================================================


@end
