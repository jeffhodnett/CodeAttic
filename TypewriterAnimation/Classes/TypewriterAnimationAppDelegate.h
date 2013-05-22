//
//  TypewriterAnimationAppDelegate.h
//  TypewriterAnimation
//
//  Created by Jeff Hodnett on 06/01/2011.
//  Copyright 2010 Applausible. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TypewriterAnimationViewController;

@interface TypewriterAnimationAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TypewriterAnimationViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TypewriterAnimationViewController *viewController;

@end

