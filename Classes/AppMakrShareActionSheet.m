//
//  AppMakrShareActionSheet.m
//  appbuildr
//
//  Created by Sergey Popenko on 11/23/11.
//  Copyright (c) 2011 pointabout. All rights reserved.
//

#import "AppMakrShareActionSheet.h"
#import "UIActionSheet+BlocksKit.h"
#import "CommentViewController.h"
#import "GlobalVariables.h"
#import "Entry.h"

@interface AppMakrShareActionSheet()
    -(void) doFacebookShare;
    -(void) doTwitterShare;
    -(void) doMailShare;
@end

@implementation AppMakrShareActionSheet
@synthesize facebookShare = _facebookShare;
@synthesize twitterShare = _twitterShare;
@synthesize mailShare = _mailShare;
@synthesize appMakrPublish = _appMakrPublish;
@synthesize parentController = _parentController;

-(id)initWithTitle:(NSString*)title entry: (Entry*)entry
{
    self =  [super initWithTitle:title delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    if(self)
    {
        // do not retain. 
        _entry = entry;
    }
    return self;
}

+(AppMakrShareActionSheet*)actionSheetForEntry:(Entry*)entry configurationBlock: (void (^)(AppMakrShareActionSheet*)) block
{
    AppMakrShareActionSheet* actionSheet = [[AppMakrShareActionSheet alloc]initWithTitle:@"" entry:entry];
    block(actionSheet);

    if(actionSheet.facebookShare)
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Share on Facebook", @"") handler:^{ [actionSheet doFacebookShare]; }];
    
    if(actionSheet.twitterShare)
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Share on Twitter", @"") handler:^{ [actionSheet doTwitterShare]; }];
    
    if(actionSheet.mailShare)
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Share on Email", @"") handler:^{ [actionSheet doMailShare]; }];
    
    [actionSheet setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"") handler:^{}];
    return [actionSheet autorelease];
}


-(void) doFacebookShare
{
    _modalViewController = (SocializeModalViewController*)[[CommentViewController alloc]
                                                           initWithNibName:@"CommentViewController" bundle:nil
                                                           postType:FacebookShare
                                                           entry:_entry];
    
    _modalViewController.modalDelegate = self;	
    [_modalViewController show];
}

-(void) doTwitterShare
{
    NSLog(@"Twitter");   
    _modalViewController = (SocializeModalViewController*)[[CommentViewController alloc]
                                                           initWithNibName:@"CommentViewController" bundle:nil 
                                                           postType:TwitterShare 
                                                           entry:_entry];
    
    _modalViewController.modalDelegate = self;
    [_modalViewController show];
}

-(void) doMailShare
{     
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:[NSString stringWithFormat:@"%@",_entry.title]];
    if(!self.appMakrPublish)
        [mailController setMessageBody:[NSString stringWithFormat:@"I thought you would find this interesting:<br /><br />%@ - <a href=\"%@\">%@</a><br /><br />Shared from %@, an iPhone app.",_entry.title,_entry.url,_entry.url,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]] isHTML:YES];
    else
        [mailController setMessageBody:[NSString stringWithFormat:@"I thought you would find this interesting:<br /><br />%@ - <a href=\"%@\">%@</a><br /><br />Shared from %@, an iPhone app made with <a href=\"http://www.appmakr.com\">www.AppMakr.com</a>",_entry.title,_entry.url,_entry.url,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]] isHTML:YES];
    
    [self.parentController presentModalViewController:mailController animated:YES];
    [mailController release];
}


-(void)dismissModalView:(UIView*)myView
{
    [_modalViewController fadeOutView];
	[_modalViewController release]; _modalViewController = nil;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self.parentController dismissModalViewControllerAnimated:YES];
}
@end
