//
//  TypewriterAnimationViewController.h
//  TypewriterAnimation
//
//  Created by Jeff Hodnett on 06/01/2011.
//  Copyright 2010 Applausible. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHTypeWriterView.h"

@interface TypewriterAnimationViewController : UIViewController<UITextFieldDelegate> {
	// Outlets
	IBOutlet UITextField *inputTextfield;
	IBOutlet UISlider *timerSlider;
	IBOutlet UILabel *sliderLabel;
	IBOutlet UISlider *jumpSlider;
	IBOutlet UILabel *jumpLabel;

	// The typewriter view
	JHTypeWriterView *typeWriterView;
}

@property(nonatomic, retain) IBOutlet UITextField *inputTextfield;
@property(nonatomic, retain) IBOutlet UISlider *timerSlider;
@property(nonatomic, retain) IBOutlet UILabel *sliderLabel;
@property(nonatomic, retain) IBOutlet UISlider *jumpSlider;
@property(nonatomic, retain) IBOutlet UILabel *jumpLabel;

-(IBAction)goAgainAction:(id)sender;

@end

