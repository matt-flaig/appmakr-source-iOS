
#import "HTMLEntitiesConverter.h"

@implementation HTMLEntitiesConverter

static NSMutableDictionary *knownEntities;

- (id)init
{
	if([super init]) {
		
		if(!knownEntities)
		{
			knownEntities = [[NSMutableDictionary alloc] init];
			[knownEntities setObject:@"&" forKey:@"&#038;"];
			[knownEntities setObject:@"'" forKey:@"&#039;"];
			[knownEntities setObject:@"\"" forKey:@"&#34;"];
			[knownEntities setObject:@"&" forKey:@"&#38;"];
			[knownEntities setObject:@"'" forKey:@"&#39;"];
			[knownEntities setObject:@"<" forKey:@"&#60;"];
			[knownEntities setObject:@">" forKey:@"&#62;"];
			[knownEntities setObject:@"|" forKey:@"&#124;"];
			[knownEntities setObject:@" " forKey:@"&#160;"];
			[knownEntities setObject:@"©" forKey:@"&#169;"];
			[knownEntities setObject:@"Ä" forKey:@"&#196;"];
			[knownEntities setObject:@"×" forKey:@"&#215;"];
			[knownEntities setObject:@"Ü" forKey:@"&#220;"];
			[knownEntities setObject:@"ß" forKey:@"&#223;"];
			[knownEntities setObject:@"ä" forKey:@"&#228;"];
			[knownEntities setObject:@"é" forKey:@"&#233;"];
			[knownEntities setObject:@"ö" forKey:@"&#246;"];
			[knownEntities setObject:@"ü" forKey:@"&#252;"];
			[knownEntities setObject:@"'" forKey:@"&#8217;"];
			[knownEntities setObject:@"–" forKey:@"&#8211;"];
			[knownEntities setObject:@"—" forKey:@"&#8212;"];
			[knownEntities setObject:@"“" forKey:@"&#8220;"];
			[knownEntities setObject:@"\"" forKey:@"&#8221;"];
			[knownEntities setObject:@"…" forKey:@"&#8230;"];
			[knownEntities setObject:@"″" forKey:@"&#8243;"];
			[knownEntities setObject:@"" forKey:@"&#8820;"];
			[knownEntities setObject:@"" forKey:@"&#8821;"];
			[knownEntities setObject:@"á" forKey:@"&aacute;"];
			[knownEntities setObject:@"Á" forKey:@"&Aacute;"];
			[knownEntities setObject:@"â" forKey:@"&acirc;"];
			[knownEntities setObject:@"à" forKey:@"&agrave;"];
			[knownEntities setObject:@"À" forKey:@"&Agrave;"];
			[knownEntities setObject:@"" forKey:@"&amp;"];
			[knownEntities setObject:@"'" forKey:@"&apos;"];
			[knownEntities setObject:@"ã" forKey:@"&atilde;"];
			[knownEntities setObject:@"ç" forKey:@"&ccedil;"];
			[knownEntities setObject:@"©" forKey:@"&copy;"];
			[knownEntities setObject:@"•" forKey:@"&bull;"];
			[knownEntities setObject:@"°" forKey:@"&deg;"];
			[knownEntities setObject:@"é" forKey:@"&eacute;"];
			[knownEntities setObject:@"É" forKey:@"&Eacute;"];
			[knownEntities setObject:@"ê" forKey:@"&ecirc;"];
			[knownEntities setObject:@"€" forKey:@"&euro;"];
			[knownEntities setObject:@">" forKey:@"&gt;"];
			[knownEntities setObject:@"…" forKey:@"&hellip;"];
			[knownEntities setObject:@"í" forKey:@"&iacute;"];
			[knownEntities setObject:@"Í" forKey:@"&Iacute;"];
			[knownEntities setObject:@"¿" forKey:@"&iquest;"];
			[knownEntities setObject:@"«" forKey:@"&laquo;"];
			[knownEntities setObject:@"“" forKey:@"&ldquo;"];
			[knownEntities setObject:@"‘" forKey:@"&lsquo;"];
			[knownEntities setObject:@"<" forKey:@"&lt;"];
			[knownEntities setObject:@"—" forKey:@"&mdash;"];
			[knownEntities setObject:@"·" forKey:@"&middot;"];
			[knownEntities setObject:@" " forKey:@"&nbsp;"];
			[knownEntities setObject:@"-" forKey:@"&ndash;"];
			[knownEntities setObject:@"ñ" forKey:@"&ntilde;"];
			[knownEntities setObject:@"ó" forKey:@"&oacute;"];
			[knownEntities setObject:@"ô" forKey:@"&ocirc;"];
			[knownEntities setObject:@"ª" forKey:@"&ordf;"];
			[knownEntities setObject:@"º" forKey:@"&ordm;"];
			[knownEntities setObject:@"õ" forKey:@"&otilde;"];
			[knownEntities setObject:@"£" forKey:@"&pound;"];
			[knownEntities setObject:@"\"" forKey:@"&quot;"];
			[knownEntities setObject:@"»" forKey:@"&raquo;"];
			[knownEntities setObject:@"”" forKey:@"&rdquo;"];
			[knownEntities setObject:@"'" forKey:@"&rsquo;"];
			[knownEntities setObject:@"§" forKey:@"&sect;"];
			[knownEntities setObject:@"-" forKey:@"&shy;"];
			[knownEntities setObject:@"∑" forKey:@"&sum;"];
			[knownEntities setObject:@"\n" forKey:@"&#13;"];
			[knownEntities setObject:@"ú" forKey:@"&uacute;"];
			[knownEntities setObject:@"" forKey:@"<p>"];
			[knownEntities setObject:@"\n\n" forKey:@"</p>\n"];
			[knownEntities setObject:@"\n\n" forKey:@"</p>"];
		}
	}
	return self;
}

- (NSString*)convertEntiesInString:(NSString*)s {
	if(s == nil) {
		//DebugLog(@"String is nil in HTMLEntitiesConverter");
	}
	
	//fixed image tags that aren't closed properly
	s = [s stringByReplacingOccurrencesOfRegex:@"<img\\\\s+([^>]*\\\\s*[^/])\\\\s*>" withString:@"<img $1 />" options:RKLCaseless range:NSMakeRange(0, [s length]) error:nil];
	///////////////////////////////////////////////
	
	NSArray *entities = [s componentsMatchedByRegex:@"&[#a-zA-Z0-9]*;"];
	NSSet *entitySet = [NSSet setWithArray:entities];
	
	for(NSString *entity in entitySet) {
		if([knownEntities objectForKey:entity]){
			s = [s stringByReplacingOccurrencesOfString:entity withString:[knownEntities objectForKey:entity]];			
		}
		else{
			NSLog(@"Please add this entity to our dictionary: %@",entity);
		}
	}
	
	return s; 
}

- (void)dealloc {
	[super dealloc];
}
@end
