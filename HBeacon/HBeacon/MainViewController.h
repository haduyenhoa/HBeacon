//
//  FirstViewController.h
//  HBeacon
//
//  Created by Duyen Hoa Ha on 18/02/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MainViewController : UIViewController 

@property (nonatomic) IBOutlet UITableView *tblBeaconsInRange;

@property (nonatomic) IBOutlet UILabel *lblMessage;
@property (nonatomic) IBOutlet UIActivityIndicatorView *aivProcess;
@property (nonatomic) IBOutlet UISegmentedControl *scMode;

@end


