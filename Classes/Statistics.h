//
//  Statistics.h
//  appbuildr
//
//  Created by William Johnson on 3/14/11.
//  Copyright (c) 2011 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry;

@interface Statistics : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * hasNewComment;
@property (nonatomic, retain) NSNumber * isLastLikeCountRequestSuccess;
@property (nonatomic, retain) NSNumber * numberOfViews;
@property (nonatomic, retain) NSNumber * numberOfLikes;
@property (nonatomic, retain) NSNumber * numberOfComments;
@property (nonatomic, retain) NSDate * lastCommentDate;
@property (nonatomic, retain) Entry * entry;

@end
