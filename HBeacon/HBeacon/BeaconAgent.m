//
//  BeaconAgent.m
//  HBeacon
//
//  Created by Duyen Hoa Ha on 21/02/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

#import "BeaconAgent.h"

#import "HBeacon.h"

static BeaconAgent *_shareBA = nil;
@implementation BeaconAgent {
    BOOL canBroadcast;
    BOOL canReceive;
    
    BOOL isBroadcasting;
    BOOL isReceiving;
    
    //for broadcasting
    CLBeaconRegion *_broadcastBeacon;
    NSMutableDictionary *_broadcastBeaconDict;
    
    //all beacon to advertising & ranging
    NSMutableDictionary *dictBeaconToReceive;
    
    NSMutableSet *_listBeaconInRange;
    NSMutableSet *_listBeaconLastVisited;
}

+(BeaconAgent*) shareBA {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareBA = [[BeaconAgent alloc] init];
    });
    return _shareBA;
}

-(id) init {
    self = [super init];
    if (self) {
        //Custom init here
        _listBeaconInRange = [[NSMutableSet alloc] init];
        _listBeaconLastVisited = [[NSMutableSet alloc] init];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.myBTManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
        
        dictBeaconToReceive = [[NSMutableDictionary alloc] init];
        
//        _broadcastBeacon = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:[self generateUUID]] major:1 minor:1 identifier:@"broadcastIdentifier"];
//        _broadcastBeaconDict = [_broadcastBeacon peripheralDataWithMeasuredPower:nil];
    }
    
    return self;
}

-(void)enableBroadcast:(BOOL)value {
    if (value) {
        if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(newMessage:)]) {
                [self.delegate newMessage:@"Cannot monitoring other beacons !!!"];
            }
            canBroadcast = NO;
            return;
        }

        self.locationManager.delegate = self;
        [self.locationManager startMonitoringForRegion:_broadcastBeacon];
        isBroadcasting = YES;
    } else {
        [self.locationManager stopMonitoringForRegion:_broadcastBeacon];
        
        isBroadcasting = NO;
    }
}
-(void)enableReceiver:(BOOL)value {
    if (value) {
        if (self.myBTManager.state == CBCentralManagerStatePoweredOn && !self.myBTManager.isAdvertising) {
            [self.myBTManager startAdvertising:_broadcastBeaconDict];
            isBroadcasting = YES;
        }
    } else {
        [self.myBTManager stopAdvertising];
        isBroadcasting = NO;
    }
}

#pragma mark Monitor - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"manager: %@",manager);
    NSLog(@"region: %@",region.identifier);
}


