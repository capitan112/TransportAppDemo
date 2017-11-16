//
//  BusViewController.m
//  DigiCodeTask
//
//  Created by Капитан on 14.11.16.
//

#import "BusViewController.h"

@interface BusViewController ()

@end

@implementation BusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.url = @"https://api.myjson.com/bins/37yzm";
    [self loadShedulesWithKey:NSStringFromClass([self class])];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
