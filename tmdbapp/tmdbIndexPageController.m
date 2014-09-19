

#import "tmdbIndexPageController.h"
#import "tmdbMasterViewController.h"

@interface tmdbIndexPageController (){
NSArray *options;
}
@end

@implementation tmdbIndexPageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    options = @[@"Now Playing", @"Upcoming", @"Top Rated", @"Popular"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [options count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"index" ];
    cell.textLabel.text = [options objectAtIndex: [indexPath row]];
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMeMaster"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setIndex:(indexPath.row)];
        [[segue destinationViewController] setChosenTitle:options[indexPath.row]];
    }
 
}


@end
