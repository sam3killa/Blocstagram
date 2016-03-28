//
//  ShareUtilities.m
//  Blocstagram
//
//  Created by Samuel Shih on 3/17/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import "ShareUtilities.h"
#import "Media.h"

@implementation ShareUtilities

+ (void) shareMediaItem:(Media *)mediaItem viewController:(UIViewController *)vc {
    
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (mediaItem.caption.length > 0) {
        [itemsToShare addObject:mediaItem.caption];
    }
    
    if (mediaItem.image) {
        [itemsToShare addObject:mediaItem.image];
    }
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        
        [vc presentViewController:activityVC animated:YES completion:nil];
    }
}

@end
