//
//  BeaconBroadcastAgent.m
//  HBeacon
//
//  Created by Duyen Hoa Ha on 21/02/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

#import "BeaconBroadcastAgent.h"

static BeaconBroadcastAgent *_shareBBA = nil;

@implementation BeaconBroadcastAgent {
    BOOL canBroadcast;
    BOOL isBroadcasting;
    
    //for broadcasting
    CLBeaconRegion *_broadcastBeacon;
    NSMutableDictionary *_broadcastBeaconDict;

}

+(BeaconBroadcastAgent*)shareBBA {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareBBA = [[BeaconBroadcastAgent alloc] init];
    });
    return _shareBBA;
}

-(id)init {
    self = [super init];
    if (self) {
        [self createBroadcastBeacon];
//        [self createLocationManager];
        [self createCBPeripheralManager];
    }
    return self;
}

#pragma mark Beacon
-(NSString*)generateUUID {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

-(void)createBroadcastBeacon {
    NSLog(@"%s",__FUNCTION__);
    if (_broadcastBeacon) {
        NSLog(@"broadcast beacon has already be created");
        return;
    } else {
        NSString *broadCastUUID = @"A77A1B68-49A7-4DBF-914C-760D07FBB87B";
        int broadCastMajor = 1;
        
        
        int broadcastIdx = 1;
        
        if (broadcastIdx == 1) {
            broadCastUUID = @"A77A1B68-49A7-4DBF-914C-760D07FBB87B";
            _broadcastBeacon = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:broadCastUUID] major:broadCastMajor minor:1 identifier:@"com.hbeacon.test1"];
        } else if (broadcastIdx == 2) {
            broadCastUUID = @"054fe7b1-a48f-41ae-8b92-0c151863236c";
            _broadcastBeacon = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:broadCastUUID] major:broadCastMajor minor:2 identifier:@"com.hbeacon.test2"];
        }
    }
}

/*
-(void)createLocationManager {
    NSLog(@"%s",__FUNCTION__);
    if (self.locationManager) {
        NSLog(@"location has already be created");
        return;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}
 */

-(void)createCBPeripheralManager {
    NSLog(@"%s",__FUNCTION__);
    if (self.myBTManager) {
        NSLog(@"BT Peripheral has already be created");
        return;
    }
    
    if (_broadcastBeacon == nil) {
        [self createBroadcastBeacon];
    }
    
    _broadcastBeaconDict = [_broadcastBeacon peripheralDataWithMeasuredPower:nil];
    NSLog(@"%@",_broadcastBeaconDict);
}
#pragma -

-(void)enableBroadcast:(BOOL)value {
    if (value) {
        if (self.myBTManager) {
            self.myBTManager.delegate = self;
            if (self.myBTManager.state == CBPeripheralManagerStatePoweredOn) {
                NSLog(@"Re-broadcasting now");
                [self.myBTManager startAdvertising:_broadcastBeaconDict];
            } else {
                NSLog(@"Cannot re-broadcasting");
            }
            return;
        }
        
        NSLog(@"enable broadcast");
        
        //start broadcasting
        self.myBTManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
        
    } else {
        NSLog(@"disable broadcast");
        if (self.myBTManager) {
            [self.myBTManager stopAdvertising];
            self.myBTManager.delegate = nil;
        }
    }
}

//
//-(void)enableBroadcast:(BOOL)value {
//    if (value) {
//        if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
//            NSLog(@"Cannot broadcast");
//            canBroadcast = NO;
//            return;
//        }
//        
//        self.locationManager.delegate = self;
//        NSLog(@"try to broadcast");
//        canBroadcast = YES;
//        [self.locationManager startMonitoringForRegion:_broadcastBeacon];
//        isBroadcasting = YES;
//        
//    } else {
//        NSLog(@"stop broadcast");
//        [self.locationManager stopMonitoringForRegion:_broadcastBeacon];
//        isBroadcasting = NO;
//    }
//}



#pragma mark BTmanager
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral
{
    NSLog(@"%s",__FUNCTION__);
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        // Bluetooth is on
        NSLog(@"Broadcasting...");
        
        // Start broadcasting
        [self.myBTManager startAdvertising:_broadcastBeaconDict];
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff)
    {
        // Update our status label
        NSLog(@"Stopped");
        
        // Bluetooth isn't on. Stop broadcasting
        [self.myBTManager stopAdvertising];
    }
    else if (peripheral.state == CBPeripheralManagerStateUnsupported)
    {
        NSLog(@"Unsupported");
    }
}
#pragma -

/*
#pragma mark Monitor - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"manager: %@",manager);
    NSLog(@"region: %@",region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"%s",__FUNCTION__);
    if (![CLLocationManager locationServicesEnabled]) {
        if (canBroadcast) {
            NSLog(@"Cannot broadcast signal. Location services are not enabled");
        }
        isBroadcasting = NO;
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        if (canBroadcast) {
            NSLog(@"Cannot broadcast signal. Location services are not enabled");
        }
        isBroadcasting = NO;
        return;
    }
    
    if (canBroadcast) {
        isBroadcasting = YES;
        NSLog(@"Broadcasting...");
    }
}
#pragma -
 */

@end
