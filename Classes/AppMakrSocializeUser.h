//
//  AppMakrSocializeUser.h
//  appbuildr
//
//  Created by William Johnson on 2/1/11.
//  Copyright 2011 PointAbout, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface AppMakrSocializeUser :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * largeImageURL;
@property (nonatomic, retain) NSString * mediumImageURL;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * smallImageURL;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * userDescription;
@property (nonatomic, retain) NSString * lastName;

@end



