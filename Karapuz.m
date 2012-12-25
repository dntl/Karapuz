//
//  Karapuz.m
//  Karapuz
//
//  Created by Vladimir Obrizan on 19.12.12.
//  Copyright (c) 2012 Design and Test Lab. All rights reserved.
//

#import "Karapuz.h"

@implementation Karapuz

static Karapuz *gInstance = NULL;


////////////////////////////////////////////////////////////////////////////////


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


////////////////////////////////////////////////////////////////////////////////


-(id)init
{
	self = [super init];
	if (self)
	{
		self.bindings = [NSMutableArray array];
	}
	return self;
}


////////////////////////////////////////////////////////////////////////////////


+(void)dest:(id)dest pty:(NSString *)pty src:(id)src pty:(NSString *)pty2;
{
	NSDictionary *d = @{@"dest": dest, @"pty": pty, @"src": src, @"pty2": pty2};
	[Karapuz.instance.bindings addObject:d];
	[src addObserver:Karapuz.instance forKeyPath:pty2 options:0 context:nil];
}


////////////////////////////////////////////////////////////////////////////////


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	for (NSDictionary *binding in self.bindings)
	{
		if ([binding[@"pty2"] isEqualToString:keyPath])
		{
			id value = [object performSelector:NSSelectorFromString(keyPath)];
			id dest = binding[@"dest"];
			NSString *pty = binding[@"pty"];
			NSString *selectorName = [NSString stringWithFormat:@"set%@:", pty.capitalizedString];
			SEL sel = NSSelectorFromString(selectorName);
			[dest performSelector:sel withObject:value];
			
			break;
		}
	}
}


////////////////////////////////////////////////////////////////////////////////

@end
