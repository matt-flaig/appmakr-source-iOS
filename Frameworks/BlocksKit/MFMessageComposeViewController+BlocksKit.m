//
//  MFMessageComposeViewController+BlocksKit.m
//  BlocksKit
//

#import "MFMessageComposeViewController+BlocksKit.h"
#import "NSObject+BlocksKit.h"
#import "BKDelegate.h"

static char *kDelegateKey = "AppMarkMFMessageComposeViewControllerDelegate";
static char *kCompletionBlockKey = "AppMakrMFMessageComposeViewControllerCompletion";

#pragma mark Delegate

@interface BKMessageComposeViewControllerDelegate : BKDelegate <MFMessageComposeViewControllerDelegate>

@end

@implementation BKMessageComposeViewControllerDelegate

+ (Class)targetClass {
    return [MFMessageComposeViewController class];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    id delegate = controller.messageComposeDelegate;
    if (delegate && [delegate respondsToSelector:@selector(messageComposeViewController:didFinishWithResult:)])
        [delegate messageComposeViewController:controller didFinishWithResult:result];
    else
        [controller dismissModalViewControllerAnimated:YES];
    
    BKMessageComposeBlock block = controller.completionBlock;
    if (block)
        block(result);
}

@end

#pragma mark Category

@implementation MFMessageComposeViewController (BlocksKit)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(messageComposeDelegate) withSelector:@selector(AppMakr_bk_messageComposeDelegate)];
        [self swizzleSelector:@selector(setMessageComposeDelegate:) withSelector:@selector(AppMakr_bk_setMessageComposeDelegate:)];
    });
}

#pragma mark Methods

- (id)AppMakr_bk_messageComposeDelegate {
    return [self associatedValueForKey:kDelegateKey];
}

- (void)AppMakr_bk_setMessageComposeDelegate:(id)delegate {
    [self weaklyAssociateValue:delegate withKey:kDelegateKey];
    [self AppMakr_bk_setMessageComposeDelegate:[BKMessageComposeViewControllerDelegate shared]];
}

#pragma mark Properties

- (BKMessageComposeBlock)completionHandler {
    return [self completionBlock];
}

- (void)setCompletionHandler:(BKMessageComposeBlock)completionHandler {
    [self setCompletionBlock:completionHandler];
}

- (BKMessageComposeBlock)completionBlock {
    BKMessageComposeBlock block = [self associatedValueForKey:kCompletionBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setCompletionBlock:(BKMessageComposeBlock)handler {
    [self AppMakr_bk_setMessageComposeDelegate:[BKMessageComposeViewControllerDelegate shared]];
    [self associateCopyOfValue:handler withKey:kCompletionBlockKey];
}

@end

