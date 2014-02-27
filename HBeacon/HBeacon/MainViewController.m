//
//  FirstViewController.m
//  HBeacon
//
//  Created by Duyen Hoa Ha on 18/02/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

#import "MainViewController.h"
#import "HBeaconRegion.h"

#import "RegionPopupViewController.h"

@interface MainViewController () {
    NSMutableArray *_listBeaconsInRange;
    RegionPopupViewController *popUp;
    
    BOOL popUpIsShown;
}
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
       NSLog(@"serial: %@",[self stringToHex:@"F18KPQMHDTWF"]);
    
    self.swBroadcast.on = NO;
    self.swReceiver.on = NO;
    
    _listBeaconsInRange = [[NSMutableArray alloc] init];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                         bundle:nil];
    popUp = [storyboard instantiateViewControllerWithIdentifier:@"popUpId"];
    
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
}

-(IBAction)switchEnableChanged:(id)sender {
    if (sender == self.swReceiver) {
        if (self.shareBRA == nil) {
            self.shareBRA = [BeaconReceiverAgent shareBA];
            self.shareBRA.delegate = self;
        }
        [self.shareBRA enableReceiver:self.swReceiver.on];
    } else if (sender == self.swBroadcast) {
        if (self.shareBBA == nil) {
            self.shareBBA = [BeaconBroadcastAgent shareBBA];
        }
        
        [self.shareBBA enableBroadcast:self.swBroadcast.on];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark BeaconReceiverAgentDelegate 
-(void)beaconsUpdated {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tblBeaconsInRange reloadData];
    });
    
    //show pop-up
    if ([_shareBRA getListBeaconInRange].count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (popUp) {
                [popUp setNearestBeacon:[[[_shareBRA getListBeaconInRange] objectAtIndex:0] getNearestBeacon]];
                if (popUpIsShown) {
                    NSLog(@"pop-up is shown");
                    return;
                }
                
                [self.view addSubview:popUp.view];
                popUpIsShown = YES;
            } else {
                NSLog(@"Cannot found pop-up");
            }
        });
    } else {
        if (popUp) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [popUp.view removeFromSuperview];
                popUpIsShown = NO;
            });
        }
    }
}

-(void)newMessage:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lblMessage.text = msg;
    });
}
#pragma -

#pragma mark Table View
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_shareBRA getListBeaconInRange] == nil ? 0 : [_shareBRA getListBeaconInRange].count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:@"BeaconCellId"];
    NSAssert1(aCell != nil, @"as we use storyboard, this cell must be null", nil);
    UILabel *lblRegionIdentifier = (UILabel*)[aCell viewWithTag:1];
    UILabel *lblRegionUUID = (UILabel*)[aCell viewWithTag:2];
    UILabel *lblNumberOfBeaconsInRegion = (UILabel*)[aCell viewWithTag:3];
    UILabel *lblNearestBeaconRssi = (UILabel*)[aCell viewWithTag:4];
    UILabel *lblNearestBeaconDistance = (UILabel*)[aCell viewWithTag:5];
    
    HBeaconRegion *cellHBeacon = [[_shareBRA getListBeaconInRange] objectAtIndex:indexPath.row];
    if (cellHBeacon) {
        lblRegionIdentifier.text = cellHBeacon.beaconReagion.identifier;
        lblRegionUUID.text = cellHBeacon.beaconReagion.proximityUUID.UUIDString;
        lblNumberOfBeaconsInRegion.text = [NSString stringWithFormat:@"%lu",(unsigned long)cellHBeacon.beaconsInRegion.count];
        
        CLBeacon *nearestBeacon = [cellHBeacon getNearestBeacon];
        if (nearestBeacon) {
            lblNearestBeaconRssi.text = [NSString stringWithFormat:@"Signal strength: %ld dB",(long)nearestBeacon.rssi];
            lblNearestBeaconDistance.text = [NSString stringWithFormat:@"Distance: %0.2f m", nearestBeacon.accuracy];
        } else {
            lblNearestBeaconRssi.text = @"Signal strength: unknown";
            lblNearestBeaconDistance.text = @"Distance: unknown";
        }
    }
    
    return aCell;
}

#pragma -
@end
