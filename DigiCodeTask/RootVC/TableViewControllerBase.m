//
//  TableViewControllerBase.m
//  DigiCodeTask
//
//  Created by Капитан on 15.11.16.
//

#import "TableViewControllerBase.h"
#import "TabController.h"
#import "NetworkConnect.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "UILabel+BarTitle.h"

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
#define Occurrence @"{size}"
#define ReplaceTo @"63"
const CGFloat toolbarHeight = 44;

typedef void ((^AlertActionBlock) (UIAlertAction * action));
static NSString *cellIdentifier = @"CustomCellId";

@interface TableViewControllerBase ()

@property (nonatomic) Reachability *internetReachability;
@property (nonatomic, assign) BOOL sorted;
@property (nonatomic, strong) NSString *userDefaultsKey;
@property (nonatomic, assign) BOOL needsSave;
@property (strong, nonatomic) UIToolbar *toolbar;

@end

@implementation TableViewControllerBase

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sorted = TRUE;
    
    UINib *cellNib = [UINib nibWithNibName:@"CustomCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    
    self.navigationItem.titleView = [UILabel createNavBarTitle:@"Berlin-Munich\nJun 07"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self toolBarCreate];
}

- (void)toolBarCreate {
    self.toolbar = [[UIToolbar alloc] init];
    
    self.toolbar.barTintColor =  [UIColor colorWithRed:15.0f/255.0f
                                                 green:97.0f/255.0f
                                                  blue:163.0f/255.0f
                                                 alpha:1.0f];
    self.toolbar.frame = CGRectMake(0, self.view.frame.size.height - toolbarHeight, self.view.frame.size.width, toolbarHeight);
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    UIImage *tabIcon = [UIImage imageNamed:@"tabIcon.png"];
    UIBarButtonItem *sortBarButtonItem = [[UIBarButtonItem alloc] initWithImage:tabIcon style:UIBarButtonItemStylePlain target:self action:@selector(onToolbarTapped:)];
    sortBarButtonItem.tintColor = [UIColor whiteColor];
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixedItem setWidth:20.0f];
    
    [items addObject:fixedItem];
    [items addObject:sortBarButtonItem];
    
    [self.toolbar setItems:items animated:NO];
    [self.navigationController.view addSubview:self.toolbar];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.toolbar invalidateIntrinsicContentSize];
    
    //toolbar rotation
    self.toolbar.frame = CGRectMake(0, self.tabBarController.view.frame.size.height - toolbarHeight, self.view.frame.size.width, toolbarHeight);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveChanges:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveChanges:) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveChanges:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationWillResignActiveNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationWillTerminateNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - load handling and save data

- (IBAction) onToolbarTapped:(id)sender {
    [self sortData];
}

- (void)saveChanges:(NSNotification *)notifications {
    if (!self.needsSave)
        return;
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.schedules] forKey:self.userDefaultsKey];
    self.needsSave = NO;
}

- (void)loadShedulesWithKey:(NSString *)objectKey {
    self.userDefaultsKey = objectKey;
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *savedArray = [currentDefaults objectForKey:objectKey];
    if (savedArray != nil) {
        NSArray *oldArray = [NSKeyedUnarchiver unarchiveObjectWithData:savedArray];
        if (oldArray != nil) {
            self.schedules = [[NSMutableArray alloc] initWithArray:oldArray];
            [self.tableView reloadData];
        }
    } else {
        [self getJSONFromURL:self.url];
    }
}

- (void)getJSONFromURL:(NSString *)url {

    NetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
    if (netStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Offline status"
                                                        message:@"Please connect to Internet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"Loading...";
    
    __weak TableViewControllerBase *weakSelf = self;
    
    [NetworkConnect getJSONfromURL:url completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            if ([responseObject isKindOfClass:[NSArray class]]) {
                NSArray *responseArray = responseObject;
                self.schedules = [[NSMutableArray alloc] init];
                
                for (NSDictionary *item in responseArray) {
                    NSNumber *idNumber = item[@"id"];
                    int numberOfStops = [item[@"number_of_stops"] intValue];
                    
                    NSString *departureTime = item[@"departure_time"];
                    NSString *arrivalTime = item[@"arrival_time"];
                    
                    float priceEuro = [item[@"price_in_euros"] floatValue];
                    NSURL *providerLogo = [NSURL URLWithString:[self replceStringinURL:item[@"provider_logo"]]];
    
                    NSDateFormatter *formatarteste = [[NSDateFormatter alloc]init];
                    [formatarteste setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                    [formatarteste setDateFormat:@"HH:mm"];
                    
                    NSDate *departureDate = [formatarteste dateFromString:departureTime];
                    NSDate *arrivalDate = [formatarteste dateFromString:arrivalTime];
                    // add to sheddule all parametrs
                    
                    Schedule *shedule = [[Schedule alloc] initWithId:idNumber providerLogo:providerLogo priceInEuros:priceEuro departureTime:departureDate arrivalTime:arrivalDate numberOfstops:numberOfStops imageLogo: nil];
                    
                    [weakSelf.schedules addObject:shedule];
                }
                weakSelf.needsSave = YES;
                [MBProgressHUD hideHUDForView: self.navigationController.view animated:YES];
                [weakSelf.tableView reloadData];
            }
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.schedules.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cell.departureLabel.text = [self timeConverterFromDate:self.schedules[indexPath.row].departureTime];

    NSString *arrivalTimeAndStops;
    NSString *arrivalString = [self timeConverterFromDate:self.schedules[indexPath.row].arrivalTime];
    
    if (self.schedules[indexPath.row].numberOfstops > 0) {
        arrivalTimeAndStops = [NSString stringWithFormat:@"%@ (+%ld)", arrivalString, (long)self.schedules[indexPath.row].numberOfstops];
    } else {
        arrivalTimeAndStops = [NSString stringWithFormat:@"%@", arrivalString];
    }
    
    cell.arrivalLabel.text = arrivalTimeAndStops;
    
    NSString *euroPrice = [NSString stringWithFormat:@"\u20AC%.02f", self.schedules[indexPath.row].priceInEuros];
    NSRange labelRange;
    if (euroPrice.length >= 6) {
        labelRange = NSMakeRange(3, 3);
    } else {
        labelRange = NSMakeRange(2, 3);
    }
    [cell.priceLabel setAttributedText:[self myLabelAttributes:euroPrice range:labelRange]];
    
    NSDate *timeInterval = [NSDate dateWithTimeIntervalSinceReferenceDate:self.schedules[indexPath.row].timeInterval];
    NSString *direct = [NSString stringWithFormat:@"Direct   %@h", [self timeConverterFromDate:timeInterval]];
    cell.durationLabel.text = direct;
    
    NSURL *url = self.schedules[indexPath.row].providerLogo;
    if (self.schedules[indexPath.row].imageLogo == nil) {
        [self loadImage:url forIndexPath:indexPath];
    } else {
        cell.logoImageView.image = self.schedules[indexPath.row].imageLogo;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Offer details"
                                                    message:@"Offer details are not yet implemented!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80.0;
}

#pragma mark - cell image loader

- (void)loadImage:(NSURL *)url forIndexPath:(NSIndexPath *)indexPath {
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CustomCell *updateCell = (CustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell) {
                        updateCell.logoImageView.image = image;
                        self.schedules[indexPath.row].imageLogo = image;
                        self.needsSave = YES;
                    }
                });
            }
        }
    }];
    [task resume];
}

