//
//  Comment.m
//  Blocstagram
//
//  Created by Samuel Shih on 2/2/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import "Comment.h"
#import "User.h"

@implementation Comment

- (instancetype) initWithDictionary:(NSDictionary *)commentDictionary {
    self = [super init];
    
    if (self) {
        
        self.idNumber = commentDictionary[@"id"];
        self.text = commentDictionary[@"text"];
        self.from = [[User alloc] initWithDictionary:commentDictionary[@"from"]];
    
    }

    return self;
}

@end
