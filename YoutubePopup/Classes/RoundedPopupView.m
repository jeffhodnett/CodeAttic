//
//  RoundedPopupView.m
//  RoundedPopup
//
//  Created by Jeff Hodnett on 09/11/2010.
//  Copyright 2010 Applausible. All rights reserved.
//

#import "RoundedPopupView.h"
#import "UIView+Appear.h"
#import "JHYoutubeView.h"

@implementation RoundedPopupView

@synthesize delegate;

-(id)initWithFrame:(CGRect)frame {
	
	if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self setBackgroundColor:[UIColor clearColor]];
		
		// Add the youtube view
		JHYoutubeView *youtubeView = [[JHYoutubeView alloc] initWithFrame:CGRectMake(50, 20, 220, 150) videoUrl:@"oHg5SJYRHA0"];
		[self addSubview:youtubeView];
		[youtubeView release];
		
		// Add a back button
		UIImage *buttonImage = [UIImage imageNamed:@"back.png"];
		button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setFrame:CGRectMake((self.bounds.size.width-buttonImage.size.width)/2, self.bounds.size.height - buttonImage.size.height - 10, buttonImage.size.width, buttonImage.size.height)];
		[button setImage:buttonImage forState:UIControlStateNormal];
		[button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)dirtyRect {
	// Drawing code

	// Get the context
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	// Set the drop shadow
	CGContextSaveGState(ctx);
	CGContextSetShadow(ctx, CGSizeMake(0, 3), 3);
	
	// Generate a rect
	CGRect rect = CGRectMake(5, 5, self.bounds.size.width - 10, self.bounds.size.height - 10); 

	// Draw the background
	float radius = 5.0f;
	CGContextBeginPath(ctx);
	CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1 ] CGColor]) );
	CGContextMoveToPoint(ctx, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));		
	CGContextAddArc(ctx, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * M_PI / 2, 0, 0);
	CGContextAddArc(ctx, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
	CGContextAddArc(ctx, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
	CGContextAddArc(ctx, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3 * M_PI / 2, 0);
	CGContextClosePath(ctx);
	CGContextFillPath(ctx);
		
	// Restore state drawing the shadow
	CGContextRestoreGState(ctx);

	// Add Gradient
	CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.25,  // Start color
		1.0, 1.0, 1.0, 0.06 }; // End color
	
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
	
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
	CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
    CGContextDrawLinearGradient(ctx, glossGradient, topCenter, bottomCenter, 0);
	
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
	
	// Add top grey line ( to give nice effect)
	float lineYOffset = 1.5;
	CGContextBeginPath(ctx);
	CGContextSetStrokeColor(ctx, CGColorGetComponents([[UIColor colorWithRed:0.862 green:0.862 blue:0.862 alpha:0.3 ] CGColor]) );
	CGContextSetLineWidth(ctx, 1.0);
	CGContextMoveToPoint(ctx, CGRectGetMinX(rect) + 1, CGRectGetMinY(rect) + lineYOffset);		
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect) - 1, CGRectGetMinY(rect) + lineYOffset);
	CGContextStrokePath(ctx);
	
	// Stroke outline
	CGContextBeginPath(ctx);
	CGContextSetStrokeColor(ctx, CGColorGetComponents([[UIColor colorWithRed:0.4 green:0.1 blue:0.1 alpha:1 ] CGColor]) );
	CGContextSetLineWidth(ctx, 2.0);
	CGContextMoveToPoint(ctx, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));		
	CGContextAddArc(ctx, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * M_PI / 2, 0, 0);
	CGContextAddArc(ctx, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
	CGContextAddArc(ctx, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
	CGContextAddArc(ctx, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3 * M_PI / 2, 0);
	CGContextClosePath(ctx);
	CGContextStrokePath(ctx);
}

- (void)dealloc {
    [super dealloc];
}

-(void)buttonPressed:(id)sender {	
	// Perform animation
	[self disappearWithCallback:@selector(cleanup)];
}

-(void)cleanup {
	// Notify the delegate
	[delegate popupViewDismissed:self];	
}

@end