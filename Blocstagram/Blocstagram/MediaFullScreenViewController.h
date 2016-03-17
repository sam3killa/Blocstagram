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

- (instancetype) initWithMedia:(Media *)media;

- (void) centerScrollView;

@end
