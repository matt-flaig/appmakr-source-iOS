//
//  AppMakrCommentDetailsView.m
//  appbuildr
//
//  Created by Sergey Popenko on 4/6/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "AppMakrCommentDetailsView.h"
#import "AppMakrCommentMapView.h"
#import <QuartzCore/QuartzCore.h>

#define VIEW_OFSET_SIZE 20
#define GEO_LABLE_OFSSET 9

@interface AppMakrCommentDetailsView()
    -(void) updateComponentsLayoutWithCommentViewHeight: (CGFloat) height;
@end

@implementation AppMakrCommentDetailsView

@synthesize commentMessage;
@synthesize mapOfUserLocation;
@synthesize navImage;
@synthesize positionLable;
@synthesize showMap;
@synthesize profileNameButton;
@synthesize profileNameLable;
@synthesize profileImage;
@synthesize shadowBackground;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if(self)
    {
        self.autoresizesSubviews = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor colorWithRed:65/ 255.f green:77/ 255.f blue:86/ 255.f alpha:1.0];
    }
    return self;
}

-(void) configurateProfileImage
{
    self.profileImage.layer.cornerRadius = 3.0;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderWidth = 1.0;
    
    UIView* shadowView = [[UIView alloc] init];
    shadowView.layer.cornerRadius = 3.0;
    shadowView.layer.shadowColor = [UIColor colorWithRed:22/ 255.f green:28/ 255.f blue:31/ 255.f alpha:1.0].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadowView.layer.shadowOpacity = 0.9f;
    shadowView.layer.shadowRadius = 3.0f;
    [shadowView addSubview:self.profileImage];
    
    [self addSubview:shadowView];
    [shadowView release];
}

-(void) updateProfileImage: (UIImage* )image
{
    self.profileImage.image = image;
    [self configurateProfileImage];
}

-(void) moveSubview: (UIView*) subView onValue: (CGFloat) value 
{
    CGRect viewFrame = subView.frame;
    viewFrame.origin.y = value;
    subView.frame = viewFrame;
}

- (CGFloat) desideSize
{
    return navImage.frame.origin.y + navImage.frame.size.height;
}

-(void) updateComponentsLayoutWithCommentViewHeight: (CGFloat) height
{    
    CGRect profileNameLableFrame = self.profileNameLable.frame;
    profileNameLableFrame.size = [self.profileNameLable.text sizeWithFont:self.profileNameLable.font];
    self.profileNameButton.frame = profileNameLableFrame;
  
    
    CGRect commentFrame = commentMessage.frame;
    commentFrame.size.height = height;
    commentMessage.frame = commentFrame;
    
    if(showMap){
        [self moveSubview: shadowBackground onValue: commentMessage.frame.origin.y + commentMessage.frame.size.height];
        [self moveSubview: mapOfUserLocation onValue: commentMessage.frame.origin.y + commentMessage.frame.size.height + VIEW_OFSET_SIZE];
        [self moveSubview: navImage onValue: mapOfUserLocation.frame.origin.y + mapOfUserLocation.frame.size.height + GEO_LABLE_OFSSET];
        [self moveSubview: positionLable onValue: mapOfUserLocation.frame.origin.y + mapOfUserLocation.frame.size.height + GEO_LABLE_OFSSET]; 
    }
    else {
        [self.mapOfUserLocation removeFromSuperview];
        self.mapOfUserLocation = nil;
        
        [self moveSubview: shadowBackground onValue: commentMessage.frame.origin.y + commentMessage.frame.size.height];
        [self moveSubview: navImage onValue: commentMessage.frame.origin.y + commentMessage.frame.size.height + VIEW_OFSET_SIZE];
        [self moveSubview: positionLable onValue: commentMessage.frame.origin.y + commentMessage.frame.size.height + VIEW_OFSET_SIZE];   
    }
    
    CGFloat newHeight = [self desideSize];
    
    if(newHeight > self.frame.size.height){
        
        CGRect selfFrame = self.frame;
        selfFrame.size.height = newHeight + VIEW_OFSET_SIZE;
        self.contentSize = selfFrame.size;
        
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *output = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"wrapper\").offsetHeight;"];
    [self updateComponentsLayoutWithCommentViewHeight: [output floatValue]];
}

- (void)dealloc
{
    commentMessage.delegate = nil;
    [commentMessage release]; commentMessage = nil;
    [mapOfUserLocation release]; mapOfUserLocation = nil;
    [navImage release]; navImage = nil;
    [profileNameButton release]; profileNameButton = nil;
    [positionLable release]; positionLable = nil;
    [profileNameLable release]; profileNameLable = nil;
    [profileImage release]; profileImage = nil;
    [shadowBackground release]; shadowBackground = nil;
    
    [super dealloc];
}

@end
