//
//  YoutubePopupAppDelegate.h
//  YoutubePopup
//
//  Created by Jeff Hodnett on 09/12/2010.
//  Copyright 2010 Applausible. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YoutubePopupViewController;

@interface YoutubePopupAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    YoutubePopupViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet YoutubePopupViewController *viewController;

@end

