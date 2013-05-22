//
//  JHTypeWriterView.m
//  TypewriterAnimation
//
//  Created by Jeff Hodnett on 06/01/2011.
//  Copyright 2010 Applausible. All rights reserved.
//

#import "JHTypeWriterView.h"
#import <QuartzCore/QuartzCore.h>
#import "FontLabel.h"
#import "ZFont.h"
#import "FontManager.h"
#import "FontLabelStringDrawing.h"

#define kFONT @"Old Typewriter.ttf"

@implementation JHTypeWriterView

@synthesize timerFrequency;
@synthesize jumpHeight;

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
				
		// Store the text
		typewriterText = text;
	
		timerFrequency = 0.2f;
		jumpHeight = 0.0;
		
		characterIndex = 0;
		runningX = 0.0;
		
		// Load the font
		[[FontManager sharedManager] loadFont:kFONT];
		
		// Start the animation
		[self startTypingAnimation];
    }
    return self;
}
	
-(void)dealloc {
	[typewriterText release];
	
	[super dealloc];                                  
}

-(void)startTypingAnimationWithText:(NSString *)text {
	// Stop the timer
	if(characterTimer != nil) {
		[characterTimer invalidate];
		characterTimer = nil;
	}
	
	// Remove all the children
	for(UIView *child in self.subviews) { 
		[child removeFromSuperview];
	}

	// Some cleanup
	[typewriterText release];
	typewriterText = [text copy];
	
	characterIndex = 0;
	runningX = 0.0;
	
	// Start the animtion
	[self startTypingAnimation];
}

#pragma mark Animations
-(void)startTypingAnimation {
	
	// Start the animation
	if(characterTimer == nil) {
		characterTimer = [NSTimer scheduledTimerWithTimeInterval: timerFrequency
												 target: self
											   selector: @selector(addCharacter:)
											   userInfo: nil
												repeats: YES];
	}
}

- (void) addCharacter: (NSTimer *) timer {
	// Grab the current char
	unichar currentChar = [typewriterText characterAtIndex:characterIndex];
	NSString *text = [NSString stringWithFormat:@"%c",currentChar];
	
	// This adds character at a time
	ZFont *textFont = [[FontManager sharedManager] zFontWithName:kFONT pointSize: 22.0f];	
	CGSize maximumLabelSize = CGSizeMake(100, 100);
	CGSize expectedLabelSize = [text sizeWithZFont:textFont constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
	
	FontLabel *textLabel = [[FontLabel alloc] initWithFrame:CGRectMake(runningX, 2, expectedLabelSize.width, expectedLabelSize.height)];
	textLabel.zFont = textFont;
	[textLabel setText:text];
	[textLabel setBackgroundColor:[UIColor clearColor]];
	[self addSubview:textLabel];
	[textLabel release];
	
	// Create a wobble animation
	[UIView beginAnimations:@"animation" context:nil];
	[UIView setAnimationDuration:0.1];
	
	textLabel.center = CGPointMake(textLabel.center.x, textLabel.center.y + jumpHeight);
	
	[UIView commitAnimations];	
	
	// Update the running x
	runningX += expectedLabelSize.width;
	
	// Update the index
	characterIndex++;
	if(characterIndex >= [typewriterText length]) {
		[characterTimer invalidate];
		characterTimer = nil;
	}
}

@end
