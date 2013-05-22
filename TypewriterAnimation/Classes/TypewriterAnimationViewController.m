//
//  TypewriterAnimationViewController.m
//  TypewriterAnimation
//
//  Created by Jeff Hodnett on 06/01/2011.
//  Copyright 2010 Applausible. All rights reserved.
//

#import "TypewriterAnimationViewController.h"

@implementation TypewriterAnimationViewController

@synthesize inputTextfield;
@synthesize timerSlider;
@synthesize sliderLabel;
@synthesize jumpSlider;
@synthesize jumpLabel;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *startingText = @"Hi Jeff! How are you?";
	
	inputTextfield.delegate = self;
	[inputTextfield setText:startingText];
	
	// Setup the timer slider
	timerSlider.minimumValue = 0.0;
	timerSlider.maximumValue = 0.8;
	[timerSlider addTarget:self action:@selector(timerSliderChanged:) forControlEvents:UIControlEventValueChanged];

	// Setup the jump slider
	jumpSlider.minimumValue = -10.0;
	jumpSlider.maximumValue = 10.0;
	[jumpSlider addTarget:self action:@selector(jumpSliderChanged:) forControlEvents:UIControlEventValueChanged];

	// Add the typewriter view
	typeWriterView = [[JHTypeWriterView alloc] initWithFrame:CGRectMake(10, 70, 250, 100) andText:startingText];
	[self.view addSubview:typeWriterView];

	// Set the default values
	timerSlider.value = typeWriterView.timerFrequency;
	[sliderLabel setText:[NSString stringWithFormat:@"%f",typeWriterView.timerFrequency]];
	
	jumpSlider.value = typeWriterView.jumpHeight;
	[jumpLabel setText:[NSString stringWithFormat:@"%f",typeWriterView.jumpHeight]];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	inputTextfield = nil;
	timerSlider = nil;
	jumpSlider = nil;
	sliderLabel = nil;
	jumpLabel = nil;
}


- (void)dealloc {
	[inputTextfield release];
	[timerSlider release];
	[jumpSlider release];
	[sliderLabel release];
	[jumpLabel release];
	[typeWriterView release];
    [super dealloc];
}

#pragma mark Text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[inputTextfield resignFirstResponder];

	// Perform the animation
	if(inputTextfield.text != nil && ![inputTextfield.text isEqualToString:@""]) {
		[typeWriterView startTypingAnimationWithText:inputTextfield.text];
	}
	
	return YES;
}

#pragma mark Slider
- (void) timerSliderChanged:(id)sender {	
	typeWriterView.timerFrequency = timerSlider.value;
	[sliderLabel setText:[NSString stringWithFormat:@"%f",typeWriterView.timerFrequency]];
}	

- (void) jumpSliderChanged:(id)sender {	
	typeWriterView.jumpHeight = jumpSlider.value;
	[jumpLabel setText:[NSString stringWithFormat:@"%f",typeWriterView.jumpHeight]];
}

#pragma mark ACTIONS
-(IBAction)goAgainAction:(id)sender {
	[inputTextfield resignFirstResponder];
	
	// Perform the animation
	if(inputTextfield.text != nil && ![inputTextfield.text isEqualToString:@""]) {
		[typeWriterView startTypingAnimationWithText:inputTextfield.text];
	}
}

@end
