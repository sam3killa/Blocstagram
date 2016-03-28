//
//  UIViewController+Sharing.h
//  Blocstagram
//
//  Created by Samuel Shih on 3/17/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface UIViewController (Sharing)

- (void) shareMediaItem:(Media *)mediaItem;

@end
