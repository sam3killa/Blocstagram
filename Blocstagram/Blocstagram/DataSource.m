//
//  DataSource.m
//  Blocstagram
//
//  Created by Samuel Shih on 2/2/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import "DataSource.h"
#import "Comment.h"
#import "Media.h"
#import "User.h"
#import "LoginViewController.h"

// Use "" for local files and <> for external files like pods
#import <UICKeyChainStore.h>
#import <AFNetworking.h>

@interface DataSource () {

// This property can only be modified by the data source
    NSMutableArray *_mediaItems;
    
}

// Each user has their own unique accessToken
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;

@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationManager;


@end

@implementation DataSource

+ (instancetype) sharedInstance {

    // dispatch_once function ensures we only create a single instance of the class
    static dispatch_once_t once;
    
    // static id to hold our shared instance
    static id sharedInstance;
    
    dispatch_once(&once, ^{
    
        sharedInstance = [[self alloc] init];
        
    });
        return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        [self createOperationsManager];
        
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if (!self.accessToken){
            [self registerForAccessTokenNotification];
        } else {

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        _mediaItems = mutableMediaItems;
                        [self didChangeValueForKey:@"mediaItems"];
                        // #1
                        for (Media* mediaItem in self.mediaItems) {
                            [self downloadImageForMediaItem:mediaItem];
                        }
                        
                    } else {
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                });
            });
        
        }
    }
    
    return self;
}

// Create Operations Manager
- (void) createOperationsManager {
    NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
    self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
    AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
    imageSerializer.imageScale = 1.0;
    
    AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
    self.instagramOperationManager.responseSerializer = serializer;


}

- (NSString *) pathForFilename:(NSString *) filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}


- (void) registerForAccessTokenNotification {
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
       
        self.accessToken = note.object;
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
        [self populateDataWithParameters:nil completionHandler:nil];
    }];
}

// Let instagram know who is calling their api
+ (NSString *) instagramClientID {
    return @"0a418c2844794c51ad46b3c5aabfa2e5";
}

#pragma mark - Key/Value Observing

- (NSUInteger) countOfMediaItems {

    return self.mediaItems.count;
    
}

- (id) objectInmediaItemsAtIndex:(NSUInteger)index {
    
    return [self.mediaItems objectAtIndex:index];
    
}

- (NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    
    return [self.mediaItems objectsAtIndexes:indexes];
    
}


- (void) insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index {

    [_mediaItems insertObject:object atIndex:index];

}

- (void) deleteMediaItem:(Media *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}

- (void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    
    [_mediaItems removeObjectAtIndex:index];
    
}

- (void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {

    [_mediaItems replaceObjectAtIndex:index withObject:object];
    
}

// Request New Items Method
- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler{
    
    self.thereAreNoMoreOlderMessages = NO;
    
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        NSDictionary *parameters;
        
        if (minID) {
            parameters = @{@"min_id": minID};
        }
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    
    }

}

- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.accessToken) {
        // only try to get the data if there's an access token
        
        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy];
        
        [mutableParameters addEntriesFromDictionary:parameters];
        
        [self.instagramOperationManager GET:@"users/self/feed"
                                 parameters:mutableParameters
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                            [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                                        }
                                        
                                        if (completionHandler) {
                                            completionHandler(nil);
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        if (completionHandler) {
                                            completionHandler(error);
                                        }
                                    }];
    }
}

// Method will convert the data into usable data to display in the app.
- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {

    NSArray *mediaArray = feedDictionary[@"data"];

    NSMutableArray *tmpMediaItems = [NSMutableArray array];

    for (NSDictionary *mediaDictionary in mediaArray) {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
    
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
            [self downloadImageForMediaItem:mediaItem];
        }
    
    }
    
    // Informs the key-value observation system that the mediaItems will be replaced
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        // This was a pull-to-refresh request
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
        
    }
    else if (parameters[@"max_id"]) {
        // This was an infinite scroll request
        
        if (tmpMediaItems.count == 0) {
            // disable infinite scroll, since there are no more older messages
            self.thereAreNoMoreOlderMessages = YES;
        } else {
            [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
        }}
    
    else {
        [self willChangeValueForKey:@"mediaItems"];
        _mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    [self saveImages];
}

// Save Images to Disk

- (void) saveImages {
    
    if (self.mediaItems.count > 0) {
        // Write the changes to disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            
            NSError *dataError;
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
        });
        
    }
}

// Request Old Items
- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    
    
    if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO) {

        NSString *maxID = [[self.mediaItems lastObject] idNumber];
        NSDictionary *parameters;
        
        self.isLoadingOlderItems = NO;
        
        if (maxID) {
            parameters = @{@"max_id": maxID};
        }
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isLoadingOlderItems = NO;
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}

// Method to download image for a media item
- (void) downloadImageForMediaItem: (Media *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) {
        [self.instagramOperationManager GET:mediaItem.mediaURL.absoluteString
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[UIImage class]]) {
                                            mediaItem.image = responseObject;
                                            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                                            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                                            if (index != NSNotFound) {
                                                [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                                            }
                                        }
                                        
                                        [self saveImages];
                                        
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error downloading image: %@", error);
                                    }];
    }
}



@end
