//
//  BUSBeacon.h
//  BUStedDebug
//
//  Created by Lukas Heilmann on 03/12/2016.
//  Copyright © 2016 Lukas Fritzsche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BUSBeacon : NSObject

@property NSNumber * accuracy;

// Not necessary
@property NSString * id;

// ID of neighbour as NSString --> direction of neighbour as NSNumber
@property NSMutableDictionary * neighbours;

@end
