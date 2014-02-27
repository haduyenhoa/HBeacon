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
}

-(void)newMessage:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lblMessage.text = msg;
    });
}
#pragma -

#pragma mark Table View
-(int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_shareBRA getListBeaconInRange] == nil ? 0 : [_shareBRA getListBeaconInRange].count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:@"BeaconCellId"];
    
    return aCell;
}

#pragma -
@end
