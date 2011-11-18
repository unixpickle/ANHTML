//
//  main.m
//  ANHTML
//
//  Created by Alex Nichol on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANHTMLDocument.h"

int main (int argc, const char * argv[]) {
	@autoreleasepool {
		NSData * testData = [@"<html><body><p>This is a basic test</p></body></html>" dataUsingEncoding:NSASCIIStringEncoding];
		ANHTMLDocument * document = [[ANHTMLDocument alloc] initWithDocumentData:testData];
		ANHTMLElement * body = [[[document rootElement] childElementsWithName:@"body"] lastObject];
		NSLog(@"Strings of the document: %@", [body stringValue]);
	}
	return 0;
}

