//
//  Media.h
//  Blocstagram
//
//  Created by Samuel Shih on 2/2/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LikeButton.h"

// Creating Enumeration to Track Fail Downloads

typedef NS_ENUM(NSInteger, MediaDownloadState) {

    MediaDownloadStateNeedsImage = 0,
    MediaDownloadStateDownloadInProgress = 1,
    MediaDownloadStateNonRecoverableError = 2,
    MediaDownloadStateHasImage =3

};

@class User;

// Media posts that users will post
@interface Media : NSObject <NSCoding>

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, assign) MediaDownloadState downloadState;

@property (nonatomic, assign) LikeState likeState;
@property (nonatomic, assign) NSNumber *numberOfLikes;

@property (nonatomic, strong) NSString *temporaryComment;


- (instancetype) initWithDictionary:(NSDictionary *) mediaDictionary;

@end
