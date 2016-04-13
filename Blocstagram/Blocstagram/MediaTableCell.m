//
//  MediaTableCell.m
//  Blocstagram
//
//  Created by Samuel Shih on 2/3/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import "MediaTableCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"
#import "DataSource.h"
#import "LikeButton.h"
#import "ComposeCommentView.h"


@interface MediaTableCell() <UIGestureRecognizerDelegate, ComposeCommentViewDelegate>

// Defining the types of elements that will be in our table view cell
@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;

// Auto-Layout Properties
@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *imageWidthConstraint;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *twoFingerTapGestureRecognizer;

// Like Button Property
@property (nonatomic, strong) LikeButton *likeButton;
@property (nonatomic, strong) UILabel *likeLabel;

// Writable CommentView
@property (nonatomic, strong) ComposeCommentView *commentView;

// Orientation Properties
@property (nonatomic, strong) NSArray *horizontallyRegularConstraints;
@property (nonatomic, strong) NSArray *horizontallyCompactConstraints;



@end

// Attribute String Properties that will hold our rich-text modifications to the string

// Used for comments and captions
static UIFont *lightFont;

// Used for usernames
static UIFont *boldFont;

// Used for background color of username and caption label
static UIColor *usernameLabelGray;

// Used for comment background
static UIColor *commentLabelGray;

// Text color of every username
static UIColor *linkColor;

// Set properties like alignment, indentaiton, spacing etc.
static NSParagraphStyle *paragraphStyle;

// Change properties

// Orange color for first comment
static UIColor *firstCommentOrange;

// Right align style
static NSParagraphStyle *commentRightAlignStyle;


@implementation MediaTableCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}

// The "+" indicates a class method not an instance method.

+ (void)load {
    
    // Initialize the properties
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1];
    commentLabelGray = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1];
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1];
    firstCommentOrange = [UIColor orangeColor];
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc]init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;

    NSMutableParagraphStyle *mutableCommentStyle = [[NSMutableParagraphStyle alloc]init];
    mutableCommentStyle.headIndent = 20.0;
    mutableCommentStyle.firstLineHeadIndent = 20.0;
    mutableCommentStyle.tailIndent = -20.0;
    mutableCommentStyle.paragraphSpacingBefore = 5;
    mutableCommentStyle.alignment = NSTextAlignmentCenter;

    paragraphStyle = mutableParagraphStyle;
    commentRightAlignStyle = mutableCommentStyle;
}

// Creating an NSAttributedString for our username and caption
- (NSAttributedString *) usernameAndCaptionString {
    
    // Font size used for username and caption
    CGFloat usernameFontSize = 15;
    
    // String that says what the user name is and what the caption is
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    
//    NSMutableAttributedString *mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize ], NSParagraphStyleAttributeName : paragraphStyle}];
    
    NSMutableAttributedString *mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize ]}];

    // Find the username range within the base string
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    [mutableUsernameAndCaptionString    addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
    
    // Change the kerning for the caption
    NSRange captionRange = [baseString rangeOfString:self.mediaItem.caption];
    [mutableUsernameAndCaptionString addAttribute:NSKernAttributeName value:@5 range:captionRange];

    
    return mutableUsernameAndCaptionString;
}

// Creating an NSAttributedString for our comments
- (NSAttributedString *) commentString {

    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    
    NSInteger count = 0;

    for (Comment *comment in self.mediaItem.comments) {
     
        // Make a string that says "username" followed by the comment in the next line
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
        

        
       // NSMutableAttributedString *oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString];
        
        NSMutableAttributedString *oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : count % 2 == 0 ? commentRightAlignStyle : paragraphStyle}];
        
        // Range of username
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
        [oneCommentString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
//        [oneCommentString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:usernameRange];
        
        // Range of comment
        NSRange commentRange = [baseString rangeOfString:comment.text];
        [oneCommentString addAttribute:NSFontAttributeName value:lightFont range:commentRange];

        // Make the first comment orange
        if (comment == self.mediaItem.comments[0]){
            
            [oneCommentString addAttribute:NSForegroundColorAttributeName value:firstCommentOrange range:commentRange];
            
        }
        
        // Every other comment right-align
        
        // Increase the count number by 1
        count++;
    
        [commentString appendAttributedString:oneCommentString];
       
    }
    return commentString;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:NO animated:animated];
}


// Method that calculates the size of our attributed string
- (CGSize) sizeOfString:(NSAttributedString *) string {
    
    // Our width we want to use
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.contentView.bounds) - 40, 0.0);
    
    // Determine how much space the string requires
    CGRect sizeRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    sizeRect.size.height += 20;
    sizeRect = CGRectIntegral(sizeRect);
    return sizeRect.size;
    
}

// This code needs to be explained to me.
- (void) layoutSubviews {
    [super layoutSubviews];

    if (!self.mediaItem) {
    
        return ;
    }
    
    // Before layout, calculate the intrinsic size of the labels
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
    CGSize usernameLabelSize = [self.usernameAndCaptionLabel sizeThatFits:maxSize];
    CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];
    
    self.usernameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height == 0 ? 0 : usernameLabelSize.height + 20;
    self.commentLabelHeightConstraint.constant = commentLabelSize.height == 0 ? 0 : commentLabelSize.height + 20;
    
    // Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds)/2.0, 0, CGRectGetWidth(self.bounds)/2.0);
    
    if (self.mediaItem.image.size.width > 0 && CGRectGetWidth(self.contentView.bounds) > 0) {
        
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
            /* It's compact! */
            self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
        } else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
            /* It's regular! */
            self.imageHeightConstraint.constant = 320;
        }
        
    } else {
        self.imageHeightConstraint.constant = 0;
    }

}