-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    //    NSLog(@"%s",__FUNCTION__);
    //    NSLog(@"manager: %@",manager);
    //    NSLog(@"beacon in range: %d",beacons.count);
    //    NSLog(@"region %@", region == self.myRegion ? @"ME" : region.identifier);
    
    for (CLBeacon *foundBeacon in beacons) {
        // You can retrieve the beacon data from its properties
        NSString *uuid = foundBeacon.proximityUUID.UUIDString;
        NSString *major = [NSString stringWithFormat:@"%@", foundBeacon.major];
        NSString *minor = [NSString stringWithFormat:@"%@", foundBeacon.minor];
        NSString *accuracy = [NSString stringWithFormat:@"%f", foundBeacon.accuracy];
        NSString *rssi = [NSString stringWithFormat:@"%ld", (long)foundBeacon.rssi];
        NSString *identifier = @"unknown";
        CLBeaconRegion *aBeaconRegion = (CLBeaconRegion*)region;
        if (aBeaconRegion && aBeaconRegion.identifier) {
            identifier = aBeaconRegion.identifier;
        }
        
        //    self.statusLabel.text = [NSString stringWithFormat:@"%@ - %@:%@ - %@",uuid, major, minor, proximity];
        NSLog(@"%@ - %@ - %@ - %@ - %@ - %@", identifier, major, minor, accuracy, rssi, uuid);
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"%s",__FUNCTION__);
    if (![CLLocationManager locationServicesEnabled]) {
        if (canBroadcast) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(newMessage:)]) {
                [self.delegate newMessage:@"Cannot broadcast signal. Location services are not enabled"];
            }
        }
        
        if (canReceive) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(newMessage:)]) {
                [self.delegate newMessage:@"Cannot search for beacon. Location services are not enabled"];
            }
        }
        
        _listBeaconInRange = nil;
        
        //notify beacon updated
        if (self.delegate && [self.delegate respondsToSelector:@selector(beaconsUpdated)]) {
            [self.delegate beaconsUpdated];
        }
        
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        if (canBroadcast) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(newMessage:)]) {
                [self.delegate newMessage:@"Cannot broadcast signal. Location services are not enabled"];
            }
        }
        
        if (canReceive) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(newMessage:)]) {
                [self.delegate newMessage:@"Cannot search for beacon. Location services are not enabled"];
            }
        }
        
        _listBeaconInRange = nil;
        
        //notify beacon updated
        if (self.delegate && [self.delegate respondsToSelector:@selector(beaconsUpdated)]) {
            [self.delegate beaconsUpdated];
        }
        
        return;
    }
    
    if (canBroadcast) {
        isBroadcasting = YES;
    }
    
    if (canReceive) {
        isReceiving = YES;
    }
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Entered region: %@", region);
    
    [self sendLocalNotificationForBeaconRegion:(CLBeaconRegion *)region];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"%s",__FUNCTION__);
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSLog(@"%s",__FUNCTION__);
    NSString *stateString = nil;
    CLBeaconRegion *bReagion = (CLBeaconRegion*)region;
    
    HBeacon *concernedHBeacon = [self searchBeacon:bReagion.identifier withMajor:bReagion.major andMinor:bReagion.minor];

    switch (state) {
        case CLRegionStateInside:
        {
            if (canReceive) {
                //rang this one
                [self startRanging:bReagion];
            }
            
            //add to list beacon in range if not the case
            if (concernedHBeacon == nil) {
                concernedHBeacon = [[HBeacon alloc] init];
                concernedHBeacon.beaconReagion = bReagion;
                
                [_listBeaconInRange addObject:concernedHBeacon];
                [_listBeaconLastVisited addObject:concernedHBeacon];
            }
        }
            break;
        case CLRegionStateOutside:
        {
            [self stopRanging:bReagion];
            
            //move to last beacon in range
            if (concernedHBeacon != nil) {
                [_listBeaconInRange removeObject:concernedHBeacon];
            }
        }
            break;
        case CLRegionStateUnknown:
            stateString = @"unknown";
            break;
    }
    NSLog(@"State changed to %@ for region %@.", stateString, region);
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%s: error: %@",__FUNCTION__, error.localizedDescription);
    [self doesNotRecognizeSelector:_cmd];
}

-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"%s: error: %@",__FUNCTION__,error.localizedDescription);
    [self doesNotRecognizeSelector:_cmd];
}

-(void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"%s: error: %@",__FUNCTION__,error.localizedDescription);
    [self doesNotRecognizeSelector:_cmd];
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"%s",__FUNCTION__);
    [self doesNotRecognizeSelector:_cmd];
}
-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"%s",__FUNCTION__);
    [self doesNotRecognizeSelector:_cmd];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"%s",__FUNCTION__);
    [self doesNotRecognizeSelector:_cmd];
    
}
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    NSLog(@"%s",__FUNCTION__);
    [self doesNotRecognizeSelector:_cmd];
}
#pragma -

#pragma mark Range (diffuser)
-(void)startRanging:(CLBeaconRegion*)region {
    NSLog(@"%s",__FUNCTION__);
    [self createLocationManager];
    
    if (![CLLocationManager isRangingAvailable]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lblMessage.text = @"Cannot start transmiter signal. Ranging is not available !!!";
        });
        return;
    }
    
    [self createBeacon]; //create beacon if need
    
    [self.locationManager startRangingBeaconsInRegion:region];
}

-(void)stopRanging:(CLBeaconRegion*)region {
    [self.locationManager stopRangingBeaconsInRegion:region];
    
    NSLog(@"Turned off ranging.");
}
#pragma -

