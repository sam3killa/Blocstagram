//
//  ImagesTableViewController.m
//  Blocstagram
//
//  Created by Samuel Shih on 1/31/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import "ImagesTableViewController.h"
#import "DataSource.h"
#import "Media.h"
#import "User.h"
#import "Comment.h"
#import "MediaTableCell.h"
#import "MediaFullScreenViewController.h"
#import "ShareUtilities.h"
#import "UIViewController+Sharing.h"

@interface ImagesTableViewController () <MediaTableCellDelegate, UIScrollViewDelegate>

@end

@implementation ImagesTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {

    self = [super initWithStyle:style];
    if (self) {
        
        
    }
    return self;
}

//- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//
//
//}

-(void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
 
    
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        NSLog(@"%@",indexPath);
        Media *mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
        
        [[DataSource sharedInstance] downloadImageForMediaItem:mediaItem];
        
        
    
    }

}

// Once you tap the cell
- (void) cell:(MediaTableCell *)cell didTapImageView:(UIImageView *)imageView {
    MediaFullScreenViewController *fullScreenVC = [[MediaFullScreenViewController alloc] initWithMedia:cell.mediaItem];
    
    [self presentViewController:fullScreenVC animated:YES completion:nil];
}

- (void) cell:(MediaTableCell *)cell didLongPressImageView:(UIImageView *)imageView {
    
    [self shareMediaItem:cell.mediaItem];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // On App Launch request New Items
    [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:nil];

    [[DataSource sharedInstance] addObserver:self forKeyPath:@"mediaItems" options:0 context:nil];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerClass:[MediaTableCell class] forCellReuseIdentifier:@"mediaCell"];
    
    
    
    // Reuse Identifer name for the type of cell we will use in the table view
    [self.tableView registerClass:[MediaTableCell class] forCellReuseIdentifier:@"mediaCell"];
    
}

- (void) refreshControlDidFire:(UIRefreshControl *)sender {

    [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error) {
        [sender endRefreshing];
    }];
    
}

// Method that returns the Datasource sharedInstance media items
- (NSArray *) items {

    return [DataSource sharedInstance].mediaItems;
    
}

- (void) dealloc {

    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Need to implement tableview delegate and datasource
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self items].count;
}

// Infinite Scroll Necessary
- (void) infiniteScrollIfNecessary {
    // #3
    NSIndexPath *bottomIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    
    if (bottomIndexPath && bottomIndexPath.row == [DataSource sharedInstance].mediaItems.count - 1) {
        // The very last cell is on screen
        [[DataSource sharedInstance] requestOldItemsWithCompletionHandler:nil];
        
    }
}



#pragma mark - UIScrollViewDelegate

// #4
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [self infiniteScrollIfNecessary];
    
}

// Handle KVO updates
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {

    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"mediaItems"]) {
        
        NSKeyValueChange kindOfChange = [change [NSKeyValueChangeKindKey] unsignedIntegerValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
        
            [self.tableView reloadData];
        } else if (kindOfChange == NSKeyValueChangeInsertion ||
                   kindOfChange == NSKeyValueChangeRemoval ||
                   kindOfChange == NSKeyValueChangeReplacement
                   ){
        
            // We have an incremental change: inserted, deleted, or replaced
            
            // Get a list of the index (or indices) that changed
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            // Converts this NSIndexSet to an NSArray of NSIndexPaths
            NSMutableArray *indexPathsThatChanged = [NSMutableArray array];
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [indexPathsThatChanged addObject:newIndexPath];
            }];
            
            // Call beginUpdates to tell table view we are going to make changes
            [self.tableView beginUpdates];
            
            // Tells the table view what the changes are
            if (kindOfChange == NSKeyValueChangeInsertion) {
                [self.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeRemoval) {
                [self.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeReplacement) {
                [self.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        
            
            // Tell the table views that we're done telling it what to do
            [self.tableView endUpdates];
        }
    }
}

- (void) cellDidPressLikeButton:(MediaTableCell *)cell {
    Media *item = cell.mediaItem;
    
    [[DataSource sharedInstance] toggleLikeOnMediaItem:item withCompletionHandler:^{
        if (cell.mediaItem == item) {
            cell.mediaItem = item;
        }
    }];
    
    cell.mediaItem = item;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MediaTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.mediaItem = [self items][indexPath.row];
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    Media *item = [self items][indexPath.row];
    UIImage *image = item.image;
    
    return [MediaTableCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)];

}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];
        
        [[DataSource sharedInstance].mediaItems exchangeObjectAtIndex:indexPath.row withObjectAtIndex:0];
        
        NSLog(@"%@",item);
        
        NSLog(@"Triggered %@", [DataSource sharedInstance].mediaItems);
    }
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];
    if (item.image) {
        return 350;
    } else {
        return 150;
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
