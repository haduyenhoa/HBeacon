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

@property (nonatomic) NSUUID    *uuid1;
@property (nonatomic) NSString  *identifier1;
@property (nonatomic) NSUUID    *uuid2;
@property (nonatomic) NSString  *identifier2;
@property (nonatomic) CLBeaconMajorValue       major1;
@property (nonatomic) CLBeaconMinorValue       minor1;

@property (nonatomic) CLBeaconMajorValue       major2;
@property (nonatomic) CLBeaconMinorValue       minor2;

@property (nonatomic) NSMutableDictionary *myBTData1;


@property (nonatomic) CLBeaconRegion *myRegion1; //a region to manager all beacons in range ! This can be also a Beacon (with proximityUUID & Identifier ????

@property (nonatomic) CLBeaconRegion *myRegion2;



@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.uuid1 = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-DLXLK5LKFCM8"];
    self.identifier1 = @"iPadMini";
    self.major1 = 1;
    self.minor1  = 1;
    
    self.uuid2 = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-DQGJ13JQDTD2"];
    self.identifier2 = @"iPhoneGiang";
    self.major2 = 2;
    self.minor2  = 1;
    
    NSLog(@"serial: %@",[self stringToHex:@"F18KPQMHDTWF"]);
    
    
    _listBeaconsInRange = [[NSMutableArray alloc] init];
}

- (NSString *) stringToHex:(NSString *)str
{
    NSUInteger len = [str length];
    unichar *chars = malloc(len * sizeof(unichar));
    [str getCharacters:chars];
    
    NSMutableString *hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
    {
        // [hexString [NSString stringWithFormat:@"%02x", chars[i]]]; //previous input
        
        [hexString appendFormat:@"%02x", chars[i]]; //EDITED PER COMMENT BELOW
    }
    free(chars);
    
    return hexString ;
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













@end
