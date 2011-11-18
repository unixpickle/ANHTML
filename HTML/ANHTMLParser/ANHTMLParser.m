//
//  ANHTMLParser.m
//  ANHTML
//
//  Created by Alex Nichol on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANHTMLParser.h"

@interface ANHTMLParser (Private)

- (BOOL)encounteredTagStart;
- (BOOL)readElementAndCallback:(NSString *)elementDeclaration;

- (BOOL)encounteredEscapeStart;
- (NSString *)unescapeAttributeString:(NSString *)escapedString;
- (unichar)readAndUnescapeNext:(StringFeed *)aFeed;

- (void)delegateInformText:(NSString *)theText;
- (void)delegateInformElementStart:(NSString *)tag attributes:(NSDictionary *)attributes;
- (void)delegateInformElementEnd:(NSString *)tag;
- (unichar)delegateGetEscapeValue:(NSString *)eCode;

@end

@implementation ANHTMLParser

@synthesize delegate;

- (id)initWithDocumentData:(NSData *)data {
	if ((self = [super init])) {
		feed = [[StringFeed alloc] initWithStringData:data];
		if (!feed) {
			return nil;
		}
	}
	return self;
}

- (id)initWithDocumentString:(NSString *)string {
	if ((self = [super init])) {
		feed = [[StringFeed alloc] initWithString:string];
		if (!feed) {
			return nil;
		}
	}
	return self;
}

- (void)parse {
	// reset parsing stats
	[feed setOffset:0];
	plainBuffer = [[NSMutableString alloc] init];
	
	while (![feed isFinished]) {
		unichar c = [feed getCharacter];
		if (c == '<') {
			[feed pushCurrentOffset];
			if (![self encounteredTagStart]) {
				[feed restoreOffset];
				[plainBuffer appendFormat:@"%C", c];
			} else {
				[feed skipOffset];
			}
		} else if (c == '&') {
			[feed pushCurrentOffset];
			if (![self encounteredEscapeStart]) {
				[feed restoreOffset];
				[plainBuffer appendFormat:@"%C", c];
			} else {
				[feed skipOffset];
			}
		} else {
			[plainBuffer appendFormat:@"%C", c];
		}
	}
	if ([plainBuffer length] > 0) {
		[self delegateInformText:plainBuffer];
	}
}

#pragma mark - Private -

- (BOOL)encounteredTagStart {
	if ([feed isFinished]) {
		return NO;
	}
	
	// different reasons that a '<' might be in our document
	if ([feed stringFollows:@"/"]) {
		// end of a tag
		[feed skipUntil:@"/"]; // skip the / character
		NSString * tagContent = [feed readUntil:@">" notEncountering:@"<"];
		if (!tagContent) {
			return NO;
		}
		
		// remove trailing whitespace
		NSCharacterSet * whitespace = [NSCharacterSet whitespaceCharacterSet];
		NSString * trimmed = [tagContent stringByTrimmingCharactersInSet:whitespace];
		if ([trimmed length] == 0) return NO;
		
		// remove stuff after first token (e.g. after element name)
		NSRange spaceRange = [trimmed rangeOfCharacterFromSet:whitespace];
		if (spaceRange.location != NSNotFound) {
			trimmed = [trimmed substringWithRange:NSMakeRange(0, spaceRange.location)];
		}
		if ([trimmed length] == 0) return NO;
		
		[self delegateInformElementEnd:trimmed];
		return YES;
	} else if ([feed stringFollows:@"!"]) {
		// comment of some sort
		if ([feed stringFollows:@"!--"]) {
			// long comment
			return [feed skipUntil:@"-->"];
		} else {
			// shorthand comment
			return [feed skipUntil:@">"];
		}
	} else if ([feed stringFollows:@"?"]) {
		// PHP, XML info
		return [feed skipUntil:@"?>"];
	} else {
		// beginning of an element
		NSString * elementDec = [feed readUntil:@">" notEncountering:@"<"];
		if (!elementDec) {
			return NO;
		}
		return [self readElementAndCallback:elementDec];
	}
	
}

