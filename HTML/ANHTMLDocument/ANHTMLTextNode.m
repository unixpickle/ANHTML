//
//  ANHTMLTextNode.m
//  ANHTML
//
//  Created by Alex Nichol on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANHTMLTextNode.h"

@implementation ANHTMLTextNode

@synthesize nodeText;

- (id)initWithNodeText:(NSString *)theText {
	if ((self = [super init])) {
		nodeText = theText;
	}
	return self;
}

- (NSString *)stringValue {
	return nodeText;
}

@end
