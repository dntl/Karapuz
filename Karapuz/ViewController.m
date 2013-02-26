//==============================================================================
//
//
//  ViewController.m
//  Karapuz
//
//  Created by krasylnikov on 2/25/13.
//  Copyright (c) 2013 Design and Test lab. All rights reserved.
//
//
//==============================================================================


#import "ViewController.h"
#import "Karapuz.h"
#import "tmp.h"


//==============================================================================


@interface ViewController ()

@end


//==============================================================================


@implementation ViewController


//==============================================================================


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //tmp *tmpO = [[tmp alloc] init];
    
    //[Karapuz dst:tmpO pty:@"tmpPty" src:self pty:@"testTmp"];
    //[Karapuz dst:self pty:@"testTmp2" src:tmpO pty:@"tmpPty2"];
}


//==============================================================================


-(IBAction)buttonTapped:(id)sender
{
    self.textStr = self.textField.text;
    
    //self.testTmp = @"try";
}


//==============================================================================


@end
