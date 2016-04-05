//
//  MediaTableCell.h
//  Blocstagram
//
//  Created by Samuel Shih on 2/3/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

// Add the media class
@class Media, MediaTableCell;

@protocol MediaTableCellDelegate <NSObject>

- (void) cell:(MediaTableCell *)cell didTapImageView:(UIImageView *)imageView;
- (void) cell:(MediaTableCell *)cell didLongPressImageView:(UIImageView *)imageView;
- (void) cell:(MediaTableCell *)cell didTapWithTwoFingers:(UIImageView *)imageView;
- (void) cellDidPressLikeButton:(MediaTableCell *)cell;


@end

@interface MediaTableCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;
@property (nonatomic, weak) id <MediaTableCellDelegate> delegate;

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

- (Media *) mediaItem;

- (void) setMediaItem:(Media *) mediaItem;

@end
