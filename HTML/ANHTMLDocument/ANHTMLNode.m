//
//  ANHTMLNode.m
//  ANHTML
//
//  Created by Alex Nichol on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANHTMLNode.h"

@implementation ANHTMLNode

@synthesize parentNode;

- (NSString *)stringValue {
	[self doesNotRecognizeSelector:@selector(stringValue)];
	return nil;
}

@end
