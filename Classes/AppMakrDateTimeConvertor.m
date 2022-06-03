//
//  AppMakrDateTimeConvertor.m
//  appbuildr
//
//  Created by Sergey Popenko on 4/5/12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import "AppMakrDateTimeConvertor.h"
#import "XMPPDateTimeProfiles.h"

@interface NSDate(helper)
    -(NSString*) stringValueWithFormat:(NSString*)format;
@end
@implementation NSDate(helper)

-(NSString*) stringValueWithFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:format];
    [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    return [dateFormatter stringFromDate:self];    
}

@end

@interface NSString(helper)
    -(NSDate*) dateValueFromFormat:(NSString*)format;
@end
@implementation NSString(helper)

-(NSDate*) dateValueFromFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:format];
    [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    return [dateFormatter dateFromString:self];
}

@end

@interface AppMakrDateTimeConvertor()
    @property(nonatomic, retain) NSMutableArray* dateFormatArray;
    -(NSString *)formatDate:(NSString *)dateString withInitialFormat:(NSString *)initialFormat toDestinationFormat:(NSString*)destinationFormat;
@end

@implementation AppMakrDateTimeConvertor
@synthesize destinationFormat = _destinationFormat;
@synthesize dateFormatArray = _dateFormatArray;

-(void)dealloc
{
    [_destinationFormat release];
    [_dateFormatArray release];
    [super dealloc];
}

-(id)initWithDestinationFormat:(NSString*)format
{
    self = [super init];
    if(self)
    {
        self.destinationFormat = format;
        
        self.dateFormatArray = [[[NSMutableArray alloc] initWithCapacity:3] autorelease];
		[self.dateFormatArray addObject:@"EEE, d MMM yyyy HH:mm:ss"];
   		[self.dateFormatArray addObject:@"EEE, d MMM yyyy HH:mm:ss z"];
		[self.dateFormatArray addObject:@"yyyy-MM-dd'T'HH:mm:ssz"]; 
		[self.dateFormatArray addObject:@"yyyy-MM-dd'T'HH:mm:SS"];
   		[self.dateFormatArray addObject:@"EEE, d MMM yyyy h:mm:ss a"];
    }
    return  self;
}

-(NSString*) convertDateTimeString:(NSString*)dtString
{
    return [self convertDateTimeString:dtString toFormat:self.destinationFormat];
}

-(NSString*) convertDateTimeString:(NSString *)dtString toFormat:(NSString*)format
{
    // Search in the predefined templates
    for(NSString *probableInitialDateFormat in self.dateFormatArray) {
        NSString *dateString = [self formatDate:dtString withInitialFormat:probableInitialDateFormat toDestinationFormat:format];
        if(dateString) {
           return dateString;
        }
    }
    
    // Try to convert from W3C notation
    NSDate* date = [XMPPDateTimeProfiles parseDateTime:dtString];    
    return [date stringValueWithFormat:format];
}

-(NSString*)formatDate:(NSString *)dateString withInitialFormat:(NSString *)initialFormat toDestinationFormat:(NSString*)destinationFormat
{
	NSDate *date = [dateString dateValueFromFormat:initialFormat];
	return [date stringValueWithFormat:destinationFormat];
}
@end
