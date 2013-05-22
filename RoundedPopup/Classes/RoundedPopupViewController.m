//
//  RoundedPopupViewController.m
//  RoundedPopup
//
//  Created by Jeff Hodnett on 09/11/2010.
//  Copyright 2010 Applausible. All rights reserved.
//

#import "RoundedPopupViewController.h"
#import "UIView+Appear.h"

@implementation RoundedPopupViewController



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


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


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
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark Actions
-(IBAction)openPopup:(id)sender {
	
	// Create a popup
	RoundedPopupView *popupView = [[RoundedPopupView alloc] initWithFrame:CGRectMake(0, 100, 320, 225)];
	popupView.delegate = self;
	[self.view addSubview:popupView];
	
	// Perform animation
	[popupView appear];
	
	[popupView release];
}

#pragma mark Popup delegate
-(void)popupViewDismissed:(RoundedPopupView *)popupView {
	// Remove it
	[popupView removeFromSuperview];
}

@end
