//
//  JHTypeWriterView.h
//  TypewriterAnimation
//
//  Created by Jeff Hodnett on 06/01/2011.
//  Copyright 2010 Applausible. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHTypeWriterView : UIView {

	// The text
	NSString *typewriterText;
	
	// Animations
	NSTimer *characterTimer;
	float timerFrequency;
	int characterIndex;
	float runningX;
	
	// Jump
	float jumpHeight;
}

@property(nonatomic) float timerFrequency;
@property(nonatomic) float jumpHeight;

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text;

-(void)startTypingAnimation;

-(void)startTypingAnimationWithText:(NSString *)text;

@end
