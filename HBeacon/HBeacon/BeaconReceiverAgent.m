//
//  BeaconAgent.m
//  HBeacon
//
//  Created by Duyen Hoa Ha on 21/02/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

#import "BeaconReceiverAgent.h"

#import "HBeaconRegion.h"

static BeaconReceiverAgent *_shareBA = nil;
@implementation BeaconReceiverAgent {
    
    BOOL canReceive;
    BOOL isReceiving;
    
    //all beacon to advertising & ranging
    NSMutableDictionary *dictBeaconToReceive;
    
    NSMutableSet *_listBeaconInRange;
    NSMutableSet *_listBeaconLastVisited;
}

+(BeaconReceiverAgent*) shareBA {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareBA = [[BeaconReceiverAgent alloc] init];
    });
    return _shareBA;
}

-(id) init {
    self = [super init];
    if (self) {
        //Custom init here
        _listBeaconInRange = [[NSMutableSet alloc] init];
        _listBeaconLastVisited = [[NSMutableSet alloc] init];
        
        dictBeaconToReceive = [[NSMutableDictionary alloc] init];
        
        [self initBeaconDict]; //dict contains all beacon that this receiver can monitoring (searching)
    }
    
    
    
    return self;
}



-(void)enableReceiver:(BOOL)value {
        [self createLocationManager];
    if (value) {
        // Check if beacon monitoring is available for this device
        if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
            NSLog(@"Monitoring is not available for this device");
            canReceive = NO;
            isReceiving = NO;
            return;
        }
        
        canReceive = YES;
        
        NSLog(@"enable receiver");
        
        // Tell location manager to start monitoring for all beacon region
        for (CLBeaconRegion *aReagion in dictBeaconToReceive.allValues) {
            [self.locationManager startMonitoringForRegion:aReagion];
            [self.locationManager startRangingBeaconsInRegion:aReagion];
        }
        
        
        [self.delegate newMessage:@"Searching for beacon region..."];
    } else {
        NSLog(@"disable receiver");
        // Tell location manager to stop monitoring for all beacon region
        for (CLBeaconRegion *aReagion in dictBeaconToReceive.allValues) {
            [self.locationManager stopRangingBeaconsInRegion:aReagion];
            [self.locationManager stopMonitoringForRegion:aReagion];            
        }
        
        [self.delegate newMessage:@"Receiver disabled"];
    }
}

-(NSArray*)getListBeaconInRange {
    return _listBeaconInRange.allObjects;
}
-(NSArray*)getLastVisitedBeacons  {
    return _listBeaconLastVisited.allObjects;
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
//    NSLog(@"beacon in range: %lu",(unsigned long)beacons.count);
//    NSLog(@"region: %@", region.identifier);
    
    @synchronized(self) {
        HBeaconRegion *foundRegion = [self searchBeaconRegion:region.identifier withMajor:region.major andMinor:region.minor];
        if (foundRegion == nil) {
            NSLog(@"Warning: this region must be tracked before??");
            foundRegion = [[HBeaconRegion alloc] init];
            foundRegion.beaconReagion = region;
            [_listBeaconInRange addObject:foundRegion];
        } else {
            foundRegion.beaconsInRegion = beacons; //update
        }
        
        if (beacons == nil || beacons.count == 0) {
            [_listBeaconInRange removeObject:foundRegion];
        }
    }
    
    //notify beacon updated
    if (self.delegate && [self.delegate respondsToSelector:@selector(beaconsUpdated)]) {
        [self.delegate beaconsUpdated];
    }
//    if (nearestBeacon) {
//        // You can retrieve the beacon data from its properties
//        NSString *uuid = nearestBeacon.proximityUUID.UUIDString;
//        NSString *major = [NSString stringWithFormat:@"%@", nearestBeacon.major];
//        NSString *minor = [NSString stringWithFormat:@"%@", nearestBeacon.minor];
//        NSString *accuracy = [NSString stringWithFormat:@"%0.2f", nearestBeacon.accuracy];
//        NSString *rssi = [NSString stringWithFormat:@"%ld", (long)nearestBeacon.rssi];
//        NSString *identifier = region.identifier;
//        
//        NSLog(@"%@ - %@ - %@ - %@ m - %@ - %@", identifier, major, minor, accuracy, rssi, uuid);
//    }
}

