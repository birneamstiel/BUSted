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


#define BEACON_18CSN_MAJOR 42563
#define BEACON_18CSN_MINOR 20278

#define BEACON_XPQE_MAJOR 44025
#define BEACON_XPQE_MINOR 64030

#define BEACON_0JNW_MAJOR 21307
#define BEACON_0JNW_MINOR 26964

#define BEACON_F905_MAJOR 38605
#define BEACON_F905_MINOR 63779

#define APPROXIMITY_THRESHOLD 1.5
#define PATH_ARRAY [NSMutableArray arrayWithObjects:@"42563",@"21307",@"38605",nil]

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
    int counter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.beacons = [[NSMutableDictionary alloc] init];
    
    [self.view setBackgroundColor:UIColorFromRGB(0x393939)];
    
    // init
    path = PATH_ARRAY;
    finished = false;
    counter = 1;
    
    [self setupArrowView];
    [self setupBeacons];
    
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
    KTKBeaconRegion *region8CSN = [[KTKBeaconRegion alloc] initWithProximityUUID:myProximityUUID major:BEACON_18CSN_MAJOR minor:BEACON_18CSN_MINOR identifier:@"BUSted beacon reagion1"];
    KTKBeaconRegion *regionXpQe = [[KTKBeaconRegion alloc] initWithProximityUUID:myProximityUUID major:BEACON_XPQE_MAJOR minor:BEACON_XPQE_MINOR identifier:@"BUSted beacon reagion2"];
    KTKBeaconRegion *region0jnw = [[KTKBeaconRegion alloc] initWithProximityUUID:myProximityUUID major:BEACON_0JNW_MAJOR minor:BEACON_0JNW_MINOR identifier:@"BUSted beacon reagion3"];
    KTKBeaconRegion *regionf905 = [[KTKBeaconRegion alloc] initWithProximityUUID:myProximityUUID major:BEACON_F905_MAJOR minor:BEACON_F905_MINOR identifier:@"BUSted beacon reagion4"];
    
    switch ([KTKBeaconManager locationAuthorizationStatus]) {
            // Non-relevant cases are cut
        case kCLAuthorizationStatusAuthorizedAlways:
            if ([KTKBeaconManager isMonitoringAvailable]) {
                [self.beaconManager startMonitoringForRegion:region8CSN];
                [self.beaconManager startRangingBeaconsInRegion:region8CSN];
                
                [self.beaconManager startMonitoringForRegion:regionXpQe];
                [self.beaconManager startRangingBeaconsInRegion:regionXpQe];
                
                [self.beaconManager startMonitoringForRegion:region0jnw];
                [self.beaconManager startRangingBeaconsInRegion:region0jnw];
                
                [self.beaconManager startMonitoringForRegion:regionf905];
                [self.beaconManager startRangingBeaconsInRegion:regionf905];
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
    if (finished) {
        return;
    }
    
    if(!currentBeacon) {
        currentBeacon = [self.beacons objectForKey:[path objectAtIndex:0]];
        [path removeObjectAtIndex:0];
    }
    BUSBeacon *nextBeacon = [self.beacons objectForKey:[path objectAtIndex:0]];

    
    if ([path count] == 1 && [nextBeacon.accuracy doubleValue] < APPROXIMITY_THRESHOLD) {
        finished = true;
        [self reachedDestination];
        
        return;
    }
    
    if (nextBeacon && [path count] > 1 && [nextBeacon.accuracy doubleValue]  - [currentBeacon.accuracy doubleValue] < 0) {
        currentBeacon = [self.beacons objectForKey:[path objectAtIndex:0]];
        [path removeObjectAtIndex:0];
    }
    
    NSNumber *angle = [currentBeacon.neighbours objectForKey:[path objectAtIndex:0]];
    [self.circleView rotateArrowBy: [self translateAngleToOrientation:[angle floatValue]]];
}

- (double) translateAngleToOrientation: (double) value {
    return (int)(value - degree) % 360;
}


- (void) reachedDestination {
    [self.circleView reachedDestination];
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
            
            // Add neighbours
            switch ([beacon.major intValue]) {
                case 42563:
                    busBeacon.neighbours = [[NSMutableDictionary alloc] init];
                    [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:242] forKey: @"21307"];
                    break;
                case 44025:
                    busBeacon.neighbours = [[NSMutableDictionary alloc] init];
                    [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:88] forKey: @"21307"];
                    break;
                case 38605:
                    busBeacon.neighbours = [[NSMutableDictionary alloc] init];
                    [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:352] forKey: @"21307"];
                    break;
                case 21307:
                    busBeacon.neighbours = [[NSMutableDictionary alloc] init];
                    [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:67] forKey: @"42563"];
                    [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:88] forKey: @"44025"];
                    [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:167] forKey: @"38605"];
                    break;
            }
        }
        
        [self.beacons setObject:busBeacon forKey: [beacon.major stringValue]];
        
        //only call every 4 ticks
        [self calculateNewDirection];

    }
    
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
