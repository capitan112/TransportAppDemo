//
//  UILabel+BarTitle.m
//  DigiCodeTask
//
//  Created by Капитан on 16.11.16.
//

#import "UILabel+BarTitle.h"

@implementation UILabel (BarTitle)

+ (UILabel *)createNavBarTitle: (NSString *)textLabel {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 2;
    label.font = [UIFont boldSystemFontOfSize: 14.0f];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = textLabel;
    
    
    return label;
    
}

@end
