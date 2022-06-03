//
//  MessageViewController.h
//  appbuildr
//
//  Created by William M. Johnson on 7/14/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MasterController.h"
#import "SendingMessageView.h"


//We'll keep this simple at first.  We should create a MessageSender protocol, which
//can be implemented by different types of message senders(i.e. Email, SMS, HttpPost/URL, Instant Message, and etc.)
@interface MessageViewController : MasterController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UIActionSheetDelegate> 
{
	UITextView					*textView;
	UIBarButtonItem				*submitButton;
	UIImagePickerController		*imagePicker;
	UIImage						*selectedImage;
	SendingMessageView			*sendingMessageView;
	
	UIImageView					*paperClipImageView;
	UIImageView					*locationImageView;
	
	//Application Specific information
	NSString					*deviceID;
	NSString					*applicationID;
	NSString					*applicationName;
	
	NSData						*encryptionKey;
	
	BOOL						useEncryption;
}

@property (nonatomic) BOOL useEncryption;
@property (nonatomic) BOOL includeLocation;
@property (nonatomic, retain) UIImage* selectedImage;

-(void)viewDidLoad_SubmitButton;
-(NSString *)getTextViewText;
-(BOOL)getSubmitButtonEnabledStatus;

-(void)sendMessage:(NSString *)message withImage:(NSData *)image AndLocation:(CLLocation *) currentLocation;
-(void)showSendingMessageViewWithMessage:(NSString *)message;
-(void)hideSendingMessageView;


//FUTURE:This should go in a message formatter class as part of 
//a chain of formatters for data;
-(NSString *) formatString:(NSString *)textString;
-(NSData *) formatData:(NSData *)data;
//FUTURE: Preparing for message send protocol 
- (void)messageWasSent:(id)message;
- (void)messageWasNotSent:(id)message;
- (void)messageDidFail:(id)message error:(NSError *)error;
- (void)messageWasCanceled:(id)message;

- (void)selectFromLibrary;
- (void)selectFromCamera;
@end
