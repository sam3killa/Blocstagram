//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Samuel Shih on 3/14/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) Media *media;


- (instancetype) initWithMedia:(Media *)media;

- (void) recalculateZoomScale;

- (void) centerScrollView;

@end
