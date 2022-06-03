//
//  TestView.m
//  appbuildr
//
//  Created by Admin  on 3/23/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "TestView.h"


@implementation TestView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (id)retain{
    DebugLog(@"retain just sent %@", self);
    DebugLog(@"the retain count befire rettaining %d", [self retainCount]);
    return [super retain];
    
    
}

- (oneway void)release{
    DebugLog(@"release just sent %@", self);
    DebugLog(@"the retain count befire release %d", [self retainCount]);
    [super release];
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
    DebugLog(@"Deallocating bitches %@", self);
    [super dealloc];
}

@end
