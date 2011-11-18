//
//  ANHTMLAttributes.m
//  ANHTML
//
//  Created by Alex Nichol on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANHTMLAttributes.h"

@implementation ANHTMLAttributes

- (id)init {
	if ((self = [super init])) {
		attributes = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithAttributeDict:(NSDictionary *)attributeDict {
	if ((self = [super init])) {
		attributes = [[NSMutableArray alloc] init];
		for (NSString * name in attributeDict) {
			if ([self attributeForName:name]) {
				return nil;
			}
			NSString * value = [attributeDict objectForKey:name];
			[attributes addObject:[ANHTMLAttribute attributeWithName:name value:value]];
		}
	}
	return self;
}

#pragma mark Accessing Attributes

- (ANHTMLAttribute *)attributeForName:(NSString *)aName {
	for (ANHTMLAttribute * attribute in attributes) {
		if ([attribute compareName:aName]) {
			return attribute;
		}
	}
	return nil;
}

- (void)removeAttributeForName:(NSString *)attributeName {
	ANHTMLAttribute * attribute = [self attributeForName:attributeName];
	if (attribute) {
		[attributes removeObject:attribute];
	}
}

- (void)setValue:(NSString *)value forAttributeName:(NSString *)attributeName {
	ANHTMLAttribute * attribute = [self attributeForName:attributeName];
	if (attribute) {
		[attributes removeObject:attribute];
	}
	[attributes addObject:[ANHTMLAttribute attributeWithName:value value:attributeName]];
}

#pragma mark Objective-C Representations

- (NSArray *)attributeNames {
	NSMutableArray * mutableNames = [NSMutableArray array];
	for (ANHTMLAttribute * attribute in attributes) {
		[mutableNames addObject:attribute.attributeName];
	}
	return [mutableNames copy]; // immutable copy
}

- (NSDictionary *)dictionaryRepresentation {
	NSMutableDictionary * mutableDict = [NSMutableDictionary dictionary];
	for (ANHTMLAttribute * attribute in attributes) {
		[mutableDict setObject:attribute.attributeValue forKey:attribute.attributeName];
	}
	return [mutableDict copy]; // immutable copy
}

@end
