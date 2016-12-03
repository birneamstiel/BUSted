//
//  ViewController.m
//  BUStedDebug
//
//  Created by Lukas on 03/12/16.
//  Copyright © 2016 Lukas Fritzsche. All rights reserved.
//

#import "ViewController.h"
#import <KontaktSDK/KontaktSDK.h>
#import "BUSBeacon.h"
#include <math.h>
#include <CoreLocation/CoreLocation.h>

#define BEACON_18CSN_MAJOR 42563
#define BEACON_18CSN_MINOR 20278

#define BEACON_XPQE_MAJOR 44025
#define BEACON_XPQE_MINOR 64030

#define BEACON_0JNW_MAJOR 21307
#define BEACON_0JNW_MINOR 26964

#define BEACON_F905_MAJOR 38605
#define BEACON_F905_MINOR 63779

@interface ViewController () <KTKBeaconManagerDelegate, CLLocationManagerDelegate>

@property KTKBeaconManager *beaconManager;

// ID of BUSBeacon as NSString --> BUSBeacon
@property NSMutableDictionary *beacons;


@end

@implementation ViewController {
    CLLocationManager *locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.beacons = [[NSMutableDictionary alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    //self.statusText.delegate = self;
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
        self.compassLabel.text = [NSString stringWithFormat: @"%.03f°", theHeading];
    }
    
    return;
}

- (void)textViewDidChange:(UITextView *)textView
{
    
    
}

- (IBAction)ButtonPressed:(id)sender {
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
            busBeacon.accuracy = [NSNumber numberWithDouble:beacon.accuracy];
        } else {
            busBeacon = [[BUSBeacon alloc] init];
            busBeacon.id = [beacon.major stringValue];
            busBeacon.accuracy = [NSNumber numberWithDouble:beacon.accuracy];
            
            // Add neighbours
            switch ([beacon.major intValue]) {
                case 42563:
                    busBeacon.neighbours = [[NSMutableDictionary alloc] init];
                    [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:242] forKey: @"21307"];
                case 44025:
                    busBeacon.neighbours = [[NSMutableDictionary alloc] init];
                    [busBeacon.neighbours setObject: [[NSNumber alloc] initWithInt:88] forKey: @"21307"];
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
            
            [self.beacons setObject:busBeacon forKey: [beacon.major stringValue]];
        }
        
        switch ([busBeacon.id intValue]) {
            case 42563:
                // Debug
                self.beaconText1.text = [[NSString stringWithFormat:@"%.02f \n", [busBeacon.accuracy doubleValue]] stringByAppendingString: self.beaconText1.text ];
                break;
            case 44025:
                //Debug
                self.beaconText2.text = [[NSString stringWithFormat:@"%.02f \n", [busBeacon.accuracy doubleValue]] stringByAppendingString: self.beaconText2.text];
                break;
            case 21307:
                //Debug
                self.beaconText3.text = [[NSString stringWithFormat:@"%.02f \n", [busBeacon.accuracy doubleValue]] stringByAppendingString: self.beaconText3.text];
                break;
            case 38605:
                //Debug
                self.beaconText4.text = [[NSString stringWithFormat:@"%.02f \n", [busBeacon.accuracy doubleValue]] stringByAppendingString: self.beaconText4.text];
                break;
        }
    }
    
}

- (double) calculateAccuracyWithRssI:(double) rssi {
    if (rssi == 0) {
        return -1.0; // if we cannot determine accuracy, return -1.
    }
    
    double ratio = rssi*1.0/3;
    if (ratio < 1.0) {
        return pow(ratio,10);
    }
    else {
        double accuracy =  (0.89976) * pow(ratio,7.7095) + 0.111;
        return accuracy;
    }
}

@end
