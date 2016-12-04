//
//  ArrowViewController.m
//  BUStedDebug
//
//  Created by Lukas on 03/12/16.
//  Copyright © 2016 Lukas Fritzsche. All rights reserved.
//

#import "BUSArrowViewController.h"
#import "BUSArrowIndicatorView.h"
#include <CoreLocation/CoreLocation.h>
#include <math.h>
#import <KontaktSDK/KontaktSDK.h>
#import "BUSBeacon.h"
#import <float.h>
#import <AVFoundation/AVFoundation.h>


#define BEACON_18CSN_MAJOR 42563
#define BEACON_18CSN_MINOR 20278

#define BEACON_XPQE_MAJOR 44025
#define BEACON_XPQE_MINOR 64030

#define BEACON_0JNW_MAJOR 21307
#define BEACON_0JNW_MINOR 26964

#define BEACON_F905_MAJOR 38605
#define BEACON_F905_MINOR 63779

#define APPROXIMITY_THRESHOLD 2.5
#define REDIRECT_FACTOR 1.3

// sample path "Spielfeld" with left turn
#define PATH_ARRAY [NSMutableArray arrayWithObjects:@"38605",@"21307",@"44025",nil]
// sample path "Spielfeld", go straight
#define PATH_ARRAY2 [NSMutableArray arrayWithObjects:@"38605",@"21307",@"42563",nil]
// sample path "Schlesisches Tor"
#define PATH_ARRAY3 [NSMutableArray arrayWithObjects:@"38605",@"42563",@"44025", @"21307",nil]

#define START @"Let's go"
#define TURN_RIGHT @"Turn right"
#define TURN_LEFT @"Turn left"
#define REACHED_DESTINATION @"Jump in the bus baby"
#define GO_STRAIGHT @"Go ahead"

@interface BUSArrowViewController () <KTKBeaconManagerDelegate, CLLocationManagerDelegate>

@property BUSArrowIndicatorView * circleView;
@property KTKBeaconManager *beaconManager;

// ID of BUSBeacon as NSString --> BUSBeacon
@property NSMutableDictionary *beacons;

@end

@implementation BUSArrowViewController {
    CLLocationManager *locationManager;
    BUSBeacon *currentBeacon;
    NSMutableArray<NSString *> *path;
    double degree;
    bool finished;
    bool navigationHasStarted;
    NSString * destinationID;
    int beaconCounter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.beacons = [[NSMutableDictionary alloc] init];
    
    [self.view setBackgroundColor:UIColorFromRGB(0x393939)];
    
    // init
    path = PATH_ARRAY;
    finished = false;
    destinationID = [path objectAtIndex:path.count - 1];
    
    [self setupArrowView];
    [self setupBeacons];
    beaconCounter = (int) path.count;
    
    UIImage *pattern = [UIImage imageNamed:@"background_pattern@2x.png"];
    UIColor * bg = [UIColor colorWithPatternImage:pattern];
    self.view.backgroundColor = bg;
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    
    if([CLLocationManager headingAvailable]) {
        [locationManager startUpdatingHeading];
    }
}

- (void)locationManager:(CLLocationManager*)manager didUpdateHeading:(CLHeading*)newHeading
{
    // If the accuracy is valid, process the event.
    if (newHeading.headingAccuracy > 0){
        CLLocationDirection theHeading = newHeading.magneticHeading;
        degree = theHeading;
    }
    
    return;
}

