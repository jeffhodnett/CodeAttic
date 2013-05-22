//
//  RoundedPopupView.h
//  RoundedPopup
//
//  Created by Jeff Hodnett on 09/11/2010.
//  Copyright 2010 Applausible. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RoundedPopupView;

@protocol RoundedPopupViewDelegate
-(void)popupViewDismissed:(RoundedPopupView *)popupView;
@end

@interface RoundedPopupView : UIView {
	// The button
	UIButton *button;
			
	// The delegate
	id <RoundedPopupViewDelegate> delegate;
}

@property(nonatomic, assign) id <RoundedPopupViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame;

@end