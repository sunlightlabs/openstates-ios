//
//  AppDelegate.h
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
// This work is licensed under the BSD-3 License included with this source
// distribution.

@class SLFStackedViewController;
@class AppBarController;
@interface AppDelegate : NSObject <UIApplicationDelegate>
@property (nonatomic,retain) IBOutlet UIWindow *window;
@property (nonatomic,/*retain,*/ readonly) SLFStackedViewController *stackedViewController;
@property (nonatomic,retain, readonly) AppBarController *appBarController;
@property (nonatomic,retain, readonly) UINavigationController *navigationController;
@end

