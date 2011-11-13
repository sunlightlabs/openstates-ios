//
//  StatesPopoverManager.h
//  Created by Greg Combs on 11/13/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <Foundation/Foundation.h>
#import "StatesViewController.h"

@class StatesPopoverManager;
@protocol StatesPopoverDelegate <StateMenuSelectionDelegate>
@required
- (void)statePopover:(StatesPopoverManager *)statePopover didSelectState:(SLFState *)newState;
@optional
- (void)statePopoverDidCancel:(StatesPopoverManager *)statePopover;
@end

@interface StatesPopoverManager : NSObject <StateMenuSelectionDelegate, UIPopoverControllerDelegate>
+ (StatesPopoverManager *)showFromBarButtonItem:(UIBarButtonItem *)button delegate:(id<StatesPopoverDelegate>)delegate;
- (void)dismissPopover:(BOOL)animated;
@end
                                