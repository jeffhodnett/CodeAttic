//
//  RoundedPopupAppDelegate.h
//  RoundedPopup
//
//  Created by Jeff Hodnett on 09/11/2010.
//  Copyright 2010 Applausible. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RoundedPopupViewController;

@interface RoundedPopupAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    RoundedPopupViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RoundedPopupViewController *viewController;

@end

