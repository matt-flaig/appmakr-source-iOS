//
//  GADDoubleClickParameters.h
//  Google Ads iPhone publisher SDK.
//
//  Copyright 2009 Google Inc. All rights reserved.
//

///////////////////////////////////////////////////////////////////////////////
// DoubleClick ad attributes
///////////////////////////////////////////////////////////////////////////////

// Keyname (required). Example site/zone;kw=keyword;key=value;sz=300x50
extern NSString* const kGADDoubleClickKeyname;

// Size profile. 'xl' - extra large. 'l' - large. 'm' - medium. 's' - small.
// 't' - text. Defaults to 'xl'.
extern NSString* const kGADDoubleClickSizeProfile;

// Override the DoubleClick country. By default, the phone's country setting
// is used to determine the closest DoubleClick servers. Valid values: us, uk,
// fr, jp.
extern NSString* const kGADDoubleClickCountryOverride;

// Background color (used if the ad creative is smaller than the GADAdSize).
// Defaults to FFFFFF.
extern NSString* const kGADDoubleClickBackgroundColor;
