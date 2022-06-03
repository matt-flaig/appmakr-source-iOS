//
//  Link.h
//  appbuildr
//
//  Created by William Johnson on 11/10/10.
//  Copyright 2010 pointabout. All rights reserved.
//

@protocol Link

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * href;
@property (nonatomic, retain) NSString * rel;

@optional
- (BOOL) hasAudio;
- (BOOL) hasVideo;
- (BOOL) hasImage;
@end

@interface Link :  NSManagedObject
{


}
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * href;
@property (nonatomic, retain) NSString * rel;

@end
