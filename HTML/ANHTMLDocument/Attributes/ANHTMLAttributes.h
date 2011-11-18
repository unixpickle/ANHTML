//
//  ANHTMLAttributes.h
//  ANHTML
//
//  Created by Alex Nichol on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANHTMLAttribute.h"

@interface ANHTMLAttributes : NSObject {
	NSMutableArray * attributes;
}

- (id)initWithAttributeDict:(NSDictionary *)attributeDict;

- (ANHTMLAttribute *)attributeForName:(NSString *)aName;
- (void)removeAttributeForName:(NSString *)attributeName;
- (void)setValue:(NSString *)value forAttributeName:(NSString *)attributeName;

- (NSArray *)attributeNames;
- (NSDictionary *)dictionaryRepresentation;

@end
