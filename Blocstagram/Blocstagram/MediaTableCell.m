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

@interface MediaTableCell()

// Defining the types of elements that will be in our table view cell
@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;


// Auto-Layout Properties
@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelHeightConstraint;



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
    [super setSelected:selected animated:animated];

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
    
    self.usernameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height + 20;
    self.commentLabelHeightConstraint.constant = commentLabelSize.height + 20;
    self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
    
    // Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds)/2.0, 0, CGRectGetWidth(self.bounds)/2.0);

}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        // Initialize the elements in the table view cell
        self.mediaImageView = [[UIImageView alloc] init];
        self.usernameAndCaptionLabel = [[UILabel alloc]init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
       // self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
        
        self.commentLabel = [[UILabel alloc]init];
        self.commentLabel.numberOfLines = 0;
       // self.commentLabel.backgroundColor = commentLabelGray;
        
        // Add each UI element to the table view cell content view
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel]) {
            
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        
        }
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|" options:kNilOptions metrics:nil views:viewDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel]|" options:kNilOptions metrics:nil views:viewDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentLabel]|" options:kNilOptions metrics:nil views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel]"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
   
        self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
        
        self.imageHeightConstraint.identifier = @"Image height constraint";

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

// Setting the media item
- (void) setMediaItem:(Media *) mediaItem {

    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];

}

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width {
    // Make a cell
    
    MediaTableCell *layoutCell = [[MediaTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    
    layoutCell.mediaItem = mediaItem;
    
    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    
    // The height will be wherever the bottom of the comments label is
    return CGRectGetMaxY(layoutCell.commentLabel.frame);
}


@end
