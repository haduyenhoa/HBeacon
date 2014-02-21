//
//  BeaconAgent.h
//  HBeacon
//
//  Created by Duyen Hoa Ha on 21/02/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;
@import CoreBluetooth;

@protocol BeaconAgentDelegate <NSObject>

-(void)newMessage:(NSString*)msg;

-(void)beaconsUpdated;

@end

@interface BeaconAgent : NSObject <CLLocationManagerDelegate,CBPeripheralManagerDelegate>

+(BeaconAgent*) shareBA;

@property (nonatomic) id<BeaconAgentDelegate> delegate;
@property (nonatomic) CBPeripheralManager *myBTManager;
@property (nonatomic) CLLocationManager *locationManager;

-(NSArray*)getListBeaconInRange;
-(NSArray*)getLastVisitedBeacons;


-(void)enableBroadcast:(BOOL)value;
-(void)enableReceiver:(BOOL)value;


@end
