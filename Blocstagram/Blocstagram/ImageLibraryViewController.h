//
//  ImageLibraryViewController.h
//  Blocstagram
//
//  Created by Samuel Shih on 4/11/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ImageLibraryViewController;

@protocol ImageLibraryViewControllerDelegate <NSObject>

- (void) imageLibraryViewController:(ImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image;

@end


@interface ImageLibraryViewController : UICollectionViewController

@property (nonatomic, weak) NSObject <ImageLibraryViewControllerDelegate> *delegate;

@end
