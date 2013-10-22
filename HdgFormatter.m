//
//  HdgFormatter.m
//  LRotor
//
//  Created by Mike Reublin on 10/21/13.
//
//

#import "HdgFormatter.h"

@interface HdgFormatter ()
- (NSString *) tmpHdg:(NSString *) inHdg;
@end

@implementation HdgFormatter

-(id)init
{
	self = [super init];
	return self;
}

-(NSString *)tmpHdg:(NSString *) inHdg
{
	NSString *small = @"-";
	NSRange arange;
	
	arange = [inHdg rangeOfString:small options:(NSCaseInsensitiveSearch | NSBackwardsSearch)];
	if(arange.location == 0)
	{
		return inHdg;
	}
	else
	{
		return @"";
	}
}
@end
