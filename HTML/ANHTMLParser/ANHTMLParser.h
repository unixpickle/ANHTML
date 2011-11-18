//
//  ANHTMLParser.h
//  ANHTML
//
//  Created by Alex Nichol on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringFeed.h"

@class ANHTMLParser;

@protocol ANHTMLParserDelegate <NSObject>

- (void)htmlParser:(ANHTMLParser *)parser didStartElement:(NSString *)name attributes:(NSDictionary *)attributes;
- (void)htmlParser:(ANHTMLParser *)parser didEndElement:(NSString *)name;
- (void)htmlParser:(ANHTMLParser *)parser didEncounterPlainText:(NSString *)text;

@optional
- (unichar)htmlParser:(ANHTMLParser *)parser characterForEscapeCode:(NSString *)code;

@end

@interface ANHTMLParser : NSObject {
	StringFeed * feed;
	NSMutableString * plainBuffer;
	
	__unsafe_unretained id<ANHTMLParserDelegate> delegate;
}

@property (nonatomic, assign) id<ANHTMLParserDelegate> delegate;

- (id)initWithDocumentData:(NSData *)data;
- (id)initWithDocumentString:(NSString *)string;

- (void)parse;

@end
