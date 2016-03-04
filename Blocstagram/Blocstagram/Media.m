//
//  Media.m
//  Blocstagram
//
//  Created by Samuel Shih on 2/2/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import "Media.h"
#import "Comment.h"
#import "User.h"

@implementation Media

- (instancetype) initWithDictionary:(NSDictionary *) mediaDictionary{
    self = [super init];
    
    if (self) {
        
        // Storing the properties into each corresponding attribute
        self.idNumber= mediaDictionary[@"id"];
        self.user = [[User alloc] initWithDictionary:mediaDictionary[@"user"]];
        NSString *standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
        NSURL *standardResolutionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResolutionImageURL) {
        
            self.mediaURL = standardResolutionImageURL;
        }
        
        NSDictionary *captionDictionary = mediaDictionary[@"caption"];
        
        // If Caption is Null
        if ([captionDictionary isKindOfClass:[NSDictionary class]]) {
            self.caption = captionDictionary[@"text"];
        } else {
            self.caption = @"";
        }
        
        NSMutableArray *commentsArray = [NSMutableArray array];
        
        for (NSDictionary *commentDictionary in mediaDictionary[@"comments"][@"data"]) {
            Comment *comment = [[Comment alloc] initWithDictionary:commentDictionary];
            [commentsArray addObject:comment];
        }
        
        self.comments = commentsArray;
    }
    
    
    return self;
}


@end
