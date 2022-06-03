#import "AccessorizedCalloutMapAnnotationView.h"
#import "BasicMapAnnotationView.h"

@interface AccessorizedCalloutMapAnnotationView()

@property (nonatomic, retain) UIButton *accessory;
@property (nonatomic, retain) UIButton *backGroundButton;
@end

@implementation AccessorizedCalloutMapAnnotationView

@synthesize accessory = _accessory;
@synthesize backGroundButton = _backGroundButton;

- (id) initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
		self.accessory = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage* cellArrawImage = nil;
        cellArrawImage = [UIImage imageNamed:@"/socialize_resources/socialize-activity-call-out-arrow.png"];
        [self.accessory setImage:cellArrawImage  forState:UIControlStateNormal];
		self.accessory.exclusiveTouch = YES;
		self.accessory.enabled = YES;
        
        self.accessory.frame = CGRectMake(300, 150, 12, 18);
		[self.accessory addTarget: self 
						   action: @selector(calloutAccessoryTapped) 
				 forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchCancel];
		[self addSubview:self.accessory];
        
		self.backGroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.backGroundButton.enabled = YES;
        self.backGroundButton.frame   = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        self.backGroundButton.hidden  = NO;
        
		[self.backGroundButton addTarget: self 
						   action: @selector(calloutAccessoryTapped) 
				 forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchCancel];

		[self addSubview:self.backGroundButton];
	}
	return self;
}

- (void)prepareContentFrame {
	CGRect contentFrame = CGRectMake(self.bounds.origin.x + 10, 
									 self.bounds.origin.y + 3, 
									 self.bounds.size.width - 20, 
									 self.contentHeight);
	
	self.contentView.frame = contentFrame;
}

- (void)prepareAccessoryFrame {
	self.accessory.frame = CGRectMake(self.bounds.size.width - self.accessory.frame.size.width - 15, 
									  (self.contentHeight + 3 - self.accessory.frame.size.height) / 2, 
									  self.accessory.frame.size.width, 
									  self.accessory.frame.size.height);
    self.backGroundButton.frame = self.contentView.frame;

}

- (void)didMoveToSuperview {
	[super didMoveToSuperview];
	[self prepareAccessoryFrame];
}

- (void) calloutAccessoryTapped {
	if ([self.mapView.delegate respondsToSelector:@selector(mapView:annotationView:calloutAccessoryControlTapped:)]) {
		[self.mapView.delegate mapView:self.mapView 
						annotationView:self.parentAnnotationView 
		 calloutAccessoryControlTapped:self.accessory];
	}
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	
	UIView *hitView = [super hitTest:point withEvent:event];
	
	//If the accessory is hit, the map view may want to select an annotation sitting below it, so we must disable the other annotations

	//But not the parent because that will screw up the selection
	if ((hitView == self.accessory) || (hitView == self.backGroundButton) ) {
        
		[self preventParentSelectionChange];
		[self performSelector:@selector(allowParentSelectionChange) withObject:nil afterDelay:1.0];
		for (UIView *sibling in self.superview.subviews) {
			if ([sibling isKindOfClass:[MKAnnotationView class]] && sibling != self.parentAnnotationView) {
				((MKAnnotationView *)sibling).enabled = NO;
				[self performSelector:@selector(enableSibling:) withObject:sibling afterDelay:1.0];
			}
		}
	}
	return hitView;
}

- (void) enableSibling:(UIView *)sibling {
	((MKAnnotationView *)sibling).enabled = YES;
}

- (void) preventParentSelectionChange {
	BasicMapAnnotationView *parentView = (BasicMapAnnotationView *)self.parentAnnotationView;
	parentView.preventSelectionChange = YES;
}

- (void) allowParentSelectionChange {
	//The MapView may think it has deselected the pin, so we should re-select it
	[self.mapView selectAnnotation:self.parentAnnotationView.annotation animated:NO];
	
	BasicMapAnnotationView *parentView = (BasicMapAnnotationView *)self.parentAnnotationView;
	parentView.preventSelectionChange = NO;
}

@end
