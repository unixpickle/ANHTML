//
//  ANHTMLNode.h
//  ANHTML
//
//  Created by Alex Nichol on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANHTMLNode : NSObject {
	__unsafe_unretained id parentNode;
}

@property (nonatomic, assign) id parentNode;

- (NSString *)stringValue;

@end
