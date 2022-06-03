//
//  SendMessage.m
//  appbuildr
//
//  Created by Isaac Mosquera on 6/21/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SendMessageViewController.h"
#import "UIViewRounded.h"
#import "GlobalVariables.h"
#import "AppMakrNativeLocation.h"
#import "SendingMessageView.h"
#import "ASIFormDataRequest.h"
#import "KeychainItemWrapper.h"
#import "NSData+AES.h"
#import "NSData+Base64Additions.h"
#import "CustomMessageToolBar.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "CustomNavigationBar.h"

#define DEFAULT_TEXT @"Tap here to enter a message"
#define kTEXTVIEW_PORTRAIT_FRAME CGRectMake(0, 0, 320, (480 / 2) - 20)
#define kTEXTVIEW_LANDSCAPE_FRAME  CGRectMake(0, 0, 480, (320/2) - 30)

#define BUTTON_TITLE_LIBRARY @"Library" 
#define BUTTON_TITLE_CAMERA  @"Camera"


@implementation MessageViewController 
@synthesize useEncryption;
@synthesize includeLocation;
@synthesize selectedImage;

-(UIColor*) customHeaderColor
{
    NSDictionary *headerBgDict = (NSDictionary *)[[GlobalVariables getPlist] objectForKey:@"configuration"];
	if( headerBgDict ) {
		CGFloat bgRed = [(NSNumber *)[headerBgDict objectForKey:@"header_bg_red"] floatValue]/255.0f;
		CGFloat bgGreen =[(NSNumber *)[headerBgDict objectForKey:@"header_bg_green"] floatValue]/255.0f;
		CGFloat bgBlue = [(NSNumber *)[headerBgDict objectForKey:@"header_bg_blue"] floatValue]/255.0f;
		return [UIColor colorWithRed:bgRed green:bgGreen blue:bgBlue alpha:1.0f];
	}
    return [UIColor clearColor];
}

-(void) dealloc 
{	
	[encryptionKey release];
	[textView release];
	[imagePicker release];
	[selectedImage release];
	
	sendingMessageView.hidden = YES;
	[sendingMessageView removeFromSuperview];
	[sendingMessageView release];
	[submitButton release];
	
	//Application Specific information
	[deviceID release];
	[applicationID release];
	[applicationName release];
	
	[paperClipImageView release];
	[locationImageView release];
	
	[super dealloc];
}

