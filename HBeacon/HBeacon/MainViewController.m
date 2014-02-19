//
//  FirstViewController.m
//  HBeacon
//
//  Created by Duyen Hoa Ha on 18/02/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

#import "MainViewController.h"


@interface MainViewController () {
    NSMutableArray *_listBeaconsInRange;
}

@property (nonatomic) NSUUID    *deviceUUID;
@property (nonatomic) NSString  *deviceIdentifier;
@property (nonatomic) CLBeaconMajorValue       major;
@property (nonatomic) CLBeaconMinorValue       minor;

@property (nonatomic) NSMutableDictionary *myBTData;

@property (nonatomic) CBPeripheralManager *myBTManager;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLBeaconRegion *myRegion; //a region to manager all beacons in range ! This can be also a Beacon (with proximityUUID & Identifier ????



@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.deviceUUID = [[NSUUID alloc] initWithUUIDString:@"A77A1B68-49A7-4DBF-914C-760D07FBB87E"];
    self.deviceIdentifier = @"aidentifier2";
    self.major = 2;
    self.minor  = 1;
    
    _listBeaconsInRange = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.scMode.selectedSegmentIndex = 1;
    
    [self setMode:[NSNumber numberWithInteger:self.scMode.selectedSegmentIndex]];
}

-(void)setMode:(NSNumber*)mode {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(setMode:) withObject:mode waitUntilDone:NO];
        return;
    }
    
    [UIView animateWithDuration:.5 animations:^{
        if (mode == nil) {
            return;
        } else if  (mode.intValue == 0) { //beacon mode
            [self.tblBeaconsInRange setAlpha:0.0];
            
            //start diffusing && stop monitoring
        } else if (mode.intValue == 1) { //monitor mode
            [self.tblBeaconsInRange setAlpha:1.0];
            
            //start monitoring && remove this as beacon.
        }
    } completion:^(BOOL finished) {
        //continue to process
        if (mode.intValue == 0) {
            [self stopMonitor];
            [self startBroadcasting];
        } else if (mode.intValue == 1) {
            [self stopBroadcasting];
            [self startMonitor];
        }
    }];
}

-(IBAction)segmentIndexChanged:(id)sender {
    [self setMode:[NSNumber numberWithInteger:self.scMode.selectedSegmentIndex]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Beacon
-(NSString*)generateUUID {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

-(void)createBeacon {
    NSLog(@"%s",__FUNCTION__);
    if (self.myRegion) {
        NSLog(@"beacon has already be created");
        return;
    }
    
    self.myRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.deviceUUID major:self.major minor:self.minor identifier:self.deviceIdentifier];
    self.myRegion.notifyEntryStateOnDisplay = YES;
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
    
    self.myBTData = [self.myRegion peripheralDataWithMeasuredPower:nil];
    self.myBTManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
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
    
    [self.locationManager startMonitoringForRegion:self.myRegion];
}

-(void)stopMonitor {
    NSLog(@"%s",__FUNCTION__);
    [self.locationManager stopMonitoringForRegion:self.myRegion];
}

#pragma -

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
        NSString *rssi = [NSString stringWithFormat:@"%d", foundBeacon.rssi];
        NSString *identifier = @"unknown";
        CLBeaconRegion *aBeaconRegion = (CLBeaconRegion*)region;
        if (aBeaconRegion && aBeaconRegion.identifier) {
            identifier = aBeaconRegion.identifier;
        }
        
        //    self.statusLabel.text = [NSString stringWithFormat:@"%@ - %@:%@ - %@",uuid, major, minor, proximity];
        NSLog(@"%@ - %@ - %@ - %@ - %@", identifier, major, minor, accuracy, rssi);
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"%s",__FUNCTION__);
    if (![CLLocationManager locationServicesEnabled]) {
        if (self.scMode.selectedSegmentIndex == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lblMessage.text = @"Cannot transmiter signal. Location services are not enabled";
            });
 
            return;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lblMessage.text = @"Cannot search for beacon in reange. Location services are not enabled";
            });
            return;
        }
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        if (self.scMode.selectedSegmentIndex == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lblMessage.text = @"Cannot transmiter signal. Location services are not authorised";
            });
            return;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lblMessage.text = @"Cannot search for beacon in reange. Location services are not authorised";
            });
            return;
        }
    }

    if (self.scMode.selectedSegmentIndex == 0) {
        self.lblMessage.text = @"Transmitting signal...";
    } else {
        self.lblMessage.text = @"Searching for beacons...";
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
    switch (state) {
        case CLRegionStateInside:
        {
            stateString = @"inside";
            [self startRanging];
        }
            break;
        case CLRegionStateOutside:
        {
            stateString = @"outside";
            [self stopRanging];
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
}

-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"%s: error: %@",__FUNCTION__,error.localizedDescription);
}

-(void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"%s: error: %@",__FUNCTION__,error.localizedDescription);
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"%s",__FUNCTION__);
}
-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
        NSLog(@"%s",__FUNCTION__);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
        NSLog(@"%s",__FUNCTION__);
    
}
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
        NSLog(@"%s",__FUNCTION__);
}
#pragma -

#pragma mark broadcasting
-(void)startBroadcasting  {
    NSLog(@"%s",__FUNCTION__);
    //start BT
    [self createCBPeripheralManager];

    if (self.myBTManager.state == CBCentralManagerStatePoweredOn && !self.myBTManager.isAdvertising) {
        NSLog(@"start broadcast now");
        [self.myBTManager startAdvertising:self.myBTData];
    }
}

-(void)stopBroadcasting {
    NSLog(@"%s",__FUNCTION__);
    [self.myBTManager stopAdvertising];
}

#pragma -

#pragma mark Range (diffuser)
-(void)startRanging {
    NSLog(@"%s",__FUNCTION__);
    [self createLocationManager];
    
    if (![CLLocationManager isRangingAvailable]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lblMessage.text = @"Cannot start transmiter signal. Ranging is not available !!!";
        });
        return;
    }
    
    if (self.locationManager.rangedRegions.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lblMessage.text = @"Didn't turn on ranging: Ranging already on.";
        });
        return;
    }
    
    [self createBeacon]; //create beacon if need
    [self.locationManager startRangingBeaconsInRegion:self.myRegion];
}

-(void)stopRanging {
    if (self.locationManager.rangedRegions.count == 0) {
        NSLog(@"Didn't turn off ranging: Ranging already off.");
        return;
    }
    
    [self.locationManager stopRangingBeaconsInRegion:self.myRegion];
    
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
        [self.myBTManager startAdvertising:self.myBTData];
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
#pragma -


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

@end
