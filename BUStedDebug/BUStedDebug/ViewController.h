//
//  ViewController.h
//  BUStedDebug
//
//  Created by Lukas on 03/12/16.
//  Copyright © 2016 Lukas Fritzsche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)ButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *beaconText1;
@property (weak, nonatomic) IBOutlet UITextView *beaconText2;
@property (weak, nonatomic) IBOutlet UITextView *beaconText3;
@property (weak, nonatomic) IBOutlet UITextView *beaconText4;
@property (weak, nonatomic) IBOutlet UILabel *compassLabel;

@end

