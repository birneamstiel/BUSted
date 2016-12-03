//
//  ArrowViewController.m
//  BUStedDebug
//
//  Created by Lukas on 03/12/16.
//  Copyright © 2016 Lukas Fritzsche. All rights reserved.
//

#import "BUSArrowViewController.h"
#import "BUSArrowIndicatorView.h"

@interface BUSArrowViewController ()
@property UIView * circleView;
@end

@implementation BUSArrowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:UIColorFromRGB(0x393939)];
    
    [self setupArrowView];
}

- (void) setupArrowView {
    self.circleView = [[BUSArrowIndicatorView alloc] initWithFrame:CGRectMake(20,20,300,300)];
    
    [self.view addSubview: self.circleView];
    
    self.circleView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *centerX =[NSLayoutConstraint
                                  constraintWithItem:self.circleView
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1.0f
                                  constant:0];
    
    NSLayoutConstraint *centerY =[NSLayoutConstraint
                                  constraintWithItem:self.circleView
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                                  attribute:NSLayoutAttributeCenterY
                                  multiplier:1.0f
                                  constant:0];
    
    NSLayoutConstraint *width =[NSLayoutConstraint
                                constraintWithItem:self.circleView
                                attribute:NSLayoutAttributeWidth
                                relatedBy:NSLayoutRelationEqual
                                toItem:nil
                                attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0f
                                constant:300];
    
    NSLayoutConstraint *height = [NSLayoutConstraint
                                  constraintWithItem:self.circleView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                  multiplier:1.0f
                                  constant:300];
    
    centerX.active = YES;
    centerY.active = YES;
    width.active = YES;
    height.active = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
