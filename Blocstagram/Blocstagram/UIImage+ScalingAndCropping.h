//
//  UIImage+ScalingAndCropping.h
//  Blocstagram
//
//  Created by Samuel Shih on 4/12/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ScalingAndCropping)

- (UIImage *) imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect;

@end