#pragma mark BTmanager
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral
{
    NSLog(@"%s",__FUNCTION__);
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        // Bluetooth is on
        
        // Update our status label
        self.lblMessage.text = @"Broadcasting...";
        
        // Start broadcasting
        [self.myBTManager startAdvertising:self.myBTData1];
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff)
    {
        // Update our status label
        self.lblMessage.text = @"Stopped";
        
        // Bluetooth isn't on. Stop broadcasting
        [self.myBTManager stopAdvertising];
    }
    else if (peripheral.state == CBPeripheralManagerStateUnsupported)
    {
        self.lblMessage.text = @"Unsupported";
    }
}

- (void)sendLocalNotificationForBeaconRegion:(CLBeaconRegion *)region
{
    UILocalNotification *notification = [UILocalNotification new];
    
    // Notification details
    notification.alertBody = [NSString stringWithFormat:@"Entered beacon region for identifier: %@",
                              region.identifier];   // Major and minor are not available at the monitoring stage
    notification.alertAction = NSLocalizedString(@"View Details", nil);
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}
#pragma -

#pragma mark broadcasting
-(void)startBroadcasting  {
    NSLog(@"%s",__FUNCTION__);
    //start BT
    [self createCBPeripheralManager];
    
    if (self.myBTManager.state == CBCentralManagerStatePoweredOn && !self.myBTManager.isAdvertising) {
        NSLog(@"start broadcast now");
        [self.myBTManager startAdvertising:self.myBTData1];
    }
}

-(void)stopBroadcasting {
    NSLog(@"%s",__FUNCTION__);
    [self.myBTManager stopAdvertising];
}

#pragma -

#pragma mark Monitors
-(void)startMonitor {
    NSLog(@"%s",__FUNCTION__);
    //empty list beacon
    [_listBeaconsInRange removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tblBeaconsInRange reloadData];
    });
    
    [self createLocationManager];
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lblMessage.text = @"Cannot monitoring other beacons !!!";
        });
        return;
    }
    
    [self createBeacon];
    
    [self.locationManager startMonitoringForRegion:self.myRegion1];
    [self.locationManager startMonitoringForRegion:self.myRegion2];
}

-(void)stopMonitor {
    NSLog(@"%s",__FUNCTION__);
    [self.locationManager stopMonitoringForRegion:self.myRegion1];
    [self.locationManager stopMonitoringForRegion:self.myRegion2];
}

#pragma -

#pragma mark Beacon
-(NSString*)generateUUID {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

-(void)createBeacon {
    NSLog(@"%s",__FUNCTION__);
    if (self.myRegion1) {
        NSLog(@"beacon 1 has already be created");
        
    } else {
        self.myRegion1 = [[CLBeaconRegion alloc] initWithProximityUUID:self.uuid1 major:self.major1 minor:self.minor1 identifier:self.identifier1];
        self.myRegion1.notifyEntryStateOnDisplay = YES;
    }
    
    if (self.myRegion2) {
        NSLog(@"beacon 2 has already be created");
        
    } else {
        self.myRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:self.uuid2 major:self.major2 minor:self.minor2 identifier:self.identifier2];
        self.myRegion2.notifyEntryStateOnDisplay = YES;
    }
    
    
    
    
    //    self.myRegion.notifyOnEntry = YES; //not notify when enter
    //    self.myRegion.notifyOnExit = NO; //not notify when exit
}

-(void)createLocationManager {
    NSLog(@"%s",__FUNCTION__);
    if (self.locationManager) {
        NSLog(@"location has already be created");
        return;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}

-(void)createCBPeripheralManager {
    NSLog(@"%s",__FUNCTION__);
    if (self.myBTManager) {
        NSLog(@"BT Peripheral has already be created");
        return;
    }
    
    self.myBTData1 = [self.myRegion2 peripheralDataWithMeasuredPower:nil];
    
    self.myBTManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
}
#pragma -


#pragma mark Beacon Manager
-(HBeacon*)searchBeacon:(NSString*)identifier withMajor:(NSNumber*)beaconMajor andMinor:(NSNumber*)beaconMinor {
    for (HBeacon *aBeacon in _listBeaconInRange) {
        if ([aBeacon.beaconReagion.identifier isEqualToString:identifier]
            && aBeacon.beaconReagion.major.intValue == beaconMajor.intValue
            && aBeacon.beaconReagion.minor.intValue = beaconMinor.intValue
            ) {
            return aBeacon;
        }
    }
    
    return nil;
}
#pragma -
@end
