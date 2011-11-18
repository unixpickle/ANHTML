//
//  ANHTMLDocument.m
//  ANHTML
//
//  Created by Alex Nichol on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANHTMLDocument.h"

@interface ANHTMLDocument (Private)

- (void)beginParsing:(ANHTMLDocumentParseFlags)flags;

- (void)closeCurrentElement;
- (void)pushCurrentElement:(ANHTMLElement *)anElement;
- (BOOL)isAutocloseTag:(NSString *)tag circumstance:(ANHTMLAutocloseStrictness)strictness;

@end

@implementation ANHTMLDocument

- (id)initWithDocumentData:(NSData *)documentData {
	self = [self initWithDocumentData:documentData flags:ANHTMLDocumentParseAutocloseTags];
	return self;
}

- (id)initWithDocumentData:(NSData *)documentData flags:(ANHTMLDocumentParseFlags)flags {
	if ((self = [super init])) {
		parser = [[ANHTMLParser alloc] initWithDocumentData:documentData];
		if (!parser) return nil;
		[self beginParsing:flags];
	}
	return self;
}

- (id)initWithDocumentString:(NSString *)documentString flags:(ANHTMLDocumentParseFlags)flags {
	if ((self = [super init])) {
		parser = [[ANHTMLParser alloc] initWithDocumentString:documentString];
		if (!parser) return nil;
		[self beginParsing:flags];
	}
	return self;
}

- (ANHTMLElement *)rootElement {
	return rootElement;
}

#pragma mark - Parsing -

- (void)beginParsing:(ANHTMLDocumentParseFlags)flags {
	parseFlags = flags;
	
	rootElement = [[ANHTMLElement alloc] initWithElementName:@"" attributes:[[ANHTMLAttributes alloc] init]];
	currentElement = rootElement;
	
	[parser setDelegate:self];
	[parser parse];
	
	// We only have a nameless root element for cases where the document
	// does not have a single element as it's root. If it does however have
	// one root element, we can substitute our nameless root element with the
	// singleton sub-element.
	if ([[rootElement children] count] == 1) {
		ANHTMLNode * node = [[rootElement children] lastObject];
		if ([node isKindOfClass:[ANHTMLElement class]]) {
			ANHTMLElement * element = (ANHTMLElement *)node;
			element.parentNode = nil;
			rootElement = element;
		}
	}
}

#pragma mark ANHTMLParserDelegate

- (void)htmlParser:(ANHTMLParser *)parser didStartElement:(NSString *)name attributes:(NSDictionary *)attributes {
	if (currentElement.parentNode) {
		// we might want to close this
		if ([self isAutocloseTag:currentElement.elementName circumstance:ANHTMLAutocloseStrictnessChild]) {
			[self closeCurrentElement];
		}
	}
	ANHTMLAttributes * attributeObj = [[ANHTMLAttributes alloc] initWithAttributeDict:attributes];
	ANHTMLElement * element = [[ANHTMLElement alloc] initWithElementName:name attributes:attributeObj];
	[self pushCurrentElement:element];
	if ([self isAutocloseTag:name circumstance:ANHTMLAutocloseStrictnessImmediately]) {
		[self closeCurrentElement];
	}
}

- (void)htmlParser:(ANHTMLParser *)parser didEndElement:(NSString *)name {
	// find the matching open element, close to that.
	// ideally, this would be currentElement.parentNode
	if ([self isAutocloseTag:name circumstance:ANHTMLAutocloseStrictnessAny]) {
		return;
	}
	
	ANHTMLElement * jumpToClose = currentElement;
	while (![jumpToClose compareName:name]) {
		jumpToClose = jumpToClose.parentNode;
		if (!jumpToClose) return;
	}
	
	currentElement = jumpToClose.parentNode;
}

- (void)htmlParser:(ANHTMLParser *)parser didEncounterPlainText:(NSString *)text {
	ANHTMLTextNode * textNode = [[ANHTMLTextNode alloc] initWithNodeText:text];
	textNode.parentNode = currentElement;
	[[currentElement children] addObject:textNode];
}

- (unichar)htmlParser:(ANHTMLParser *)parser characterForEscapeCode:(NSString *)code {
	if ([code isEqualToString:@"nbsp"]) {
		return ' ';
	}
	return 0;
}

#pragma mark Element Tree

- (void)closeCurrentElement {
	if (currentElement.parentNode) {
		currentElement = (ANHTMLElement *)currentElement.parentNode;
	}
}

- (void)pushCurrentElement:(ANHTMLElement *)anElement {
	anElement.parentNode = currentElement;
	[[currentElement children] addObject:anElement];
	currentElement = anElement;
}

#pragma mark Autoclosing

- (BOOL)isAutocloseTag:(NSString *)tag circumstance:(ANHTMLAutocloseStrictness)strictness {
	const struct {
		__unsafe_unretained NSString * name;
		ANHTMLAutocloseStrictness strictness;
	} closeTags[] = {
		{@"br", ANHTMLAutocloseStrictnessImmediately},
		{@"hr", ANHTMLAutocloseStrictnessImmediately},
		{@"meta", ANHTMLAutocloseStrictnessImmediately},
		{@"img", ANHTMLAutocloseStrictnessImmediately},
		{@"link", ANHTMLAutocloseStrictnessChild}
	};
	const NSUInteger numCloseTags = 5;
	if ((parseFlags & ANHTMLDocumentParseAutocloseTags) != 0) {
		for (NSUInteger i = 0; i < numCloseTags; i++) {
			if ([closeTags[i].name caseInsensitiveCompare:tag] == NSOrderedSame) {
				if (closeTags[i].strictness <= strictness) {
					return YES;
				}
			}
		}
	}
	return NO;
}

@end
