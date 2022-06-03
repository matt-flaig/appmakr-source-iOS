//
//  GHTestCase+Swizzle.h
//  appbuildr
//
//  Created by Sergey Popenko on 11/15/11.
//  Copyright (c) 2011 pointabout. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <objc/runtime.h>

@interface SwizzleSelector : NSObject

@property(nonatomic) Method originalMethod;
@property(nonatomic) Method swizzleMethod;

- (void)deswizzle;

@end

@interface GHTestCase (Swizzle)

- (SwizzleSelector*)swizzle:(Class)target_class selector:(SEL)selector;

@end
