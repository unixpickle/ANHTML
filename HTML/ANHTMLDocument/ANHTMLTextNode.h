//
//  ANHTMLTextNode.h
//  ANHTML
//
//  Created by Alex Nichol on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANHTMLNode.h"

@interface ANHTMLTextNode : ANHTMLNode {
	NSString * nodeText;
}

@property (readonly) NSString * nodeText;

- (id)initWithNodeText:(NSString *)theText;

@end
