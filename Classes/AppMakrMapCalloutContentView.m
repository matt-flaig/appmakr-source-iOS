//
//  AppMakrMapCalloutContentView.m
//  appbuildr
//
//  Created by Fawad Haider  on 4/20/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "AppMakrMapCalloutContentView.h"
#import <QuartzCore/QuartzCore.h>



@interface AppMakrMapCalloutContentView(private) 
-(void)configurateProfileImage:(UIImageView*)myprofileImageView;
@end

@implementation AppMakrMapCalloutContentView


@synthesize titleLabel, subTitleLabel, profileImageView, iconView;

- (id)initWithFrame:(CGRect)frame imageUrlString:(NSString *)imageUrlString placeholderImage:(UIImage *)placeholderImage subTitleIcon:(UIImage*)subTitleIcon contentType:(CalloutContentType) mycontentType
{
    self = [super initWithFrame:frame];
    if (self) {
        
#define PADDING_TOP 14
#define PADDING_LEFT 14
#define IMAGE_HEIGHT_WIDTH  48
#define IMAGE_HEIGHT_WIDTH_COUNT  49

        contentType = mycontentType;
        profileImageView = [[TCImageView alloc] initWithURL:[NSURL URLWithString:imageUrlString] placeholderImage:placeholderImage];
        profileImageView.caching = YES; // Remove line or change to NO to disable off-line caching
        
        if (imageUrlString)
            [profileImageView loadImage];

       if (mycontentType == CALLOUT_CONTENT){
           titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT + IMAGE_HEIGHT_WIDTH + 10, PADDING_TOP + 2, 200, 20)];
           titleLabel.backgroundColor = [UIColor clearColor]; 
           titleLabel.font = [UIFont boldSystemFontOfSize:14];
           
           
           titleLabel.textColor = [UIColor colorWithRed:217/255.0
                                                  green:225/255.0
                                                   blue:232/255.0
                                                  alpha:1.0];
           
           profileImageView.frame = CGRectMake(PADDING_LEFT, PADDING_TOP, IMAGE_HEIGHT_WIDTH, IMAGE_HEIGHT_WIDTH);
           [self configurateProfileImage:profileImageView]; 
        }
        else if (mycontentType == CALLOUT_ACTIVITY_COUNT){
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT + IMAGE_HEIGHT_WIDTH_COUNT + 10, PADDING_TOP + 14, 200, 20)];
            titleLabel.backgroundColor = [UIColor clearColor]; 
            titleLabel.textColor = [UIColor whiteColor]; 
            titleLabel.font = [UIFont boldSystemFontOfSize:18];
            
            titleLabel.textColor = [UIColor colorWithRed:217/255.0
                                                   green:225/255.0
                                                    blue:232/255.0
                                                   alpha:1.0];
            
            profileImageView.frame = CGRectMake(PADDING_LEFT, PADDING_TOP - 3, IMAGE_HEIGHT_WIDTH_COUNT, IMAGE_HEIGHT_WIDTH_COUNT);
        }
        
        [self addSubview:titleLabel];
        [self addSubview:profileImageView];

        subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT + IMAGE_HEIGHT_WIDTH + 10 + 15 + 2, PADDING_TOP + 20, 200, 20)];
        subTitleLabel.backgroundColor = [UIColor clearColor]; 
        subTitleLabel.font = [UIFont boldSystemFontOfSize:11];
        subTitleLabel.textColor = [UIColor colorWithRed:131/255.0
                                               green:145/255.0
                                                blue:158/255.0
                                               alpha:1.0];
        [self addSubview:subTitleLabel];
        
        if (subTitleLabel){
            iconView = [[UIImageView alloc] init];
            iconView.frame = CGRectMake(PADDING_LEFT + IMAGE_HEIGHT_WIDTH + 10, PADDING_TOP + 23, 15, 15);
            iconView.image = subTitleIcon;
            [self addSubview:iconView];
        }
    }
    return self;
}

