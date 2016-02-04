//
//  MediaTableCell.h
//  Blocstagram
//
//  Created by Samuel Shih on 2/3/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import <UIKit/UIKit.h>a

// Add the media class
@class Media;

@interface MediaTableCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

- (Media *) mediaItem;

- (void) setMediaItem:(Media *) mediaItem;

@end
