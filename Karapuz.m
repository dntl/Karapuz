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


+(void)dest:(id)dest pty:(NSString *)pty src:(id)src pty:(NSString *)pty2;
{
	NSDictionary *d = @{@"dest": dest, @"pty": pty, @"src": src, @"pty2": pty2};
	[Karapuz.instance.bindings addObject:d];
	[src addObserver:Karapuz.instance forKeyPath:pty2 options:0 context:nil];
}


//==============================================================================


+(void)remove:(id)dest
{
	NSMutableArray *objectsToBeRemoved = [NSMutableArray array];
	for (NSDictionary *d in Karapuz.instance.bindings)
	{
		if ([d[@"dest"] isEqual:dest])
		{
			id obj = d[@"src"];
			[obj removeObserver:Karapuz.instance forKeyPath:d[@"pty2"]];
			[objectsToBeRemoved addObject:d];
		}
	}
	
	for (id d in objectsToBeRemoved)
		[Karapuz.instance.bindings removeObject:d];
}


//==============================================================================


+(void)dest:(id)dest block:(KarapuzBlock)block src:(id)src pty:(NSString *)pty2
{
	NSDictionary *d = @{@"dest": dest, @"block": block, @"src": src, @"pty2": pty2};
	[Karapuz.instance.bindings addObject:d];
	[src addObserver:Karapuz.instance forKeyPath:pty2 options:0 context:nil];	
}


//==============================================================================


#pragma mark - Observers

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	for (NSDictionary *binding in self.bindings)
	{
		if ([binding[@"pty2"] isEqualToString:keyPath] && (binding[@"src"] == object))
		{
			NSString *pty = binding[@"pty"];
			
			if (pty)
			{				
				id value = objc_msgSend(object, NSSelectorFromString(keyPath));
				id dest = binding[@"dest"];
				NSString *selectorName = [NSString stringWithFormat:@"set%@:", pty.capitalizedString];
				objc_msgSend(dest, NSSelectorFromString(selectorName), value);
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


@end