-(void)updateCalloutContentType:(CalloutContentType) mycontentType{
    
    contentType = mycontentType;
    if (mycontentType == CALLOUT_CONTENT){
        
        titleLabel.frame = CGRectMake(PADDING_LEFT + IMAGE_HEIGHT_WIDTH + 10, PADDING_TOP + 2, 200, 20);
        titleLabel.backgroundColor = [UIColor clearColor]; 
        titleLabel.textColor = [UIColor whiteColor]; 
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        
        titleLabel.textColor = [UIColor colorWithRed:217/255.0
                                               green:225/255.0
                                                blue:232/255.0
                                               alpha:1.0];
        
        profileImageView.frame = CGRectMake(PADDING_LEFT, PADDING_TOP, IMAGE_HEIGHT_WIDTH, IMAGE_HEIGHT_WIDTH);
        [self configurateProfileImage:profileImageView]; 
    }
    else if (mycontentType == CALLOUT_ACTIVITY_COUNT){
        
        titleLabel.frame = CGRectMake(PADDING_LEFT + IMAGE_HEIGHT_WIDTH_COUNT + 10, PADDING_TOP + 14, 200, 20);
        titleLabel.backgroundColor = [UIColor clearColor]; 
        titleLabel.textColor = [UIColor whiteColor]; 
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        
        titleLabel.textColor = [UIColor colorWithRed:217/255.0
                                               green:225/255.0
                                                blue:232/255.0
                                               alpha:1.0];
        
        profileImageView.frame = CGRectMake(PADDING_LEFT, PADDING_TOP - 3, IMAGE_HEIGHT_WIDTH_COUNT, IMAGE_HEIGHT_WIDTH_COUNT);
        
        if ([profileImageView superview] == shadowView ){
            [[shadowView superview] addSubview:profileImageView];
            [shadowView removeFromSuperview];
            shadowView.hidden = YES;
            [shadowView release];
            profileImageView.layer.borderWidth = 0;
        }
    }
}

-(void)updateProfileImageWithUrlString:(NSString *)imageUrlString placeholderImage:(UIImage *)placeholderImage  {

    if (profileImageView){
        [[profileImageView superview] removeFromSuperview];
        [profileImageView removeFromSuperview];
        [profileImageView release];
        profileImageView = nil;
    }
    
    profileImageView = [[TCImageView alloc] initWithURL:[NSURL URLWithString:imageUrlString] placeholderImage:placeholderImage];
    
    profileImageView.frame = CGRectMake(PADDING_LEFT, PADDING_TOP, IMAGE_HEIGHT_WIDTH, IMAGE_HEIGHT_WIDTH);
    profileImageView.caching = YES; // Remove line or change to NO to disable off-line caching
    
    if (imageUrlString)
        [profileImageView loadImage];

    [self addSubview:profileImageView];
    if (contentType == CALLOUT_CONTENT)
        [self configurateProfileImage:profileImageView]; 
}

-(void)configurateProfileImage:(UIImageView*)myprofileImageView
{
    myprofileImageView.layer.cornerRadius = 3.0;
    myprofileImageView.layer.masksToBounds = YES;
    myprofileImageView.layer.borderWidth = 1.0;
    
    shadowView = [[UIView alloc] init];
    shadowView.layer.cornerRadius = 3.0;
    shadowView.layer.shadowColor = [UIColor colorWithRed:22/ 255.f green:28/ 255.f blue:31/ 255.f alpha:1.0].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadowView.layer.shadowOpacity = 0.9f;
    shadowView.layer.shadowRadius = 3.0f;
    [[myprofileImageView superview] addSubview:shadowView];
    [shadowView addSubview:myprofileImageView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    DebugLog(@"XXX Deallocating AppMakrMapCalloutContentView XXX");
    self.profileImageView = nil;
    self.titleLabel = nil;
    self.subTitleLabel = nil;
    self.iconView = nil;
    [super dealloc];
}

@end
