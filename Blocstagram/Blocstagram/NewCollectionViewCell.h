//
//  NewCollectionViewCell.h
//  Blocstagram
//
//  Created by Samuel Shih on 4/14/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewCollectionViewCell : UICollectionViewCell


@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UILabel *label;

- (instancetype) initWithFrame:(CGRect)frame;


@end
