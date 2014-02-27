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













@end
