//
//  FlightViewController.m
//  DigiCodeTask
//
//  Created by Капитан on 14.11.16.
//

#import "FlightViewController.h"

@interface FlightViewController ()

@end

@implementation FlightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.url = @"https://api.myjson.com/bins/w60i";
    [self loadShedulesWithKey:NSStringFromClass([self class])];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
