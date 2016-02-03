//
//  Comment.h
//  Blocstagram
//
//  Created by Samuel Shih on 2/2/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Comment : NSObject

@property (nonatomic, strong) NSString *idNumber;

@property (nonatomic, strong) User *from;
@property (nonatomic, strong) NSString *text;

@end
