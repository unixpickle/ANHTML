//
//  ANHTMLDocument.h
//  ANHTML
//
//  Created by Alex Nichol on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANHTMLParser.h"
#import "ANHTMLElement.h"
#import "ANHTMLTextNode.h"

typedef enum {
	ANHTMLDocumentParseAutocloseTags = 1
} ANHTMLDocumentParseFlags;

typedef enum {
	ANHTMLAutocloseStrictnessImmediately = 1,
	ANHTMLAutocloseStrictnessChild = 2,
	ANHTMLAutocloseStrictnessAny = 3
} ANHTMLAutocloseStrictness;

@interface ANHTMLDocument : NSObject <ANHTMLParserDelegate> {
	ANHTMLParser * parser;
	ANHTMLElement * rootElement;
	ANHTMLElement * currentElement;
	ANHTMLDocumentParseFlags parseFlags;
}

- (id)initWithDocumentData:(NSData *)documentData;
- (id)initWithDocumentData:(NSData *)documentData flags:(ANHTMLDocumentParseFlags)flags;
- (id)initWithDocumentString:(NSString *)documentString flags:(ANHTMLDocumentParseFlags)flags;

- (ANHTMLElement *)rootElement;

@end
