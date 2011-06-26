//
//  IPHelpController.m
//  ipad-portfolio
//
//  Created by Brian Dewey on 6/18/11.
//  Copyright 2011 Brian's Brain. All rights reserved.
//

#import "IPHelpController.h"
#import "NSString+TestHelper.h"

@interface IPHelpController()

- (void)dismissHelpController;
- (void)goBack;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation IPHelpController

@synthesize webView = webView_;

////////////////////////////////////////////////////////////////////////////////
//
//  Designated initializer.
//

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    
    self.modalPresentationStyle = UIModalPresentationFormSheet;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained properties.
//

- (void)dealloc {
  
  [webView_ release];
  [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release cached data.
//

- (void)didReceiveMemoryWarning {

  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

////////////////////////////////////////////////////////////////////////////////
//
//  Post-load initialization.
//

- (void)viewDidLoad {

  [super viewDidLoad];
  
  self.webView.delegate = self;
  
  //
  //  Configure how I look inside a navigation controller.
  //
  
  self.navigationItem.title = kUserGuide;
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                          target:self 
                                                                                          action:@selector(dismissHelpController)] 
                                            autorelease];

  _GTMDevAssert(self.webView != nil, @"self.webView must not be nil");
  NSURL *url = [NSURL fileURLWithPath:[@"getting-started.html" asPathInBundlePath] isDirectory:NO];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  [self.webView loadRequest:request];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Release retained outlets.
//

- (void)viewDidUnload {

  [super viewDidUnload];

  self.webView = nil;
}

////////////////////////////////////////////////////////////////////////////////
//
//  We support all orientations.
//

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

  return YES;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Dismiss myself.
//

- (void)dismissHelpController {
  
  [self dismissModalViewControllerAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////
//
//  Navigate backwards.
//

- (void)goBack {
  
  [self.webView goBack];
}

#pragma mark - UIWebViewDelegate

////////////////////////////////////////////////////////////////////////////////
//
//  When a page finishes loading, figure out if we should show a back button.
//

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
  if (webView.canGoBack && (self.navigationItem.leftBarButtonItem == nil)) {
    
    //
    //  Need to make a left bar button item.
    //
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:kBackString 
                                                                              style:UIBarButtonItemStyleBordered 
                                                                             target:self 
                                                                             action:@selector(goBack)] 
                                             autorelease];
  }
  
  if (!webView.canGoBack && (self.navigationItem.leftBarButtonItem != nil)) {
    
    //
    //  If we can't go back, make sure we don't show a back button.
    //
    
    self.navigationItem.leftBarButtonItem = nil;
  }
}

@end
