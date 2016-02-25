//
//  DataSource.h
//  Blocstagram
//
//  Created by Samuel Shih on 2/2/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface DataSource : NSObject

// We want to be able to access this data anywhere so it is a shared instance type
// Following the Singleton pattern
+ (instancetype) sharedInstance;

// Storing the client id
+ (NSString *) instagramClientID;

// Read only so other classes can't modify it
@property (nonatomic, strong, readonly) NSMutableArray *mediaItems;
@property (nonatomic, strong, readonly) NSString *accessToken;

- (void) deleteMediaItem:(Media *)item;

- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock) completionHandler;
- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock) completionHandler;

@end
