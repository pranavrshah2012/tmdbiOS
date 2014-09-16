//
//  tmdbIndexPageController.m
//  tmdbapp
//
//  Created by Pranav on 9/5/14.
//  Copyright (c) 2014 ___Pranav___. All rights reserved.
//

#import "tmdbIndexPageController.h"
#import "tmdbMasterViewController.h"

@interface tmdbIndexPageController (){
NSArray *options;
}
@end

@implementation tmdbIndexPageController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    options = @[@"Now Playing", @"Upcoming", @"Top Rated", @"Popular"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [options count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"index" ];
    cell.textLabel.text = [options objectAtIndex: [indexPath row]];
    
    // Configure the cell...
    
    return cell;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMeMaster"]) {
        
        // NSLog(@"I am called");
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
       // NSDate *object = options[indexPath.row];
        //  NSLog(@"item: %@", [object description] );
        [[segue destinationViewController] setIndex:(indexPath.row)];
        [[segue destinationViewController] setChosenTitle:options[indexPath.row]];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
