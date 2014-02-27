//
//  BeaconBroadcastAgent.h
//  HBeacon
//
//  Created by Duyen Hoa Ha on 21/02/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
@import CoreBluetooth;

@interface BeaconBroadcastAgent : NSObject <
//CLLocationManagerDelegate,
CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager *myBTManager;
//@property (nonatomic) CLLocationManager *locationManager;

+(BeaconBroadcastAgent*)shareBBA;

-(void)enableBroadcast:(BOOL)value;


@end
