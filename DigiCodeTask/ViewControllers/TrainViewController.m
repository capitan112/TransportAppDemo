//
//  ViewController.m
//  DigiCodeTask
//
//  Created by Капитан on 14.11.16.
//

#import "TrainViewController.h"

@interface TrainViewController ()

@end

@implementation TrainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.url = @"https://api.myjson.com/bins/3zmcy";
    [self loadShedulesWithKey:NSStringFromClass([self class])];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
