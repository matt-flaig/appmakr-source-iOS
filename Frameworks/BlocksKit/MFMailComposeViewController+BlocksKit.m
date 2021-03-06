//
//  MFMailComposeViewController+BlocksKit.m
//  BlocksKit
//

#import "MFMailComposeViewController+BlocksKit.h"
#import "NSObject+BlocksKit.h"
#import "BKDelegate.h"

static char *kDelegateKey = "AppMakrMFMailComposeViewControllerDelegate";
static char *kCompletionBlockKey = "AppMakrMFMailComposeViewControllerCompletion";

#pragma mark Delegate

@interface BKMailComposeViewControllerDelegate : BKDelegate <MFMailComposeViewControllerDelegate>

@end

@implementation BKMailComposeViewControllerDelegate

+ (Class)targetClass {
    return [MFMailComposeViewController class];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    id delegate = controller.mailComposeDelegate;
    if (delegate && [delegate respondsToSelector:@selector(mailComposeController:didFinishWithResult:error:)])
        [controller.mailComposeDelegate mailComposeController:controller didFinishWithResult:result error:error];
    else
        [controller dismissModalViewControllerAnimated:YES];
        
    BKMailComposeBlock block = controller.completionBlock;
    if (block)
        block(result, error);
}

@end

#pragma mark Category

@implementation MFMailComposeViewController (BlocksKit)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(mailComposeDelegate) withSelector:@selector(AppMakr_bk_mailComposeDelegate)];
        [self swizzleSelector:@selector(setMailComposeDelegate:) withSelector:@selector(AppMakr_bk_setMailComposeDelegate:)];
    });
}

#pragma mark Methods

- (id)AppMakr_bk_mailComposeDelegate {
    return [self associatedValueForKey:kDelegateKey];
}

- (void)AppMakr_bk_setMailComposeDelegate:(id)delegate {
    [self weaklyAssociateValue:delegate withKey:kDelegateKey];
    [self AppMakr_bk_setMailComposeDelegate:[BKMailComposeViewControllerDelegate shared]];
}

#pragma mark Properties

- (BKMailComposeBlock)completionHandler {
    return [self completionBlock];
}

- (void)setCompletionHandler:(BKMailComposeBlock)completionHandler {
    [self setCompletionBlock:completionHandler];
}
 
- (BKMailComposeBlock)completionBlock {
    BKMailComposeBlock block = [self associatedValueForKey:kCompletionBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setCompletionBlock:(BKMailComposeBlock)handler {
    [self AppMakr_bk_setMailComposeDelegate:[BKMailComposeViewControllerDelegate shared]];
    [self associateCopyOfValue:handler withKey:kCompletionBlockKey];
}

@end