- (void) traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        /* It's compact! */
        [self.contentView removeConstraints:self.horizontallyRegularConstraints];
        [self.contentView addConstraints:self.horizontallyCompactConstraints];
    } else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        /* It's regular */
        [self.contentView removeConstraints:self.horizontallyCompactConstraints];
        [self.contentView addConstraints:self.horizontallyRegularConstraints];
    }
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        // Initialize the elements in the table view cell
        self.mediaImageView = [[UIImageView alloc] init];
        self.mediaImageView.userInteractionEnabled = YES;
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapFired:)];
        self.tapGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.tapGestureRecognizer];
       
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        self.longPressGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.longPressGestureRecognizer];
        
//        self.twoFingerTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
        self.twoFingerTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
        self.twoFingerTapGestureRecognizer.delegate = self;
        self.twoFingerTapGestureRecognizer.numberOfTouchesRequired = 2;
        [self.mediaImageView addGestureRecognizer:self.twoFingerTapGestureRecognizer];
        
        self.usernameAndCaptionLabel = [[UILabel alloc]init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
       // self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
        
        self.commentLabel = [[UILabel alloc]init];
        self.commentLabel.numberOfLines = 0;
       // self.commentLabel.backgroundColor = commentLabelGray;
        
        self.likeLabel = [[UILabel alloc] init];
        self.likeLabel.numberOfLines = 0;
        
        self.likeButton = [[LikeButton alloc] init];
        [self.likeButton addTarget:self action:@selector(likePressed:) forControlEvents:UIControlEventTouchUpInside];
        self.likeButton.backgroundColor = usernameLabelGray;
        
        self.commentView = [[ComposeCommentView alloc] init];
        self.commentView.delegate = self;
        
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel, self.likeButton, self.likeLabel, self.commentView]) {
    
            // contentView is specific to UITableViewCell
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        
        }
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel, _likeButton, _commentView, _likeLabel);

        
        self.horizontallyCompactConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|" options:kNilOptions metrics:nil views:viewDictionary];
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:320];
        NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:0
                                                                               toItem:_mediaImageView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1
                                                                             constant:0];
        
        self.horizontallyRegularConstraints = @[widthConstraint, centerConstraint];
        
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
            /* It's compact! */
            [self.contentView addConstraints:self.horizontallyCompactConstraints];
        } else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
            /* It's regular! */
            [self.contentView addConstraints:self.horizontallyRegularConstraints];
        }
    
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel][_likeLabel(==50)][_likeButton(==38)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentLabel]|" options:kNilOptions metrics:nil views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentView]|" options:kNilOptions metrics:nil views:viewDictionary]];

        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel][_commentView(==100)]"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
    
        
        
   
        // Image Height Constraint
        self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
        
        self.imageHeightConstraint.identifier = @"Image height constraint";
        
        // Image Width Constraint
        self.imageWidthConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
        
        self.imageWidthConstraint.identifier = @"Image width constraint";

        self.usernameAndCaptionLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1
                                                                                     constant:100];
        self.usernameAndCaptionLabelHeightConstraint.identifier = @"Username and caption label height constraint";
        
        self.commentLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:100];
        
        self.commentLabelHeightConstraint.identifier = @"Comment label height constraint";
        
        [self.contentView addConstraints:@[self.imageHeightConstraint, self.usernameAndCaptionLabelHeightConstraint, self.commentLabelHeightConstraint]];
        
    }
    return self;
}

// Creating action method for double tap
-(void) doubleTapFired:(UITapGestureRecognizer *)sender{
    
    // Run retry method
    //downloadImageForMediaItem
    
    [[DataSource sharedInstance] downloadImageForMediaItem:self.mediaItem];
}

// Creating the action method
- (void) tapFired:(UITapGestureRecognizer *)sender {

    [self.delegate cell:self didTapImageView:self.mediaImageView];

}

// UIGestureRecognizerDelegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.isEditing == NO;
}

// Setting the media item
- (void) setMediaItem:(Media *) mediaItem {

    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
    self.likeButton.likeButtonState = mediaItem.likeState;
    self.likeLabel.text = mediaItem.numberOfLikes.stringValue;
    self.commentView.text = mediaItem.temporaryComment;

}

- (void) likePressed:(UIButton *)sender {
    [self.delegate cellDidPressLikeButton:self];
    
    // Increment the number of likes by 1
    _mediaItem.numberOfLikes = @(_mediaItem.numberOfLikes.intValue+1);
    
}

- (void) longPressFired:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.delegate cell:self didLongPressImageView:self.mediaImageView];
    }
}


+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width traitCollection:(UITraitCollection *) traitCollection {
    // Make a cell
    
    MediaTableCell *layoutCell = [[MediaTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    
    layoutCell.mediaItem = mediaItem;
    
    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    
    layoutCell.overrideTraitCollection = traitCollection;

    
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    
    // The height will be wherever the bottom of the comments label is
    return CGRectGetMaxY(layoutCell.commentView.frame);
}

- (UITraitCollection *) traitCollection {
    if (self.overrideTraitCollection) {
        return self.overrideTraitCollection;
    }
    
    return [super traitCollection];
}

// Comment Methods
- (void) commentViewDidPressCommentButton:(ComposeCommentView *)sender {
    [self.delegate cell:self didComposeComment:self.mediaItem.temporaryComment];
}

- (void) commentView:(ComposeCommentView *)sender textDidChange:(NSString *)text {
    self.mediaItem.temporaryComment = text;
}

- (void) commentViewWillStartEditing:(ComposeCommentView *)sender {
    [self.delegate cellWillStartComposingComment:self];
}

- (void) stopComposingComment {
    [self.commentView stopComposingComment];
}


@end