- (BOOL)readElementAndCallback:(NSString *)elementDeclaration {
	NSCharacterSet * whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	
	StringFeed * elemFeed = [[StringFeed alloc] initWithString:elementDeclaration];
	if ([elemFeed isFinished]) return NO;
	
	// read the element name token
	NSString * elementName = [elemFeed readUntilCharacterInSet:whitespace];
	if ([elementName length] == 0) {
		return NO;
	}
	
	NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
	
	// read the attribute tokens
	while (![elemFeed isFinished]) {
		[elemFeed consumeCharactersInSet:whitespace];
		if ([elemFeed isFinished]) break;
		
		NSString * attributeName = [elemFeed readUntil:@"="];
		if (!attributeName) break;
		if (![elemFeed skipUntil:@"\""]) break;
		NSString * attributeValue = [self unescapeAttributeString:[elemFeed readUntil:@"\""]];
		if (!attributeValue) break;
		[attributes setObject:attributeValue forKey:attributeName];
	}
	
	[self delegateInformElementStart:elementName attributes:attributes];
	
	// the <tag ... /> syntax
	if ([[elementDeclaration stringByTrimmingCharactersInSet:whitespace] hasSuffix:@"/"]) {
		[self delegateInformElementEnd:elementName];
	}
	
	return YES;
}

#pragma mark Unescaping

- (BOOL)encounteredEscapeStart {
	unichar escapeChar = [self readAndUnescapeNext:feed];
	if (escapeChar == 0) {
		return NO;
	}
	
	[plainBuffer appendFormat:@"%C", escapeChar];
	return YES;
}

- (NSString *)unescapeAttributeString:(NSString *)escapedString {
	if (!escapedString) return nil;
	StringFeed * subFeed = [[StringFeed alloc] initWithString:escapedString];
	NSMutableString * unescaped = [[NSMutableString alloc] init];
	
	while (![subFeed isFinished]) {
		unichar token = [subFeed getCharacter];
		if (token == '&') {
			[subFeed pushCurrentOffset];
			unichar original = [self readAndUnescapeNext:subFeed];
			if (original == 0) {
				[subFeed restoreOffset];
				[unescaped appendFormat:@"%C", token];
			} else {
				[subFeed skipOffset];
				[unescaped appendFormat:@"%C", original];
			}
		} else {
			[unescaped appendFormat:@"%C", token];
		}
	}
	
	return [unescaped copy]; // immutable copy
}

- (unichar)readAndUnescapeNext:(StringFeed *)aFeed {
	NSString * escBody = [aFeed readUntil:@";" notEncountering:@"&"];
	if (!escBody) return 0;
	unichar escapeChar = [self delegateGetEscapeValue:escBody];
	return escapeChar;
}

#pragma mark Delegate Callbacks

- (void)delegateInformText:(NSString *)theText {
	NSCharacterSet * whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSCharacterSet * newLines = [NSCharacterSet newlineCharacterSet];
	
	BOOL isJustSpace = YES;
	// remove instances where there are two spaces in a row,
	// replace with the first space only, deleting the second.
	NSMutableString * noRepeats = [[theText stringByTrimmingCharactersInSet:newLines] mutableCopy];
	for (NSInteger i = 0; i < (NSInteger)[noRepeats length] - 1; i++) {
		unichar current = [noRepeats characterAtIndex:i];
		unichar next = [noRepeats characterAtIndex:i + 1];
		if ([whitespace characterIsMember:current]) {
			if ([whitespace characterIsMember:next]) {
				// we have repeating whitespace, remove next character,
				// then set i so that we will check this character again
				// with the next character
				[noRepeats deleteCharactersInRange:NSMakeRange(i + 1, 1)];
				i--;
			} else {
				isJustSpace = NO;
			}
		} else {
			isJustSpace = NO;
		}
	}
	
	if (isJustSpace) return;
	
	[delegate htmlParser:self didEncounterPlainText:[noRepeats copy]]; // immutable copy
}

- (void)delegateInformElementStart:(NSString *)tag attributes:(NSDictionary *)attributes {
	if ([plainBuffer length] > 0) {
		[self delegateInformText:plainBuffer];
		plainBuffer = [[NSMutableString alloc] init];
	}
	[delegate htmlParser:self didStartElement:tag attributes:attributes];
}

- (void)delegateInformElementEnd:(NSString *)tag {
	if ([plainBuffer length] > 0) {
		[self delegateInformText:plainBuffer];
		plainBuffer = [[NSMutableString alloc] init];
	}
	[delegate htmlParser:self didEndElement:tag];
}

- (unichar)delegateGetEscapeValue:(NSString *)eCode {
	if (![delegate respondsToSelector:@selector(htmlParser:characterForEscapeCode:)]) {
		return 0;
	}
	return [delegate htmlParser:self characterForEscapeCode:eCode];
}

@end
