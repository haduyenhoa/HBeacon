//
//  RegionPopupViewController.m
//  HBeacon
//
//  Created by Duyen Hoa Ha on 27/02/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

#import "RegionPopupViewController.h"

@interface RegionPopupViewController ()

@end

@implementation RegionPopupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self performSelectorOnMainThread:@selector(loadContent) withObject:nil waitUntilDone:NO];
}

-(void)setNearestBeacon:(CLBeacon *)nearestBeacon {
    NSString *distanceText = @"Unknown";
    if (nearestBeacon) {
        distanceText = [NSString stringWithFormat:@"%0.2f m",nearestBeacon.accuracy];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lblDistance.text = [NSString stringWithFormat:@"Distance: %@", distanceText];    
    });
    
}

-(void)loadContent {
    NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"lebonmarche" ofType:@"html"];
    [self.wvAd loadHTMLString:[NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil] baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
