//
//  ANHTMLAttribute.h
//  ANHTML
//
//  Created by Alex Nichol on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANHTMLAttribute : NSObject {
	NSString * attributeName;
	NSString * attributeValue;
}

@property (readonly) NSString * attributeName;
@property (readonly) NSString * attributeValue;

- (id)initWithName:(NSString *)name value:(NSString *)value;
+ (ANHTMLAttribute *)attributeWithName:(NSString *)name value:(NSString *)value;

- (BOOL)compareName:(NSString *)aName;

@end
