//
//  StringFeed.m
//  ANHTML
//
//  Created by Alex Nichol on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StringFeed.h"

@implementation StringFeed

#pragma mark Initialization

- (id)initWithString:(NSString *)string {
	if ((self = [super init])) {
		if (!string) {
			return nil;
		}
		feedString = string;
		offsetStack = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithStringData:(NSData *)data {
	if ((self = [super init])) {
		const NSStringEncoding encodings[] = {
			NSUTF8StringEncoding,
			NSUTF16StringEncoding,
			NSUTF32StringEncoding,
			NSWindowsCP1252StringEncoding
		};
		const int encodingsSize = 4;
		for (int i = 0; i < encodingsSize; i++) {
			feedString = [[NSString alloc] initWithData:data encoding:encodings[i]];
			if (feedString) break;
		}
		if (!feedString) return nil;
		offsetStack = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithStringData:(NSData *)data encoding:(NSStringEncoding)encoding {
	if ((self = [super init])) {
		feedString = [[NSString alloc] initWithData:data encoding:encoding];
		if (!feedString) {
			return nil;
		}
		offsetStack = [[NSMutableArray alloc] init];
	}
	return self;
}

#pragma mark Length

- (NSUInteger)length {
	return [feedString length];
}

- (BOOL)isFinished {
	return (offset >= [feedString length]);
}

#pragma mark Reading

- (unichar)getCharacter {
	if ([self isFinished]) {
		@throw [NSException exceptionWithName:BufferUnderflowException
									   reason:@"No characters are left to read."
									 userInfo:nil];
	}
	unichar c = [feedString characterAtIndex:offset++];
	return c;
}

- (NSString *)getString:(NSUInteger)length {
	if (offset + length > [feedString length]) {
		@throw [NSException exceptionWithName:BufferUnderflowException
									   reason:@"Less characters are available than the number specified to read."
									 userInfo:nil];
	}
	NSString * str = [feedString substringWithRange:NSMakeRange(offset, length)];
	offset += length;
	return str;
}

#pragma mark - Chunking -

#pragma mark Strings

- (BOOL)stringFollows:(NSString *)aString {
	if (offset + [aString length] > [feedString length]) {
		return NO;
	}
	NSString * following = [feedString substringWithRange:NSMakeRange(offset, [aString length])];
	return [following isEqualToString:aString];
}

- (NSString *)readUntil:(NSString *)ending {
	NSRange remaining = NSMakeRange(offset, [feedString length] - offset);
	NSRange termRange = [feedString rangeOfString:ending options:0 range:remaining];
	if (termRange.location == NSNotFound) {
		return nil;
	}
	NSString * str = [feedString substringWithRange:NSMakeRange(offset, termRange.location - offset)];
	offset = termRange.location + termRange.length;
	return str;
}

- (BOOL)skipUntil:(NSString *)ending {
	NSRange remaining = NSMakeRange(offset, [feedString length] - offset);
	NSRange termRange = [feedString rangeOfString:ending options:0 range:remaining];
	if (termRange.location == NSNotFound) {
		return NO;
	}
	offset = termRange.location + termRange.length;
	return YES;
}

- (NSString *)readUntil:(NSString *)ending notEncountering:(NSString *)invalidStr {
	NSRange remaining = NSMakeRange(offset, [feedString length] - offset);
	NSRange termRange = [feedString rangeOfString:ending options:0 range:remaining];
	NSRange invalidRange = [feedString rangeOfString:invalidStr options:0 range:remaining];
	if (termRange.location == NSNotFound) {
		return nil;
	}
	if (invalidRange.location != NSNotFound && invalidRange.location < termRange.location) {
		// found invalid string, therefore the read was faulty
		return nil;
	}
	NSString * str = [feedString substringWithRange:NSMakeRange(offset, termRange.location - offset)];
	offset = termRange.location + termRange.length;
	return str;
}

#pragma mark Character Sets

- (NSString *)readUntilCharacterInSet:(NSCharacterSet *)charSet {
	NSMutableString * builtString = [NSMutableString string];
	
	while (![self isFinished]) {
		unichar token = [self getCharacter];
		if ([charSet characterIsMember:token]) {
			break;
		}
		[builtString appendFormat:@"%C", token];
	}
	
	return [builtString copy]; // immutable copy
}

- (void)skipUntilCharacterInSet:(NSCharacterSet *)charSet {
	while (![self isFinished]) {
		unichar token = [self getCharacter];
		if ([charSet characterIsMember:token]) {
			return;
		}
	}
}

- (void)consumeCharactersInSet:(NSCharacterSet *)charSet {
	while (![self isFinished]) {
		unichar token = [self getCharacter];
		if (![charSet characterIsMember:token]) {
			offset--;
			return;
		}
	}
}

#pragma mark - Offsets -

#pragma mark Offset Property

- (NSUInteger)offset {
	return offset;
}

- (void)setOffset:(NSUInteger)_offset {
	if (_offset > [self length]) {
		@throw [NSException exceptionWithName:BufferUnderflowException
									   reason:@"The given offset exceeds the bounds of the buffer"
									 userInfo:nil];
	}
	offset = _offset;
}

#pragma mark Offset Stack

- (void)pushCurrentOffset {
	[offsetStack addObject:[NSNumber numberWithUnsignedInteger:offset]];
}

- (void)restoreOffset {
	if ([offsetStack count] == 0) {
		@throw [NSException exceptionWithName:OffsetStackEmptyException
									   reason:@"Cannot pop from empty stack."
									 userInfo:nil];
	}
	NSNumber * offsetObj = [offsetStack lastObject];
	[offsetStack removeLastObject];
	[self setOffset:[offsetObj unsignedIntegerValue]];
}

- (void)skipOffset {
	if ([offsetStack count] == 0) {
		@throw [NSException exceptionWithName:OffsetStackEmptyException
									   reason:@"Cannot pop from empty stack."
									 userInfo:nil];
	}
	[offsetStack removeLastObject];
}

@end
