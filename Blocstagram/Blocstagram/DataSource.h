//
//  DataSource.h
//  Blocstagram
//
//  Created by Samuel Shih on 2/2/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

@interface DataSource : NSObject

// We want to be able to access this data anywhere so it is a shared instance type
// Following the Singleton pattern
+ (instancetype) sharedInstance;

// Read only so other classes can't modify it
@property (nonatomic, strong, readonly) NSArray *mediaItems;

- (void) deleteMediaItem:(Media *)item;

@end
