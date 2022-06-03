    //
//  NingMessageViewController.m
//  appbuildr
//
//  Created by Isaac Mosquera on 9/13/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "NingMessageViewController.h"
#import "NingDomainService.h"

@implementation NingMessageViewController
@synthesize NingApiType;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
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
- (void)cancelButtonTapped 
{
	[ningService cancelRequest];
	DebugLog(@"ning cancel button tapped");
	DebugLog(@"retain count %@", self.navigationController);
	[self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void)sendMessage:(NSString *)message withImage:(NSData *)image AndLocation:(CLLocation *) currentLocation
{
	if ([NingApiType isEqualToString:NingUpdateStatusApi]) 
	{
		if( [message length] > 140 ) {
			[self showAlertView:@"Status Update Too Long" description:@"Please keep your status update under 140 characters"];
			[self hideSendingMessageView];
		} else {
			[ningService updateStatus:message];
		}
	}
	else if ([NingApiType isEqualToString:NingAddPhotoApi]) 
	{
		[ningService addPhoto:selectedImage title:titleTextField.text description:message];
		
	}
	else
	{
		[ningService addBlogPost:message title:titleTextField.text];
	
	}
		
}
- (void)viewDidLoad {
    [super viewDidLoad];
	
	CGFloat titleFrameHeight = 0;
	
	if (![NingApiType isEqualToString:NingUpdateStatusApi]) 
	{	
		titleFrameHeight = 25;
		CGRect titleFrame = CGRectMake(0,0, self.view.frame.size.width, titleFrameHeight);
		titleTextField = [[UITextField alloc] initWithFrame:titleFrame];
		titleTextField.backgroundColor = [UIColor whiteColor];
		titleTextField.borderStyle = UITextBorderStyleLine;
		titleTextField.delegate = self;
		titleTextField.returnKeyType = UIReturnKeyNext;
		titleTextField.placeholder = @"Title";
		titleTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self.view addSubview:titleTextField];
		
	}
	
	textView.frame = CGRectMake(0,titleFrameHeight,self.view.frame.size.width,(self.view.frame.size.height/2) -(30 +titleFrameHeight));
	
	self.navigationItem.leftBarButtonItem = nil;
	
	ningService = [[NingDomainService alloc]init];
	ningService.delegate = self;
	

}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return !UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)serviceCallBack:(NSDictionary *)responseDictionary
{
	
	[self hideSendingMessageView];
	NSError *error = [responseDictionary objectForKey:@"error"];
	if( error ) 
	{
		[self showAlertView:[error localizedFailureReason] description:[error localizedDescription]];
		return;
	}
	NSDictionary *ningResponse = [responseDictionary objectForKey:@"response"];
	BOOL success = [(NSNumber *)[ningResponse objectForKey:@"success"] boolValue];
	if(!success) {
		[self showAlertView:@"Ning API Error" description:[ningResponse objectForKey:@"reason"]];
		return;
	}
	[self.navigationController.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void) viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	if (![NingApiType isEqualToString:NingUpdateStatusApi]) 
	{
		[textView resignFirstResponder];
		[titleTextField becomeFirstResponder];
	}
	
	DebugLog(@"view will appear for ning controller");
	self.navigationItem.hidesBackButton = YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	[textView becomeFirstResponder];
	return NO;
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{


	[titleTextField release];
	[NingApiType release];
	[ningService release];
    [super dealloc];
}


@end
