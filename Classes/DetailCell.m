/*
     File: DetailCell.m
 Abstract: 
 Custom table cell used in the main view's table. Capable of displaying in two modes - a "type:name" mode for existing
 data and a "prompt" mode when used as a placeholder for data creation.
 
  Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2008 Apple Inc. All Rights Reserved.
 
 */

#import "DetailCell.h"
#define kFontName				@"Arial"
#define kTextFieldFontSize		18.0

@implementation DetailCell

@synthesize type, name, prompt, promptMode;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialize the labels, their fonts, colors, alignment, and background color.
     /*   type = [[UILabel alloc] initWithFrame:CGRectMake(0,0,240,240)];
        type.font = [UIFont boldSystemFontOfSize:12];
        type.textColor = [UIColor darkGrayColor];
        type.textAlignment = UITextAlignmentRight;
        type.backgroundColor = [UIColor whiteColor]; */
	//	[type textRectForBounds:CGRectMake(0,0,234,380)];
//        [self.contentView addSubview:type];
	}
    return self;
}

- (void)dealloc {
    [type release];
    [name release];
    [prompt release];
    [super dealloc];
}

// Setting the prompt mode to YES hides the type/name labels and shows the prompt label.
- (void)setPromptMode:(BOOL)flag {
    if (flag) {
        type.hidden = YES;
        name.hidden = YES;
        prompt.hidden = NO;
    } else {
        type.hidden = NO;
        name.hidden = NO;
        prompt.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
   
}

// Update the text color of each label when entering and exiting selected mode.
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        name.textColor = [UIColor whiteColor];
        type.textColor = [UIColor whiteColor];
        prompt.textColor = [UIColor whiteColor];
    } else {
        name.textColor = [UIColor blackColor];
        type.textColor = [UIColor darkGrayColor];
        prompt.textColor = [UIColor darkGrayColor];
    }
}

@end
