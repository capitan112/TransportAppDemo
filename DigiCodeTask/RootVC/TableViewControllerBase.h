//
//  TableViewControllerBase.h
//  DigiCodeTask
//
//  Created by Капитан on 15.11.16.
//

#import <UIKit/UIKit.h>
#import "DigiCodeTask-Swift.h"

@interface TableViewControllerBase : UITableViewController

@property (strong, nonatomic) NSMutableArray<Schedule *> *schedules;
@property (strong, nonatomic) NSString *url;

- (void)sortData;
- (void)loadShedulesWithKey:(NSString *)objectKey;

@end