//check if we can monitoring or not
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"%s",__FUNCTION__);
    if (![CLLocationManager locationServicesEnabled]) {
        if (canReceive) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(newMessage:)]) {
                [self.delegate newMessage:@"Cannot search for beacon. Location services are not enabled"];
            }
        }
        
        [_listBeaconInRange removeAllObjects];
        
        //notify beacon updated
        if (self.delegate && [self.delegate respondsToSelector:@selector(beaconsUpdated)]) {
            [self.delegate beaconsUpdated];
        }
        
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        if (canReceive) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(newMessage:)]) {
                [self.delegate newMessage:@"Cannot search for beacon. Location services are not authorized"];
            }
        }
        
        [_listBeaconInRange removeAllObjects];
        
        //notify beacon updated
        if (self.delegate && [self.delegate respondsToSelector:@selector(beaconsUpdated)]) {
            [self.delegate beaconsUpdated];
        }
        
        return;
    }
    
    if (canReceive) {
        [self.delegate newMessage:@"Searching for beacon region..."];
        isReceiving = YES;
    }
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Entered region: %@", region);
    
    if (canReceive) {
        //start ranging it
        CLBeaconRegion *regionEntered = [dictBeaconToReceive objectForKey:((CLBeaconRegion*)region).proximityUUID.UUIDString];
        if (regionEntered) {
            [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)regionEntered];
        }
        
        @synchronized(self) {
            HBeaconRegion *foundBeacon = [self searchBeaconRegion:regionEntered.identifier withMajor:regionEntered.major andMinor:regionEntered.minor];
            
            if (foundBeacon == nil) {
                foundBeacon = [[HBeaconRegion alloc] init];
                foundBeacon.beaconReagion = regionEntered;
                [_listBeaconInRange addObject:foundBeacon];
            }
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(beaconsUpdated)]) {
            [self.delegate beaconsUpdated];
        }

    }
    
    
    [self sendLocalNotificationForBeaconRegion:(CLBeaconRegion *)region];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"%s",__FUNCTION__);
    if (canReceive) {
        [self removeBeaconRegion:region];
        
        [self sendExitLocalNotificationForBeaconRegion:(CLBeaconRegion *)region];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(beaconsUpdated)]) {
        [self.delegate beaconsUpdated];
    }
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSLog(@"%s",__FUNCTION__);
    NSString *stateString = nil;

    CLBeaconRegion *concernedRegion = (CLBeaconRegion*)region;
    
    switch (state) {
        case CLRegionStateInside:
        {
            //rang this one
            [self.locationManager startRangingBeaconsInRegion:concernedRegion];
            stateString = @"inside";
        }
            break;
        case CLRegionStateOutside:
        {
            //stop ranging
            [self.locationManager stopRangingBeaconsInRegion:concernedRegion];
            stateString = @"outside";
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
    //remove from beacon
    [self removeBeaconRegion:region];
    
    //then update
    if (self.delegate && [self.delegate respondsToSelector:@selector(beaconsUpdated)]) {
        [self.delegate beaconsUpdated];
    }
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

- (void)sendLocalNotificationForBeaconRegion:(CLBeaconRegion *)region
{
    UILocalNotification *notification = [UILocalNotification new];
    
    // Notification details
    notification.alertBody = [NSString stringWithFormat:@"Welcome to: %@",
                              region.identifier];   // Major and minor are not available at the monitoring stage
    notification.alertAction = NSLocalizedString(@"View Details", nil);
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)sendExitLocalNotificationForBeaconRegion:(CLBeaconRegion *)region
{
    UILocalNotification *notification = [UILocalNotification new];
    
    // Notification details
    notification.alertBody = [NSString stringWithFormat:@"Bye. See you again in %@",
                              region.identifier];   // Major and minor are not available at the monitoring stage
    notification.alertAction = NSLocalizedString(@"View Details", nil);
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}
#pragma -


#pragma mark Beacon
-(NSString*)generateUUID {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

-(void)initBeaconDict {
    if (dictBeaconToReceive != nil && dictBeaconToReceive.allKeys.count == 2) {
        NSLog(@"dict beacon to receive is created");
        return;
    }
    
    NSString *broadCastUUID1 = @"A77A1B68-49A7-4DBF-914C-760D07FBB87B";
    CLBeaconRegion *myBeaconRegion1 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:broadCastUUID1] identifier:@"com.hbeacon.test1"];
    myBeaconRegion1.notifyEntryStateOnDisplay = YES;

    NSString *broadCastUUID2 = @"054fe7b1-a48f-41ae-8b92-0c151863236c";
    CLBeaconRegion *myBeaconRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:broadCastUUID2] identifier:@"com.hbeacon.test2"];
    myBeaconRegion2.notifyEntryStateOnDisplay = YES;
    
    //add to dict
    dictBeaconToReceive = [[NSMutableDictionary alloc] init];
    [dictBeaconToReceive setObject:myBeaconRegion1 forKey:broadCastUUID1];
//    [dictBeaconToReceive setObject:myBeaconRegion2 forKey:broadCastUUID2];
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

#pragma -


#pragma mark Beacon Manager
-(void)removeBeaconRegion:(CLRegion*)region {
    //stop ranging
    CLBeaconRegion *regionExited = [dictBeaconToReceive objectForKey:((CLBeaconRegion*)region).proximityUUID.UUIDString];
    if (regionExited) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)regionExited];
    }
    
    @synchronized(self) {
        HBeaconRegion *foundBeacon = [self searchBeaconRegion:regionExited.identifier withMajor:regionExited.major andMinor:regionExited.minor];
        
        if (foundBeacon == nil) {
            NSLog(@"this region is already existed");
        } else {
            [_listBeaconInRange removeObject:foundBeacon];
        }
    }
}


-(HBeaconRegion*)searchBeaconRegion:(NSString*)identifier withMajor:(NSNumber*)beaconMajor andMinor:(NSNumber*)beaconMinor {
    
    for (HBeaconRegion *aBeacon in _listBeaconInRange) {
        if ([aBeacon.beaconReagion.identifier isEqualToString:identifier]
            && aBeacon.beaconReagion.major.intValue == beaconMajor.intValue
            && aBeacon.beaconReagion.minor.intValue == beaconMinor.intValue
            ) {
            return aBeacon;
        }
    }
    
    return nil;
}
#pragma -
@end
