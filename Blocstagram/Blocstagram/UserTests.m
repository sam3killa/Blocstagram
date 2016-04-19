//
//  UserTests.m
//  Blocstagram
//
//  Created by Samuel Shih on 4/12/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "User.h"
#import "Media.h"
#import "ComposeCommentView.h"
#import "MediaTableCell.h"
#import "DataSource.h"

@interface UserTests : XCTestCase

@end

@implementation UserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatInitializationWorks
{
    NSDictionary *sourceDictionary = @{@"id": @"8675309",
                                       @"username" : @"d'oh",
                                       @"full_name" : @"Homer Simpson",
                                       @"profile_picture" : @"http://www.example.com/example.jpg"};
    User *testUser = [[User alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testUser.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(testUser.userName, sourceDictionary[@"username"], @"The username should be equal");
    XCTAssertEqualObjects(testUser.fullName, sourceDictionary[@"full_name"], @"The full name should be equal");
    XCTAssertEqualObjects(testUser.profilePictureURL, [NSURL URLWithString:sourceDictionary[@"profile_picture"]], @"The profile picture should be equal");
}

- (void)testThatMediaInitializationWorks
{
    NSDictionary *mediaDictionary = @{@"id": @"8675309"
                                       };
    
    Media *testMedia = [[Media alloc] initWithDictionary: mediaDictionary];
    
    XCTAssertEqualObjects(testMedia.idNumber, mediaDictionary[@"id"],@"The IDs should be equal");


}

- (void)testThatCommentComposeWorks
{
    
    ComposeCommentView *comment = [[ComposeCommentView alloc] init];
    [comment setText:@"Hello"];
    
    XCTAssertTrue(comment.isWritingComment,@"Should be yes");
    
    [comment setText:NULL];
    
    XCTAssertFalse(comment.isWritingComment, @"Should be no");
    
}

//NSString *standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];




- (void)testMediaTableHeight

{
    
    Media *mediaItem = [DataSource sharedInstance].mediaItems[0];
    
    UIImage *testImage = [UIImage imageNamed:@"Angelina"];
    mediaItem.image = testImage;
    
    CGFloat testHeight = [MediaTableCell heightForMediaItem:mediaItem width:718];
    
    CGFloat number = 905.5;
    
    XCTAssertEqual(testHeight, number, @"The profile picture should be equal");
    
    mediaItem = [DataSource sharedInstance].mediaItems[1];
    
    CGFloat testHeight2 = [MediaTableCell heightForMediaItem:mediaItem width:718];
    
    CGFloat number2 = 1228;
    
    XCTAssertEqual(testHeight2, number2, @"The profile picture should be equal");



}

@end
