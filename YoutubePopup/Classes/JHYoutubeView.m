//
//  JHYoutubeView.m
//  YoutubePopup
//
//  Created by Jeff Hodnett on 09/12/2010.
//  Copyright 2010 Applausible. All rights reserved.
//

#import "JHYoutubeView.h"


@implementation JHYoutubeView

- (id)initWithFrame:(CGRect)frame videoUrl:(NSString *)videoUrl{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		// Setup the webview
		CGRect videoFrame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height); 
		UIWebView *youtubeWebView = [[UIWebView alloc] initWithFrame:videoFrame];
		
		// Add the webview
		NSString *url = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",videoUrl];
		NSString* embedHTML = @"\
		<html><head>\
		<style type=\"text/css\">\
		body {\
		background-color: transparent;\
		color: white;\
		}\
		</style>\
		</head><body style=\"margin:0\">\
		<embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
		width=\"%0.0f\" height=\"%0.0f\"></embed>\
		</body></html>";
		
		NSString *htmlString = [NSString stringWithFormat:embedHTML, url, videoFrame.size.width, videoFrame.size.height];
		[youtubeWebView loadHTMLString:htmlString baseURL:nil];
		
		[self addSubview:youtubeWebView];
		[youtubeWebView release];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
