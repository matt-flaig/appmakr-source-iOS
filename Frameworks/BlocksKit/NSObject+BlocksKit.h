//
//  NSObject+BlocksKit.h
//  %PROJECT
//

#import "BKGlobals.h"
#import "NSObject+AssociatedObjects.h"

/** Block execution on *any* object.

 This category overhauls the `performSelector:` utilities on
 NSObject to instead use blocks.  Not only are the blocks performed
 extremely speedily, thread-safely, and asynchronously using
 Grand Central Dispatch, but each convenience method also returns
 a pointer that can be used to cancel the execution before it happens!

 Includes code by the following:

 - Peter Steinberger. <https://github.com/steipete>.   2011. MIT.
 - Zach Waldowski.    <https://github.com/zwaldowski>. 2011. MIT.

 */
@interface NSObject (BlocksKit)

/** Executes a block after a given delay on the reciever.

    [array performBlock:^(id obj){
      [obj addObject:self];
      [self release];
    } afterDelay:0.5f];
 
 @warning *Important:* Use of the **self** reference in a block will
 reference the current implementation context.  The block argument,
 `obj`, should be used instead.

 @param block A single-argument code block, where `obj` is the reciever.
 @param delay A measure in seconds.
 @return Returns a pointer to the block that may or may not execute the given block.
 */
- (id)performBlock:(BKSenderBlock)block afterDelay:(NSTimeInterval)delay;

/** Executes a block after a given delay.

 This class method is functionally identical to its instance method version.  It still executes
 asynchronously via GCD.  However, the current context is not passed so that the block is performed
 in a general context.

 Block execution is very useful, particularly for small events that you would like delayed.

    [object performBlock:^(){
      [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    } afterDelay:0.5f];

 @see performBlock:afterDelay:
 @param block A code block.
 @param delay A measure in seconds.
 @return Returns a pointer to the block that may or may not execute the given block.
 */
+ (id)performBlock:(BKBlock)block afterDelay:(NSTimeInterval)delay;

/** Cancels the potential execution of a block.

 @warning *Important:* It is not recommended to cancel a block executed
 with no delay (a delay of 0.0).  While it it still possible to catch the block
 before GCD has executed it, it has likely already been executed and disposed of.

 @param block A pointer to a containing block, as returned from one of the
 `performBlock` selectors.
 */
+ (void)cancelBlock:(id)block;

/** Purely swaps the implementations of two selectors.  No more, no less.

 Both selectors must have existing implementations available to the
 runtime.  If you intend to extend an Apple class, introduce your
 new method using a category.

 After this method is called on a class object, all subsequent
 calls to the original selector will instead trigger the
 new selector.

 This method is used interally by BlocksKit. It is only guaranteed
 to work on iOS and Mac OS 10.6+.  Attempts should not be made to
 use it on any earlier platform.
 
 @param oldSel The name of the original selector.
 @param newSel The name of your new selector.
 */
+ (void)swizzleSelector:(SEL)oldSel withSelector:(SEL)newSel;
+ (void)swizzleClassSelector:(SEL)oldSel withSelector:(SEL)newSel;

@end