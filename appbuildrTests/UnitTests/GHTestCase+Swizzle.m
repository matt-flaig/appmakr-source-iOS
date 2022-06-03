#import <GHUnitIOS/GHUnit.h>
#import "GHTestCase+Swizzle.h"


@implementation SwizzleSelector
@synthesize swizzleMethod = _swizzleMethod;
@synthesize originalMethod = _originalMethod;

-(void) dealloc
{
    self.swizzleMethod = nil;
    self.originalMethod = nil;
    [super dealloc];
}

- (void)deswizzle
{
	method_exchangeImplementations(self.swizzleMethod, self.originalMethod);    
}

@end

@implementation GHTestCase (Swizzle)

- (SwizzleSelector*)swizzle:(Class)target_class selector:(SEL)selector
{
    SwizzleSelector* ss = [SwizzleSelector new];
	ss.originalMethod = class_getClassMethod(target_class, selector);
	ss.swizzleMethod = class_getInstanceMethod([self class], selector);
	method_exchangeImplementations(ss.originalMethod, ss.swizzleMethod);
    return [ss autorelease];
}

@end
