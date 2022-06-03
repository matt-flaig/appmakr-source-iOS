//
//  ImageData+Extensions.m
//  
//
//  Copyright 2010 PointAbout. All rights reserved.
//

#import "ImageReference+Extensions.h"
#import "NSFileManager+Paths.h"


const float kImageCompressionFactor = 1;	// 0 = most compressed, 1 = least compressed

@implementation ImageReference(Extensions)


- (NSURL*) URL{
	NSURL* result = [NSURL URLWithString:self.URLString];
	if (result == nil && self.URLString != nil)
		NSLog(@"image has invalid URL '%@'", self.URLString);
	return result;
}

- (UIImage*) ImageObject{
	NSString* path = [[NSFileManager defaultManager] pathForAppData:[NSString stringWithFormat:@"images/%@",self.fileName]];
	return [UIImage imageWithContentsOfFile:path];
}

- (BOOL) saveImage:(UIImage*)image{
	NSData* data = UIImageJPEGRepresentation(image, kImageCompressionFactor);
	if (data == nil)
		return NO;

	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* fileName = self.fileName;
	
	NSString* path = [fileManager pathForAppData:@"images"];
 
	NSError* error = nil;
	
    BOOL success = YES;
	if (![fileManager fileExistsAtPath:path]) 
	{
		success = [fileManager createDirectoryAtPath:path  withIntermediateDirectories:FALSE 
										  attributes:nil error:&error];
	}
	
	if (!success)
		return NO;
	
	path = [path stringByAppendingPathComponent:fileName];
	
	if ([fileManager fileExistsAtPath:path]){
		
		[fileManager removeItemAtPath:path error:&error];
		if (error)
		{
			NSLog(@"%@-failed to delete file '%@'", [error localizedDescription], fileName);
			return NO;
		}
	}	
	BOOL result = [data writeToFile:path atomically:YES];

	
	return result;
}

- (BOOL) deleteImage
{
    NSLog(@"%@", self.URLString);
    
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* fileName = self.fileName;
	NSString* path = [fileManager pathForAppData:[NSString stringWithFormat:@"images/%@",fileName]];
	if (path == nil)
		return NO;
	
	if ([fileManager fileExistsAtPath:path])
	{
		NSError* error = nil;
		[fileManager removeItemAtPath:path error:&error];
		if (error)
		{
		 	NSLog(@"%@-failed to delete file '%@'", [error localizedDescription], fileName);
			return NO;
		}
		else 
		{
			self.fileName = nil;
			self.URLString = nil;
		}

	}	

	return YES;
}

- (void)didSave
{
	if ([self isDeleted]) 
	{
		[self deleteImage];
	}	
}

@end
