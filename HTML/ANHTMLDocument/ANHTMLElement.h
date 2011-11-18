//
//  ANHTMLElement.h
//  ANHTML
//
//  Created by Alex Nichol on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANHTMLNode.h"
#import "ANHTMLAttributes.h"

@interface ANHTMLElement : ANHTMLNode {
	ANHTMLAttributes * attributes;
	NSString * elementName;
	NSMutableArray * children;
}

@property (readonly) NSString * elementName;
@property (readonly) ANHTMLAttributes * attributes;
@property (readonly) NSMutableArray * children;

- (id)initWithElementName:(NSString *)theName attributes:(ANHTMLAttributes *)theAttributes;

- (BOOL)compareName:(NSString *)aName;

- (NSUInteger)numberOfChildren;
- (ANHTMLNode *)childAtIndex:(NSUInteger)index;

- (NSArray *)childElementsWithName:(NSString *)aName;
- (NSArray *)childElementsMatching:(BOOL (^)(ANHTMLElement * elem))predicate;

@end
