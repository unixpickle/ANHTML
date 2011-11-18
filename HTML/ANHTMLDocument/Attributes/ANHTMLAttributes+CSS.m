//
//  ANHTMLAttributes+CSS.m
//  ANHTML
//
//  Created by Alex Nichol on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANHTMLAttributes+CSS.h"

@implementation ANHTMLAttributes (CSS)

- (BOOL)cssMatchesClass:(NSString *)aClass {
	NSCharacterSet * whitespace = [NSCharacterSet whitespaceCharacterSet];
	ANHTMLAttribute * attribute = [self attributeForName:@"class"];
	if (!attribute) return NO;
	NSArray * classNames = [[attribute attributeValue] componentsSeparatedByCharactersInSet:whitespace];
	for (NSString * name in classNames) {
		if ([name caseInsensitiveCompare:aClass]) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)cssMatchesID:(NSString *)anID {
	NSCharacterSet * whitespace = [NSCharacterSet whitespaceCharacterSet];
	ANHTMLAttribute * attribute = [self attributeForName:@"id"];
	if (!attribute) return NO;
	NSArray * idNames = [[attribute attributeValue] componentsSeparatedByCharactersInSet:whitespace];
	for (NSString * name in idNames) {
		if ([name caseInsensitiveCompare:anID]) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)cssMatchesSelector:(NSString *)cssSel {
	NSRange hashRange = [cssSel rangeOfString:@"#"];
	if (hashRange.location != NSNotFound) {
		NSString * idName = [cssSel substringFromIndex:hashRange.location + 1];
		return [self cssMatchesID:idName];
	}
	NSRange dotRange = [cssSel rangeOfString:@"."];
	if (dotRange.location != NSNotFound) {
		NSString * className = [cssSel substringFromIndex:dotRange.location + 1];
		return [self cssMatchesClass:className];
	}
	return NO;
}

@end
