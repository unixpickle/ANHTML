//
//  ANHTMLAttributes+CSS.h
//  ANHTML
//
//  Created by Alex Nichol on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANHTMLAttributes.h"

@interface ANHTMLAttributes (CSS)

- (BOOL)cssMatchesClass:(NSString *)aClass;
- (BOOL)cssMatchesID:(NSString *)anID;
- (BOOL)cssMatchesSelector:(NSString *)cssSel;

@end
