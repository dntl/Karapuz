//
//  KrpzosxTests.m
//  KrpzosxTests
//
//  Created by krasylnikov on 3/6/13.
//  Copyright (c) 2013 Design and Test lab. All rights reserved.
//

#import "KrpzosxTests.h"
#import "Karapuz.h"
#import "tmp.h"

@implementation KrpzosxTests

//==============================================================================


- (void)setUp
{
    NSLog(@"\n\n\n------------   Test start    ------------------");
    [super setUp];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
    NSLog(@"\n------------    Test end     ------------------\n\n\n");
}


//==============================================================================


- (void)test1
{
    tmp *t = [[tmp alloc] init];
    tmp *t2 = [[tmp alloc] init];
    
    t.tmpPty = @"11";
    t.tmpPty2 = @"12";
    
    t2.tmpPty = @"21";
    t2.tmpPty2 = @"22";
    
    [Karapuz dst:t2 pty:@"tmpPty2" src:t pty:@"tmpPty2"];
    [Karapuz dst:t2 pty:@"tmpPty" src:t2 pty:@"tmpPty2"];
    
    [Karapuz dst:t
           block:^(id src, NSString *pty2)
     {
         t.tmpPty = t2.tmpPty;
     }
             src:t2
             pty:@"tmpPty"];
    
    
    t.tmpPty2 = @"test";
    
    STAssertTrue([t.tmpPty isEqualToString:@"test"], @"Strings not match");
    STAssertTrue([t.tmpPty2 isEqualToString:@"test"], @"Strings not match");
    STAssertTrue([t2.tmpPty isEqualToString:@"test"], @"Strings not match");
    STAssertTrue([t.tmpPty2 isEqualToString:@"test"], @"Strings not match");
    STAssertTrue((Karapuz.instance.bindings.count == 3), @"Karapuz bindings should have 3 bindings");
    
    [Karapuz remove:t];
    t.tmpPty2 = @"test2";
    
    STAssertTrue([t.tmpPty isEqualToString:@"test"], @"Strings not match");
    STAssertTrue([t.tmpPty2 isEqualToString:@"test2"], @"Strings not match");
    STAssertTrue([t2.tmpPty isEqualToString:@"test2"], @"Strings not match");
    STAssertTrue([t2.tmpPty2 isEqualToString:@"test2"], @"Strings not match");
    STAssertTrue((Karapuz.instance.bindings.count == 2), @"Karapuz bindings should have 3 bindings");
    
    [Karapuz remove:t2];
    t.tmpPty2 = @"test3";
    
    STAssertTrue([t.tmpPty isEqualToString:@"test"], @"Strings not match");
    STAssertTrue([t.tmpPty2 isEqualToString:@"test3"], @"Strings not match");
    STAssertTrue([t2.tmpPty isEqualToString:@"test2"], @"Strings not match");
    STAssertTrue([t2.tmpPty2 isEqualToString:@"test2"], @"Strings not match");
    STAssertTrue((Karapuz.instance.bindings.count == 0), @"Karapuz bindings should be empty");
}


//==============================================================================


-(void)test2
{
    [self subscrTmp];
    self.str = @"test";
    
    STAssertTrue((Karapuz.instance.bindings.count == 0), @"Karapuz bindings should be empty");
    [Karapuz removeAll];
}


//==============================================================================


-(void)test3
{
    tmp *t = [[tmp alloc] init];
    tmp *t2 = [[tmp alloc] init];
    
    t.tmpPty = @"11";
    t.tmpPty2 = @"12";
    
    t2.tmpPty = @"21";
    t2.tmpPty2 = @"22";    

    [Karapuz dst:self selector:NSStringFromSelector(@selector(selectorTest)) withParams:nil src:t pty:@"tmpPty"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:t2.tmpPty forKey:@"testParam"];
    
    [Karapuz dst:self selector:NSStringFromSelector(@selector(selectorTestWithParams:)) withParams:params src:t2 pty:@"tmpPty"];
    
    t.tmpPty = @"Selector testing";
    STAssertTrue([self.str isEqualToString:@"selectorTest"], @"Strings not match");    
    
    t2.tmpPty = @"Selector with params testing";
    STAssertTrue([self.str isEqualToString:@"21"], @"Strings not match");
    
    [Karapuz remove:self];
}


//==============================================================================


-(void)test4
{
    tmp *t = [[tmp alloc] init];
    
    t.tmpPty = @"11";
    self.str = @"";
    
    [Karapuz dst:self selector:@selector(selectorTest) src:t pty:@"tmpPty"];
    
    t.tmpPty = @"Selector testing";
    STAssertTrue([self.str isEqualToString:@"selectorTest"], @"Strings not match");
    
    [Karapuz remove:self];
}


//==============================================================================


- (void)subscrTmp
{
    tmp *t = [[tmp alloc] init];
    
    t.tmpPty = @"11";
    t.tmpPty2 = @"12";
    
    [Karapuz dst:t pty:@"tmpPty" src:self pty:@"str"];
    [Karapuz dst:self pty:@"str2" src:t pty:@"tmpPty"];
    
    [Karapuz dst:t
           block:^(id src, NSString *pty2)
     {
         t.tmpPty2 = self.str;
     }
             src:self
             pty:@"str2"];
}


//==============================================================================


-(void)selectorTest
{
    self.str = @"selectorTest";
}


//==============================================================================


-(void)selectorTestWithParams:(NSDictionary *)params
{
    self.str = params[@"testParam"];
}


//==============================================================================

@end
