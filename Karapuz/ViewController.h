//
//  ViewController.h
//  Karapuz
//
//  Created by krasylnikov on 2/25/13.
//  Copyright (c) 2013 Design and Test lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) UILabel *label2;
@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong) NSString *testTmp;
@property (nonatomic, strong) NSString *testTmp2;

@property (strong, nonatomic) NSString *textStr;

-(IBAction)buttonTapped:(id)sender;

@end