- (void) setupBeacons {
    self.beaconManager = [[KTKBeaconManager alloc] initWithDelegate:self];
    
    switch ([KTKBeaconManager locationAuthorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            [self.beaconManager requestLocationAlwaysAuthorization];
            break;
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            // No access to Location Services
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // For most iBeacon-based app this type of
            // permission is not adequate
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            // We will use this later
            break;
    }
    
    NSUUID *myProximityUUID = [[NSUUID alloc] initWithUUIDString:@"f7826da6-4fa2-4e98-8024-bc5b71e0893e"];
    KTKBeaconRegion *region8CSN = [[KTKBeaconRegion alloc] initWithProximityUUID:myProximityUUID identifier:@"BUSted beacon reagion1"];
//    KTKBeaconRegion *regionXpQe = [[KTKBeaconRegion alloc] initWithProximityUUID:myProximityUUID major:BEACON_XPQE_MAJOR minor:BEACON_XPQE_MINOR identifier:@"BUSted beacon reagion2"];
//    KTKBeaconRegion *region0jnw = [[KTKBeaconRegion alloc] initWithProximityUUID:myProximityUUID major:BEACON_0JNW_MAJOR minor:BEACON_0JNW_MINOR identifier:@"BUSted beacon reagion3"];
//    KTKBeaconRegion *regionf905 = [[KTKBeaconRegion alloc] initWithProximityUUID:myProximityUUID major:BEACON_F905_MAJOR minor:BEACON_F905_MINOR identifier:@"BUSted beacon reagion4"];
    
    switch ([KTKBeaconManager locationAuthorizationStatus]) {
            // Non-relevant cases are cut
        case kCLAuthorizationStatusAuthorizedAlways:
            if ([KTKBeaconManager isMonitoringAvailable]) {
                [self.beaconManager startMonitoringForRegion:region8CSN];
                [self.beaconManager startRangingBeaconsInRegion:region8CSN];
                
//                [self.beaconManager startMonitoringForRegion:regionXpQe];
//                [self.beaconManager startRangingBeaconsInRegion:regionXpQe];
//                
//                [self.beaconManager startMonitoringForRegion:region0jnw];
//                [self.beaconManager startRangingBeaconsInRegion:region0jnw];
//                
//                [self.beaconManager startMonitoringForRegion:regionf905];
//                [self.beaconManager startRangingBeaconsInRegion:regionf905];
            }
            break;
    }

}

- (void) stopBeacons {
    [self.beaconManager stopMonitoringForAllRegions];
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

/**
 * Main logic, gets called when beacon data is ready.
 *
 */
- (void)calculateNewDirection {
    if ([self userReachedDestination] || ![self navigationStarted] || [path count] == 0) {
        return;
    }
    
    BUSBeacon *nextBeacon = [self.beacons objectForKey:[path objectAtIndex:0]];
    
    double oldAngle = degree;
    
    NSNumber *newAngle = [currentBeacon.neighbours objectForKey:[path objectAtIndex:0]];
    [self.circleView rotateArrowBy: [self translateAngleToOrientation:[newAngle floatValue]]];
    
    if (nextBeacon && [nextBeacon.accuracy doubleValue]  - REDIRECT_FACTOR * [currentBeacon.accuracy doubleValue] < 0) {
        currentBeacon = [self.beacons objectForKey:[path objectAtIndex:0]];
        [path removeObjectAtIndex:0];
        beaconCounter--;
        
        // Speak baby
        if ([path count] > 0) {
            newAngle = [currentBeacon.neighbours objectForKey:[path objectAtIndex:0]];
            double angleDifference = [self buildAngleDifference:oldAngle and: [newAngle doubleValue]];
            NSString *text = [self getTextForSpeak:angleDifference];
            [self speak:text];
        }
    }
    
    //[self printDebugInfo];
}

- (bool) navigationStarted {
    if (navigationHasStarted) {
        return true;
    }
    
    for (BUSBeacon *beacon in [self.beacons allValues]) {
        if ([beacon.id isEqualToString:[path objectAtIndex:0]]) {
            currentBeacon = [self.beacons objectForKey:[path objectAtIndex:0]];
            [path removeObjectAtIndex:0];
            beaconCounter--;
            [self.circleView startedNavigation];
            
            [self speak: START];
            
            return navigationHasStarted =  true;
        }
    }
    
    // start beacon not in sight
    return false;
    
}

- (bool) userReachedDestination {
    if (beaconCounter > 1) {
        return false;
    }
    
    BUSBeacon * strongestBeacon = [self strongestBeaconInReach];
    if ([strongestBeacon.id isEqualToString:destinationID] && [strongestBeacon.accuracy doubleValue] < APPROXIMITY_THRESHOLD) {
        [self reachedDestination];
        return true;
    }
    
    return false;
}

- (BUSBeacon*) strongestBeaconInReach {
    double strongest = DBL_MAX;
    BUSBeacon * strongestBeacon;
    for (BUSBeacon *beacon in [self.beacons allValues]) {
        if ([beacon.accuracy doubleValue] < strongest) {
            strongest = [beacon.accuracy doubleValue];
            strongestBeacon = beacon;
        }
    }
    return strongestBeacon;
}

- (double) translateAngleToOrientation: (double) value {
    return (int)(value - degree) % 360;
}


- (void) reachedDestination {
    [self.circleView reachedDestination];
    [self speak: REACHED_DESTINATION];
    [self stopBeacons];
}


- (void) speak:(NSString*)text {
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    utterance.pitchMultiplier = 1.0;
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    [synth speakUtterance:utterance];
}

- (NSString*) getTextForSpeak:(double)angleDifference {
    if (angleDifference < 0) {
        return TURN_RIGHT;
    } else {
        return TURN_LEFT;
    }
    
    return GO_STRAIGHT;
}

- (double) buildAngleDifference:(double)oldAngle and:(double)newAngle {
    if ((oldAngle <= 180 && newAngle <= 180) || (oldAngle > 180 && newAngle > 180)) {
        return oldAngle - newAngle;
    }
    
    return newAngle - oldAngle;
}


- (void)beaconManager:(KTKBeaconManager *)manager didStartMonitoringForRegion:(__kindof KTKBeaconRegion *)region {
    
}

- (void)beaconManager:(KTKBeaconManager *)manager monitoringDidFailForRegion:(__kindof KTKBeaconRegion *)region withError:(NSError *)error {
    // Handle monitoring failing to start for your region
}

- (void)beaconManager:(KTKBeaconManager *)manager didEnterRegion:(__kindof KTKBeaconRegion *)region {
    // Decide what to do when a user enters a range of your region; usually used
    // for triggering a local notification and/or starting a beacon ranging
    //self.statusText.text = @"enter";
}

- (void)beaconManager:(KTKBeaconManager *)manager didExitRegion:(__kindof KTKBeaconRegion *)region {
    // Decide what to do when a user exits a range of your region; usually used
    // for triggering a local notification and stoping a beacon ranging
    //self.statusText.text = @"exit";
}

- (void)beaconManager:(KTKBeaconManager*)manager didDetermineState:(CLRegionState)state forRegion:(__kindof KTKBeaconRegion*)region {
    
}

- (void)beaconManager:(KTKBeaconManager*)manager didRangeBeacons:(NSArray <CLBeacon *>*)beacons inRegion:(__kindof KTKBeaconRegion*)region {
    
    for(CLBeacon * beacon in beacons) {
        BUSBeacon * busBeacon;
        
        if ([self.beacons objectForKey: [beacon.major stringValue]]) {
            busBeacon = [self.beacons objectForKey: [beacon.major stringValue]];
            
            if (beacon.accuracy >= 0) {
                busBeacon.accuracy = [NSNumber numberWithDouble:beacon.accuracy];
            }

        } else {
            busBeacon = [[BUSBeacon alloc] init];
            busBeacon.id = [beacon.major stringValue];
            busBeacon.accuracy = [NSNumber numberWithDouble:beacon.accuracy];
            
// Sample data for "Spielfeld":
            switch ([beacon.major intValue]) {
                case 42563:
                    busBeacon.neighbours = [[NSMutableDictionary alloc] init];
                    [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:88] forKey: @"21307"];
                    break;
                case 44025:
                    busBeacon.neighbours = [[NSMutableDictionary alloc] init];
                    [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:352] forKey: @"21307"];
                    break;
                case 38605:
                    busBeacon.neighbours = [[NSMutableDictionary alloc] init];
                    [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:242] forKey: @"21307"];
                    break;
                case 21307:
                    busBeacon.neighbours = [[NSMutableDictionary alloc] init];
                    [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:269] forKey: @"42563"];
                    [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:167] forKey: @"44025"];
                    [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:67] forKey: @"38605"];
                    break;
            }
            
