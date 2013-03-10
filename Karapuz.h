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


/** Add observer 'dst' to observe property 'pty2' of the 'src' object.
 *
 * @param	dst	An object-observer.
 * @param	pty		A property to be updated.
 * @param	src		An object-source.
 * @param	pty2	A property being observed.
 */
+(void)dst:(id)dst pty:(NSString *)pty src:(id)src pty:(NSString *)pty2;


/** Removes the observer from all objects.
 *
 * @param	dst	The observer to be removed.
 */
+(void)remove:(id)dst;



+(void)dst:(id)dst block:(KarapuzBlock)block src:(id)src pty:(NSString *)pty2;

@end


//==============================================================================


@interface WeakStore : NSObject

@property (nonatomic, weak) id store;

// Blocks must have the "copy" attribute, as they are allocated on the stack.
// http://stackoverflow.com/questions/3935574/can-i-use-objective-c-blocks-as-properties
@property (nonatomic, copy) KarapuzBlock storeBlock;

-(id)initWithObj:(id)obj;
-(id)initWithBlo:(KarapuzBlock)blo;

@end