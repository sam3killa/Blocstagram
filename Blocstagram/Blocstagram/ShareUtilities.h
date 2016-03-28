//
//  ShareUtilities.h
//  Blocstagram
//
//  Created by Samuel Shih on 3/17/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import <Foundation/Foundation.h>

// We're not importing the files of these classes but just saying that we know these classes exist
@class Media, UIViewController;

@interface ShareUtilities : NSObject

+ (void) shareMediaItem:(Media *)mediaItem viewController:(UIViewController *)vc;


@end
