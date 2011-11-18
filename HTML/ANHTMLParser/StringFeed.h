//
//  StringFeed.h
//  ANHTML
//
//  Created by Alex Nichol on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OffsetStackEmptyException @"OffsetStackEmptyException"
#define BufferUnderflowException @"BufferUnderflowException"

@interface StringFeed : NSObject {
	NSString * feedString;
	NSUInteger offset;
	NSMutableArray * offsetStack;
}

@property (readwrite) NSUInteger offset;

- (id)initWithString:(NSString *)string;
- (id)initWithStringData:(NSData *)data;
- (id)initWithStringData:(NSData *)data encoding:(NSStringEncoding)encoding;

- (NSUInteger)length;
- (BOOL)isFinished;

- (unichar)getCharacter;
- (NSString *)getString:(NSUInteger)length;

- (BOOL)stringFollows:(NSString *)aString;
- (NSString *)readUntil:(NSString *)ending;
- (BOOL)skipUntil:(NSString *)ending;
- (NSString *)readUntil:(NSString *)ending notEncountering:(NSString *)invalidStr;

- (NSString *)readUntilCharacterInSet:(NSCharacterSet *)charSet;
- (void)skipUntilCharacterInSet:(NSCharacterSet *)charSet;
- (void)consumeCharactersInSet:(NSCharacterSet *)charSet;

- (void)pushCurrentOffset;
- (void)restoreOffset;
- (void)skipOffset;

@end
