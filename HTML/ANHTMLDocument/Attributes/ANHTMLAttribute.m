//
//  ANHTMLAttribute.m
//  ANHTML
//
//  Created by Alex Nichol on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANHTMLAttribute.h"

@implementation ANHTMLAttribute

@synthesize attributeName;
@synthesize attributeValue;

- (id)initWithName:(NSString *)name value:(NSString *)value {
	if ((self = [super init])) {
		attributeName = name;
		attributeValue = value;
	}
	return self;
}

+ (ANHTMLAttribute *)attributeWithName:(NSString *)name value:(NSString *)value {
	return [[ANHTMLAttribute alloc] initWithName:name value:value];
}

- (BOOL)compareName:(NSString *)aName {
	return ([attributeName caseInsensitiveCompare:aName] == NSOrderedSame);
}


@end