// Sample data for "Schlesisches Tor":
//                        switch ([beacon.major intValue]) {
//                            case 42563://8csn
//                                busBeacon.neighbours = [[NSMutableDictionary alloc] init];
//                                [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:26] forKey: @"44025"];
//                                break;
//                            case 44025://xpqe
//                                busBeacon.neighbours = [[NSMutableDictionary alloc] init];
//                                [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:92] forKey: @"21307"];
//                                break;
//                            case 38605://f905
//                                busBeacon.neighbours = [[NSMutableDictionary alloc] init];
//                                [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:279] forKey: @"42563"];
//                                break;
//                            case 21307://0jnw
//                                busBeacon.neighbours = [[NSMutableDictionary alloc] init];
////                                [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:67] forKey: @"42563"];
//                                break;
//                        }

            [self.beacons setObject:busBeacon forKey: [beacon.major stringValue]];

        }
    }
    [self calculateNewDirection];
    
}

- (void) printDebugInfo {
    self.debugLabelLeft.text = currentBeacon.id;
    NSString * values = @"";
    for (NSString *beaconID in path) {
        BUSBeacon * beacon = [self.beacons objectForKey:beaconID];
        values = [values stringByAppendingString:[NSString stringWithFormat:@"%@|", beacon.id]];
    }
    self.debugLabelRight.text = values;
    self.debugLabelLeft.hidden = NO;
    self.debugLabelRight.hidden = NO;
    
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
