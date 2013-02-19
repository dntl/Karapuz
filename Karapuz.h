//==============================================================================
//
//
//  Karapuz.h
//  Karapuz
//
//  Created by Vladimir Obrizan on 19.12.12.
//  Copyright (c) 2012 Design and Test Lab. All rights reserved.
//
//
//==============================================================================


#import <Foundation/Foundation.h>


typedef void (^KarapuzBlock)(id src, NSString *pty2);

@interface Karapuz : NSObject


/// An array of bindings.
@property (nonatomic, retain) NSMutableArray *bindings;


/** Give an instance of Karapuz. It is a singleton.
 *
 * @return	A Karapuz's instance.
 */
+(Karapuz *)instance;


/** Add observer 'dest' to observe property 'pty2' of the 'src' object.
 *
 * @param	dest	An object-observer.
 * @param	pty		A property to be updated.
 * @param	src		An object-source.
 * @param	pty2	A property being observed.
 */
+(void)dest:(id)dest pty:(NSString *)pty src:(id)src pty:(NSString *)pty2;


/** Removes the observer from all objects.
 *
 * @param	dest	The observer to be removed.
 */
+(void)remove:(id)dest;



+(void)dest:(id)dest block:(KarapuzBlock)block src:(id)src pty:(NSString *)pty2;


@end
