//
//  CameraToolbar.m
//  Blocstagram
//
//  Created by Samuel Shih on 4/8/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import "CameraToolbar.h"


@interface CameraToolbar()

// Customizing Appearance of View
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *rightButton;

// Views to customize look
@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) UIView *purpleView;

@end

@implementation CameraToolbar

// Create initializer to create objects and add them to the view hierarchy

-(instancetype) initWithImageNames:(NSArray *)imageNames {
    self = [super init];
    
    if (self) {
    
        // Initialize Buttons
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        // Add action methods when the buttons are pressed and set the the appropriate selector methods
        [self.leftButton addTarget:self action:@selector(leftButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.cameraButton addTarget:self action:@selector(cameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightButton addTarget:self action:@selector(rightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        // Set images on buttons
        [self.leftButton setImage:[UIImage imageNamed:imageNames.firstObject] forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:imageNames.lastObject] forState:UIControlStateNormal];
        
        [self.cameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [self.cameraButton setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 15, 10)];
        
        
        self.whiteView = [UIView new];
        self.whiteView.backgroundColor = [UIColor whiteColor];
        
        self.purpleView = [UIView new];
        self.purpleView.backgroundColor = [UIColor colorWithRed:0.345 green:0.318 blue:0.424 alpha:1]; /*#58516c*/
        
        // Add each view to the entire view
        for (UIView *view in @[self.whiteView, self.purpleView, self.leftButton, self.cameraButton, self.rightButton]) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
            
        }
        [self createConstraints];
    }

    return self;
}

- (void) createConstraints {
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_leftButton, _cameraButton, _rightButton, _whiteView, _purpleView);
    
    // The three buttons have equal widths and are distributed across the whole view
    NSArray *allButtonsHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftButton][_cameraButton(==_leftButton)][_rightButton(==_leftButton)]|" options:kNilOptions metrics:nil views:viewDictionary];
    
    // The left and right buttons have 10 points spacing from the top. All three buttons are aligned with the bottom of the view.
    NSArray *leftButtonVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_leftButton]|" options:kNilOptions metrics:nil views:viewDictionary];
    NSArray *cameraButtonVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cameraButton]|" options:kNilOptions metrics:nil views:viewDictionary];
    NSArray *rightButtonVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_rightButton]|" options:kNilOptions metrics:nil views:viewDictionary];
    
    // The white view goes behind all the buttons, 10 points from the top.
    NSArray *whiteViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_whiteView]|" options:kNilOptions metrics:nil views:viewDictionary];
    NSArray *whiteViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_whiteView]|" options:kNilOptions metrics:nil views:viewDictionary];
    
    // The purple view is positioned identically to the camera button
    NSArray *purpleViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[_leftButton][_purpleView][_rightButton]" options:NSLayoutFormatAlignAllBottom metrics:nil views:viewDictionary];
    NSArray *purpleViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_purpleView]" options:kNilOptions metrics:nil views:viewDictionary];
    
    NSArray *allConstraintArrays = @[allButtonsHorizontalConstraints, leftButtonVerticalConstraints, cameraButtonVerticalConstraints, rightButtonVerticalConstraints, whiteViewHorizontalConstraints, whiteViewVerticalConstraints, purpleViewHorizontalConstraints, purpleViewVerticalConstraints];
    
    for (NSArray *constraintsArray in allConstraintArrays) {
        for (NSLayoutConstraint *constraint in constraintsArray) {
            [self addConstraint:constraint];
        }
    }
}

- (void) layoutSubviews {
    [super layoutSubviews];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.purpleView.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.purpleView.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.purpleView.layer.mask = maskLayer;
}

- (void) leftButtonPressed:(UIButton *)sender {
    [self.delegate leftButtonPressedOnToolbar:self];
}

- (void) rightButtonPressed:(UIButton *)sender {
    [self.delegate rightButtonPressedOnToolbar:self];
}

- (void) cameraButtonPressed:(UIButton *)sender {
    [self.delegate cameraButtonPressedOnToolbar:self];
}


@end
