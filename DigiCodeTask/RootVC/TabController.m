//
//  TabController.m
//  DigiCodeTask
//
//  Created by Капитан on 14.11.16.
//

#import "TabController.h"
#import "TableViewControllerBase.h"
#import "CEFoldAnimationController.h"

const CGFloat navBarHeightLandscape = 30;
const CGFloat navBarHeightPortret = 64;

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@interface TabController ()

@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) UIToolbar *toolbar;

@end

@implementation TabController {
    CEFoldAnimationController *_animationController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _animationController = [[CEFoldAnimationController alloc] init];
    _animationController.folds = 1;
    [self setDelegate:self];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.tabBar invalidateIntrinsicContentSize];
    CGFloat tabSize = 44.0;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect tabFrame = self.tabBar.frame;
    
    if (IDIOM != IPAD) {
        if (UIInterfaceOrientationIsLandscape(orientation) ) {
            tabFrame.origin.y = self.view.frame.origin.y + navBarHeightLandscape;
        } else {
            tabFrame.origin.y = self.view.frame.origin.y + navBarHeightPortret;
        }
    } else {
        tabFrame.origin.y = self.view.frame.origin.y + navBarHeightPortret;
    }

    tabFrame.size.height = tabSize;
    self.tabBar.frame = tabFrame;
    self.tabBar.translucent = YES;
}

- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
            animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                              toViewController:(UIViewController *)toVC {
    [UIView transitionWithView:self.tabBar
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.tabBar.hidden = YES;
                    }
                    completion:NULL];
    
    NSUInteger fromVCIndex = [tabBarController.viewControllers indexOfObject:fromVC];
    NSUInteger toVCIndex = [tabBarController.viewControllers indexOfObject:toVC];
    
    _animationController.reverse = fromVCIndex < toVCIndex;
    _animationController.tabBar = self.tabBar;
    
    return _animationController;
}

@end
