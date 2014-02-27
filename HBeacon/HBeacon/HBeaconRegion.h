//
//  HBeacon.h
//  HBeacon
//
//  Created by Duyen Hoa Ha on 21/02/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CLBeaconRegion.h>
@interface HBeaconRegion : NSObject

@property (nonatomic) NSArray *beaconsInRegion;
@property (nonatomic, strong) CLBeaconRegion *beaconReagion;

-(CLBeacon*)getNearestBeacon;

@end