#pragma mark - text attribute

- (NSMutableAttributedString *)myLabelAttributes:(NSString *)input range:(NSRange)range {
    NSMutableAttributedString *labelAttributes = [[NSMutableAttributedString alloc] initWithString:input];
    [labelAttributes addAttribute:NSFontAttributeName
                            value:[UIFont systemFontOfSize:16.0]
                            range:range];
    return labelAttributes;
}

#pragma mark - data Handler

- (void)sortData {
    __block NSSortDescriptor *sortDescriptor;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sort"
                                                                   message:@"Select sort option"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    __weak TableViewControllerBase *weakSelf = self;
    
    AlertActionBlock byArrivalSortBlock = ^(UIAlertAction * action) {
        if (weakSelf.sorted) {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"arrivalTime"
                                                         ascending:YES];
            
        } else {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"arrivalTime"
                                                         ascending:NO];
        }
        [weakSelf.schedules sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        weakSelf.sorted = !weakSelf.sorted;
        [self.tableView reloadData];
    };
    
    AlertActionBlock byDepartureSortBlock = ^(UIAlertAction * action) {
        
        if (weakSelf.sorted) {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"departureTime"
                                                         ascending:YES];
            
        } else {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"departureTime"
                                                         ascending:NO];
        }
        [weakSelf.schedules sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        weakSelf.sorted = !weakSelf.sorted;
        [self.tableView reloadData];
    };
    
    
    AlertActionBlock byDurationSortBlock = ^(UIAlertAction * action) {
        if (weakSelf.sorted) {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeInterval"
                                                         ascending:YES];
            
        } else {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeInterval"
                                                         ascending:NO];
        }
        [weakSelf.schedules sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        weakSelf.sorted = !weakSelf.sorted;
        [self.tableView reloadData];
        
    };
    
    AlertActionBlock byPriceSortBlock = ^(UIAlertAction * action) {
        if (weakSelf.sorted) {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priceInEuros"
                                                         ascending:YES];
            
        } else {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priceInEuros"
                                                         ascending:NO];
        }
        [weakSelf.schedules sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        weakSelf.sorted = !weakSelf.sorted;
        [self.tableView reloadData];
    };
    
    UIAlertAction *byArrivalAction = [UIAlertAction actionWithTitle:@"By Arrival Time"
                                                              style:UIAlertActionStyleDefault
                                                            handler:byArrivalSortBlock];
    UIAlertAction *byDeparteAction = [UIAlertAction actionWithTitle:@"By Departure Time"
                                                              style:UIAlertActionStyleDefault
                                                            handler:byDepartureSortBlock];
    UIAlertAction *byDurationAction = [UIAlertAction actionWithTitle:@"By Duration"
                                                               style:UIAlertActionStyleDefault
                                                             handler:byDurationSortBlock];
    
    UIAlertAction *byPriceAction = [UIAlertAction actionWithTitle:@"By Price"
                                                               style:UIAlertActionStyleDefault
                                                             handler:byPriceSortBlock];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                                                            }];
    [alert addAction:byPriceAction];
    [alert addAction:byDeparteAction];
    [alert addAction:byArrivalAction];
    [alert addAction:byDurationAction];
    [alert addAction:cancel];
    
    if (IDIOM == IPAD) {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)timeConverterFromDate:(NSDate *)date {
    NSDateFormatter *formatarteste = [[NSDateFormatter alloc]init];
    [formatarteste setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [formatarteste setDateFormat:@"HH:mm"];

    return [formatarteste stringFromDate:date];
}


- (NSString *)replceStringinURL:(NSString *)url {
    url = [url stringByReplacingOccurrencesOfString: Occurrence
                                         withString: ReplaceTo];
    return url;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
