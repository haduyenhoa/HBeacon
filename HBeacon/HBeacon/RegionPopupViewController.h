//
//  RegionPopupViewController.h
//  HBeacon
//
//  Created by Duyen Hoa Ha on 27/02/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CLBeaconRegion.h>

@interface RegionPopupViewController : UIViewController

@property (nonatomic) IBOutlet UIWebView *wvAd;
@property (nonatomic) IBOutlet UILabel *lblDistance;

-(IBAction)closeMe:(id)sender;

-(void)setNearestBeacon:(CLBeacon *)nearestBeacon;

@end
