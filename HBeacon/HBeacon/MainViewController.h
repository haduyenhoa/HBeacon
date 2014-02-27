//
//  FirstViewController.h
//  HBeacon
//
//  Created by Duyen Hoa Ha on 18/02/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BeaconBroadcastAgent.h"
#import "BeaconReceiverAgent.h"

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, BeaconReceiverAgentDelegate>

@property (nonatomic) IBOutlet UITableView *tblBeaconsInRange;

@property (nonatomic, strong) BeaconBroadcastAgent *shareBBA;
@property (nonatomic, strong) BeaconReceiverAgent *shareBRA;

@property (nonatomic) IBOutlet UILabel *lblMessage;
@property (nonatomic) IBOutlet UIActivityIndicatorView *aivProcess;

@property (nonatomic) IBOutlet UISwitch *swBroadcast;
@property (nonatomic) IBOutlet UISwitch *swReceiver;

@end