- (id) init
{
	self = [super initWithNibName:nil bundle:nil];
	if (self != nil) 
	{
		
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle 
{
	if((self = [super initWithNibName:nibName bundle:nibBundle]) )
	{
		imagePicker = [[UIImagePickerController alloc]init];
		textView = [[UITextView alloc] init];
		textView.delegate = self;
		submitButton = nil;
	}
	return self;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//	if ( toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight  )
//		textView.frame = kTEXTVIEW_LANDSCAPE_FRAME;
//	else 
//		textView.frame = kTEXTVIEW_PORTRAIT_FRAME;
//}

//FUTURE:This should go in a message formatter class as part of 
//a chain of formatters for data;
-(NSString *) formatString:(NSString *)textString
{
	if (!self.useEncryption) 
	{
		return textString;  //We should really return a copy of the string
	}
	
	NSData * stringData = [self formatData:[textString dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSString * newString = [[NSString alloc]initWithData:stringData encoding:NSUTF8StringEncoding];
	
	return [newString autorelease];
}

-(NSData *) formatData:(NSData *)data
{
	if (!self.useEncryption) 
	{
		return data;  //We should really return a copy of the data
	}
	
	DebugLog(@"key leng: %i", [encryptionKey length]);
	NSData * encryptedData = [data AESEncryptWithKey:encryptionKey];
	
	NSString * encryptedString = [encryptedData encodeBase64ForData];
	
	return [encryptedString dataUsingEncoding:NSUTF8StringEncoding];
	
}

-(void)viewDidLoad_Credentials {
    NSDictionary *globalVars = (NSDictionary *)[GlobalVariables getPlist];	
	NSDictionary * applicationData = (NSDictionary *)[globalVars objectForKey:@"application"];
	
	deviceID = @"";
	applicationID = [[[applicationData objectForKey:@"pk"]stringValue] retain];
	applicationName = [[applicationData objectForKey:@"display_name"] copy];
}

-(void)viewDidLoad_SubmitButton {
    submitButton =	[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Submit",@"") style:UIBarButtonItemStylePlain target:self action:@selector(submitButtonTapped)];
}

-(void)viewDidLoad {	
    [self viewDidLoad_Credentials];
    
	self.view.backgroundColor = [UIColor whiteColor];
	
	textView.frame = kTEXTVIEW_PORTRAIT_FRAME;
	
	UIBarButtonItem *cameraButton = 
	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonTapped)];
	self.navigationItem.leftBarButtonItem = cameraButton;
	[cameraButton release];
	
	CustomMessageToolBar* toolBar = [[CustomMessageToolBar alloc] initWithFrame:CGRectMake(0, 0, 140, 44.01)];
    toolBar.tintColor = [self customHeaderColor];
	
	NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
	
	UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc]
									 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped)];
	cancelButton.style = UIBarButtonItemStyleBordered;
	[buttons addObject:cancelButton];
	[cancelButton release];
	
	// create a standard "refresh" button
	//UIBarButtonItem* submitButton = 
     //submitButton =	[[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitButtonTapped)];
	[self viewDidLoad_SubmitButton];
	//initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(refresh:)];
	submitButton.style = UIBarButtonItemStyleBordered;
	[buttons addObject:submitButton];
	
	submitButton.enabled = false;
	// stick the buttons in the toolbar
	[toolBar setItems:buttons animated:NO];	
	toolBar.autoresizingMask =  UIViewAutoresizingFlexibleHeight;
	[buttons release];
	
	// and put the toolbar in the nav bar
	UIBarButtonItem* tmpRightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolBar]; 
	self.navigationItem.rightBarButtonItem = tmpRightBarButtonItem;
	[tmpRightBarButtonItem release];
	[toolBar release];	

	[self.view addSubview:textView]; 
	
	UIView * statusView = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.frame];
	statusView.backgroundColor = [UIColor clearColor];
	self.navigationItem.titleView = statusView;
	
	[statusView release];
	
	UIImage * paperClipImage= [UIImage imageNamed:@"paperclip.png"];
	CGRect paperClipImageViewFrame = CGRectMake(0, 10, paperClipImage.size.width,paperClipImage.size.height);
	
	paperClipImageView = [[UIImageView alloc]initWithFrame:paperClipImageViewFrame];
	paperClipImageView.image = paperClipImage;
	paperClipImageView.hidden = YES;
	[statusView addSubview:paperClipImageView];

	UIImage * locationImage= [UIImage imageNamed:@"location.png"];
	CGRect locationImageViewFrame = CGRectMake(paperClipImageViewFrame.size.width+5, 10, locationImage.size.width, locationImage.size.height);
	
	locationImageView = [[UIImageView alloc]initWithFrame:locationImageViewFrame];
	locationImageView.image = locationImage;
	locationImageView.hidden = YES;
	[statusView addSubview:locationImageView];
	
	AppMakrNativeLocation * location = [AppMakrNativeLocation sharedInstance];
	
	if (self.includeLocation && location.islocationServicesEnabled) 
	{
		locationImageView.hidden = NO;
	}
	
	if (self.useEncryption) 
	{
		KeychainItemWrapper *secretKeyWrapper = [[[KeychainItemWrapper alloc] initWithIdentifier:@"_application_secret_key" accessGroup:nil] autorelease];
		NSString *keyString = ( NSString *) [secretKeyWrapper objectForKey:(id)kSecValueData];
		
		NSAssert(keyString!=nil, @"NSString: Encryption String can not be nil");
		NSData * keyData = [NSData decodeBase64ForString:keyString];
		
		NSAssert(keyData!=nil, @"NSData: Encryption Data can not be nil");
		encryptionKey = [keyData retain];
		
	}
	NSInteger halfTheSquare = 150;	
	sendingMessageView = [[SendingMessageView alloc] 
						  initWithFrame:CGRectMake(self.view.center.x - 75,self.view.center.y-halfTheSquare,halfTheSquare,halfTheSquare)];	
	sendingMessageView.hidden = YES;
	[self.view addSubview:sendingMessageView];

}

-(BOOL)getSubmitButtonEnabledStatus {
    return submitButton.enabled;
}

- (NSString *)getTextViewText {
    return textView.text;
}

- (void)checkInputFieldForContent {
    //submitButton.enabled = textView.text!=nil?(![textView.text isEqualToString:@""]):false;
    submitButton.enabled = [self getTextViewText]!=nil?(![[self getTextViewText] isEqualToString:@""]):false;
}

- (void)textViewDidChange:(UITextView *)textView1
{
	submitButton.enabled = ([textView1.text length]>0);
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated {
	if( selectedImage ) {
		[selectedImage release];
		selectedImage = nil;
	}	
}

-(void) setSelectedImageTo:(UIImage*)newImage
{
	[selectedImage release];
	selectedImage = [newImage retain];
	
	if (selectedImage!=nil) 
	{
		paperClipImageView.hidden = NO;
	}
	else
	{
		paperClipImageView.hidden = YES;
	}

}

//Overriden from MasterController
-(void)setupStatusView
{
	
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[textView becomeFirstResponder];
    if([self.navigationController.navigationBar isKindOfClass:[CustomNavigationBar class]])
    {
        [((CustomNavigationBar*)self.navigationController.navigationBar) clearBackground];
    }
    self.navigationController.navigationBar.tintColor = [self customHeaderColor];
}

-(void)doPrepareAndSendMessage
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
	NSData * imageData = UIImageJPEGRepresentation(selectedImage, 1);
	
	//I know retaining this is bad, but I want to make sure that the memory is released and that it
	//is not released too early by the auto released pool.
	[self performSelectorOnMainThread:@selector(doSendMessage:) withObject:[imageData retain] waitUntilDone:NO];
	[pool release];
}

