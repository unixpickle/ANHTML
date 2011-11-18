//
//  ANHTMLElement.m
//  ANHTML
//
//  Created by Alex Nichol on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANHTMLElement.h"

@implementation ANHTMLElement

@synthesize elementName;
@synthesize attributes;
@synthesize children;

- (id)initWithElementName:(NSString *)theName attributes:(ANHTMLAttributes *)theAttributes {
	if ((self = [super init])) {
		elementName = theName;
		attributes = theAttributes;
		children = [[NSMutableArray alloc] init];
	}
	return self;
}

- (BOOL)compareName:(NSString *)aName {
	return [elementName caseInsensitiveCompare:aName] == NSOrderedSame;
}

#pragma mark Children Array

- (NSUInteger)numberOfChildren {
	return [children count];
}

- (ANHTMLNode *)childAtIndex:(NSUInteger)index {
	return [children objectAtIndex:index];
}

#pragma mark Children Elements

- (NSArray *)childElementsWithName:(NSString *)aName {
	NSMutableArray * matching = [NSMutableArray array];
	
	for (ANHTMLNode * node in children) {
		if ([node isKindOfClass:[ANHTMLElement class]]) {
			ANHTMLElement * element = (ANHTMLElement *)node;
			if ([element compareName:aName]) {
				[matching addObject:element];
			}
		}
	}
	
	return [matching copy]; // immutable;
}

- (NSArray *)childElementsMatching:(BOOL (^)(ANHTMLElement * elem))predicate {
	NSMutableArray * matching = [NSMutableArray array];
	
	for (ANHTMLNode * node in children) {
		if ([node isKindOfClass:[ANHTMLElement class]]) {
			ANHTMLElement * element = (ANHTMLElement *)node;
			if (predicate(element)) {
				[matching addObject:element];
			}
		}
	}
	
	return [matching copy]; // immutable;
}

#pragma mark String Value

- (NSString *)stringValue {
	NSMutableString * concat = [NSMutableString string];
	for (ANHTMLNode * node in children) {
		[concat appendString:[node stringValue]];
	}
	return concat;
}

@end
