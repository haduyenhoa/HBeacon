//
//  HBeacon.m
//  HBeacon
//
//  Created by Duyen Hoa Ha on 21/02/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

#import "HBeaconRegion.h"

@implementation HBeaconRegion

-(CLBeacon*)getNearestBeacon {
    CLBeacon *nearestBeacon = nil;
    if (self.beaconsInRegion && self.beaconsInRegion.count > 0) {
        NSMutableArray *immediateBeacons = [[NSMutableArray alloc] init];
        NSMutableArray *nearBeacons = [[NSMutableArray alloc] init];
        NSMutableArray *farBeacons = [[NSMutableArray alloc] init];
        
        for (CLBeacon *foundBeacon in self.beaconsInRegion) {
            if (foundBeacon.proximity == CLProximityImmediate) {
                [immediateBeacons addObject:foundBeacon];
            } else if (foundBeacon.proximity == CLProximityNear) {
                [nearBeacons addObject:foundBeacon];
            } else if (foundBeacon.proximity == CLProximityFar) {
                [farBeacons addObject:foundBeacon];
            }
        }
        
        for (CLBeacon *aBeacon in immediateBeacons) {
            if (nearestBeacon == nil) {
                nearestBeacon = aBeacon;
            } else if (aBeacon.accuracy < nearestBeacon.accuracy) {
                nearestBeacon = aBeacon;
            }
        }
        
        if (nearestBeacon == nil) {
            for (CLBeacon *aBeacon in nearBeacons) {
                if (nearestBeacon == nil) {
                    nearestBeacon = aBeacon;
                } else if (aBeacon.accuracy < nearestBeacon.accuracy) {
                    nearestBeacon = aBeacon;
                }
            }
            
            if (nearestBeacon == nil) {
                for (CLBeacon *aBeacon in farBeacons) {
                    if (nearestBeacon == nil) {
                        nearestBeacon = aBeacon;
                    } else if (aBeacon.accuracy < nearestBeacon.accuracy) {
                        nearestBeacon = aBeacon;
                    }
                }
                
                if (nearestBeacon) {
                    NSLog(@"found nearest beacon in far list");
                }
            } else {
                NSLog(@"found nearest beacon in near list");
            }
        } else {
            NSLog(@"found nearest beacon in immediate list");
        }
    } else {
        return nil;
    }
    
    if (nearestBeacon == nil) {
        NSLog(@"take first beacon in list");
        nearestBeacon = [self.beaconsInRegion firstObject];
    }
    
    return nearestBeacon;
}
@end