-(void) doSendMessage:(NSData *)imageData
{
	AppMakrNativeLocation * location = [AppMakrNativeLocation sharedInstance];
	
	DebugLog(@"submitting request for send message");
	[self sendMessage:textView.text withImage:imageData AndLocation:location.lastKnownLocation];
	[imageData release];  //I know this is bad.  see note above!!!
	
}

- (void)submitButtonTapped {
	[textView resignFirstResponder];
	[self showSendingMessageViewWithMessage:nil];
	[self performSelectorInBackground:@selector(doPrepareAndSendMessage) withObject:nil];
}

-(void)showSendingMessageViewWithMessage:(NSString *)message
{
	if (message!=nil) 
	{
		sendingMessageView.labelView.text = message;
	}
	else 
	{
		sendingMessageView.labelView.text =  @"Sending Message";
	}

	sendingMessageView.hidden = NO;
}

-(void)hideSendingMessageView
{
	sendingMessageView.hidden = YES;
}

-(void)sendMessage:(NSString *)message withImage:(NSData *)image AndLocation:(CLLocation *) currentLocation
{
	
}

- (void)cancelButtonTapped 
{
	[textView resignFirstResponder];
    if([GlobalVariables templateType] == AppMakrScrollTemplate)
        [self dismiss];
}

- (void)cameraButtonTapped 
{
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:BUTTON_TITLE_LIBRARY, BUTTON_TITLE_CAMERA, nil];
	//[sheet showFromTabBar:self.tabBarController.tabBar];
    [sheet showInView:self.view];
	
	if ([imagePicker respondsToSelector:@selector(setAllowsEditing:)]) 
	{
		imagePicker.allowsEditing = YES;
	}
	imagePicker.delegate = self;

}

#pragma mark Image Picker delegate calls
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[self dismissModalViewControllerAnimated:YES];
	UIImage * editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
	
	if (editedImage) 
	{
		[self setSelectedImageTo:editedImage];
	}
	
	DebugLog(@"done!!!");
	
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	
	[self dismissModalViewControllerAnimated:YES]; 
	
}

#pragma "message  sender protocol  calls"
//FUTURE: Preparing for message send protocol

- (void)messageWasSentAlert {
    [textView becomeFirstResponder];
	
	UIAlertView *uiAlert = [[UIAlertView alloc]
                            initWithTitle:@"send message" message:@"message was successfully sent" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[uiAlert show]; 
	[uiAlert release];
}

- (void)messageWasSent:(id)message
{
	DebugLog(@"sending message tab success!");
	[self setSelectedImageTo:nil];
	textView.text =@"";
	//sendingMessageView.hidden = YES;
	[self hideSendingMessageView];
    
    [self checkInputFieldForContent];
    
	[self messageWasSentAlert];
}

- (void)messageWasNotSentAlert {
    [textView becomeFirstResponder];
    UIAlertView *uiAlert = [[UIAlertView alloc]
                            initWithTitle:@"send message" message:@"message was not successfully sent" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[uiAlert show]; 
	[uiAlert release];
}

- (void)messageWasNotSent:(id)message {
    DebugLog(@"sending message was not successful!");
    [self setSelectedImageTo:nil];
	//textView.text =@"";
    [self hideSendingMessageView];
    
    [self checkInputFieldForContent];
    
	[self messageWasNotSentAlert];
}

- (void)messageDidFail:(id)message error:(NSError *)error
{
	//sendingMessageView.hidden = YES;
	[self hideSendingMessageView];
	[error retain];
	UIAlertView *uiAlert = [[UIAlertView alloc]
							initWithTitle:@"send message error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[uiAlert show]; 
	[uiAlert release];
	
	DebugLog(@"sending message tab failed");
	[error release];
}

- (void)messageWasCanceled:(id)message
{
	DebugLog(@"sending message tab success!");
	//sendingMessageView.hidden = YES;
	[self hideSendingMessageView];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	// check titles instead of index, since the positioning of the buttons could be either way
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	
	if ([buttonTitle isEqualToString:BUTTON_TITLE_LIBRARY]) {
		[self selectFromLibrary];
	}
	
	else if ([buttonTitle isEqualToString: BUTTON_TITLE_CAMERA]) {
		[self selectFromCamera];
	}
	
}
- (void)selectFromLibrary{
	if( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
		
	} 
		[self.navigationController presentModalViewController:imagePicker animated:YES];
}
- (void)selectFromCamera{
	if( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		imagePicker.showsCameraControls = YES;
		imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
		
	} 
		[self.navigationController presentModalViewController:imagePicker animated:YES];
}

@end
