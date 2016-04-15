//
//  NewCollectionViewCell.m
//  Blocstagram
//
//  Created by Samuel Shih on 4/14/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import "NewCollectionViewCell.h"

@implementation NewCollectionViewCell

// Overriding the instance method
- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
CGFloat thumbnailEdgeSize = 50;

    self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
    self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnail.clipsToBounds = YES;
    
    [self.contentView addSubview:self.thumbnail];

    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
    [self.contentView addSubview:self.label];
    
    return self;

}

@end
