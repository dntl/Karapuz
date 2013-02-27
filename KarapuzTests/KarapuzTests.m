//==============================================================================
//
//
//  KarapuzTests.m
//  KarapuzTests
//
//  Created by krasylnikov on 2/25/13.
//  Copyright (c) 2013 Design and Test lab. All rights reserved.
//
//
//==============================================================================


#import "KarapuzTests.h"
#import "Karapuz.h"
#import "ViewController.h"


//==============================================================================


@implementation KarapuzTests


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
    // Create view controller for testing
    ViewController *vc = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
   
    // Set tag to force view loading
    vc.view.tag = 1;    
    
    // Subscribe property "text" of view controller label to changing of "textStr" property of view controller
    [Karapuz dst:vc.label pty:@"text" src:vc pty:@"textStr"];
    
    // Subscribe self (test class) to changing of "text" property of "label" property of view controller
    [Karapuz dst:self
           block:^(id src, NSString *pty2)
     {
         NSString *newText = [NSString stringWithFormat:@"Test text: %@",vc.label.text];
         
         if (vc.label2)
         {
             vc.label2.text = newText;
             [vc.label2 sizeToFit];
         }
         else
         {
             UILabel *testLbl = [[UILabel alloc] init];
             testLbl.text = newText;
             [vc.view addSubview:testLbl];
             vc.label2 = testLbl;
         }
     }
             src:vc.label
             pty:@"text"];
    
    // Change text in textField in view controller
    vc.textField.text = @"Test 1 text";
    
    // Emulate button tap
    [vc buttonTapped:vc.button];
    
    // vc.label.text should be changed to "Test 1 text" by view controller
    STAssertTrue([vc.label.text isEqualToString:@"Test 1 text"], @"Strings not match");
    
    // vc.label2.text should be changed to "Test text: Test 1 text" by test class
    STAssertTrue([vc.label2.text isEqualToString:@"Test text: Test 1 text"], @"Strings not match");
    
    // Unsubscribe self (test class)
    [Karapuz remove:self];
    
    // Change text in textField in view controller
    vc.textField.text = @"Test 2 text";
    
    // Emulate button tap
    [vc buttonTapped:vc.button];
    
    // vc.label.text should be changed to "Test 2 text" by view controller
    STAssertTrue([vc.label.text isEqualToString:@"Test 2 text"], @"Strings not match");
    
    // vc.label2.text should stay "Test text: Test 1 text" because test class was unsubsribed
    STAssertTrue([vc.label2.text isEqualToString:@"Test text: Test 1 text"], @"Strings not match");
    
    // Unsubscribe view controller label
    [Karapuz remove:vc.label];
    
    // Change text in textField in view controller
    vc.textField.text = @"Test 3 text";
    
    // Emulate button tap
    [vc buttonTapped:vc.button];
    
    // vc.label.text should stay "Test text: Test 2 text" because view controller label was unsubsribed
    STAssertTrue([vc.label.text isEqualToString:@"Test 2 text"], @"Strings not match");
    
    // vc.label2.text should stay "Test text: Test 1 text" because test class was unsubsribed
    STAssertTrue([vc.label2.text isEqualToString:@"Test text: Test 1 text"], @"Strings not match");
}


//==============================================================================


-(void)test2
{
    [self subscrVC];
    self.str = @"test";
    
    STAssertTrue((Karapuz.instance.bindings.count == 0), @"Karapuz bindings shoud be empty");
}


//==============================================================================


- (void)subscrVC
{   
    // Create view controller for testing
    ViewController *vc = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    
    // Set tag to force view loading
    vc.view.tag = 1;
    
    // Subscribe property "textStr" of view controller to changing of "text" property of view controller label
    [Karapuz dst:vc pty:@"testTmp" src:self pty:@"str"];
    [Karapuz dst:self pty:@"str2" src:vc pty:@"testTmp2"];
    
    [Karapuz dst:vc
           block:^(id src, NSString *pty2)
     {
         vc.textStr = @"new";
     }
             src:self
             pty:@"str"];
}


//==============================================================================


@end
