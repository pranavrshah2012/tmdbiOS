//
//  tmdbMasterViewController.m
//  tmdbapp
//
//  Created by Pranav on 9/3/14.
//  Copyright (c) 2014 ___Pranav___. All rights reserved.
//

#import "tmdbMasterViewController.h"
#import "constants.h"
#import "CustomCellTableViewCell.h"
#import "tmdbDetailViewController.h"


@interface tmdbMasterViewController () {
    NSMutableArray *_objects;
    NSString *key;
    id movieObject;
    NSMutableArray *results;
    NSMutableArray *ratings;
    NSMutableArray *releases;
    NSMutableArray *urls;
    NSMutableArray *ids;
    NSInteger count;
    NSMutableString *baseImageUrl;
    NSMutableDictionary *memoryCache;
    BOOL isDragging_msg, isDecliring_msg;
    NSInteger page;
    NSMutableString *str ;
    NSMutableString *ampersandPage;
    NSMutableString *downloadMoreUrl;
}
@end

@implementation tmdbMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    page =1;
    NSMutableString *choice;
    memoryCache = [[NSMutableDictionary alloc]init];

    ampersandPage = [NSMutableString stringWithString: @"&page="];
    switch (_index){
        case 0:
            choice =[NSMutableString stringWithString:@"now_playing"];
            break;
            
        case 1:
            choice = [NSMutableString stringWithString:@"upcoming"];
            break;
            
        case 2:
            choice = [NSMutableString stringWithString:@"top_rated"];
            break;
            
        case 3:
            choice = [NSMutableString stringWithString:@"popular"];
    
        default:
            break;
    }
    
    _objects=  [[NSMutableArray alloc]init];
    releases=  [[NSMutableArray alloc]init];
    ratings=  [[NSMutableArray alloc]init];
    urls=  [[NSMutableArray alloc]init];
    ids = [[NSMutableArray alloc]init];
    self.title = _chosenTitle;
    
    str =     [NSMutableString stringWithString:@"https://api.themoviedb.org/3/movie/"];
    key = @"?api_key=c47afb8e8b27906bca710175d6e8ba68";
    [str appendString: choice];
    [str appendString:key];
    
    [self.masterView setHidden:YES];
    [self.scrollWheel setHidden:NO];
    [self.scrollWheel startAnimating];

     //get full json using async
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
     NSURL *url=[NSURL URLWithString:str];
     NSData *data=[NSData dataWithContentsOfURL:url];
         if(!data)NSLog(@"data is nil?? %@", data);
     NSError *error=nil;
         id response=[NSJSONSerialization JSONObjectWithData:data options:
                      NSJSONReadingMutableContainers error:&error];
         
         results = [response objectForKey:@"results"];
     
     dispatch_async(dispatch_get_main_queue(), ^{
         for(movieObject in results){
             [_objects addObject: [movieObject objectForKey : @"original_title" ]];
             [releases addObject: [movieObject objectForKey : @"release_date" ]];
             [ratings addObject: [movieObject objectForKey : @"vote_average" ]];
             [urls addObject: [movieObject objectForKey : @"poster_path"]];
             [ids addObject: [movieObject objectForKey:@"id"]];
             [self.masterView setHidden:NO];
             [self.scrollWheel setHidden:YES];
             [self.masterView reloadData];
             [self.scrollWheel stopAnimating];
         }
     });
          });
    
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.masterView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResult count];
    }
    else
    {
        return [_objects count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCellTableViewCell *cell = (CustomCellTableViewCell*)[self.masterView dequeueReusableCellWithIdentifier:@"Cell"] ;
    NSInteger indexToSearchForImage;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell.imageView.image = nil;
        cell.textLabel.text = [self.searchResult objectAtIndex:indexPath.row];
        cell.ratingLabel.text = @"";
        cell.TitleLabel.text = @"";
        cell.releaseLabel.text = @"";
        indexToSearchForImage = [_objects indexOfObject:cell.textLabel.text];
       // cell.imageView.image = [memoryCache objectForKey:indexToSearchForImage];
        
        //cell.textLabel.text = [
    }
    else {
    cell.imageView.image = nil ;
    NSObject *object = _objects[indexPath.row];
    NSObject *movieRating = ratings[indexPath.row];
    NSObject *movieRelease = releases [indexPath.row];
    NSString *poster_path = urls [indexPath.row];
 
    baseImageUrl = [NSMutableString stringWithString:@""];
    baseImageUrl = [NSMutableString stringWithString:@"http://image.tmdb.org/t/p/w45"];
    __block  NSURL *localUrl ;
         if(![poster_path isEqual:[NSNull null]]){
    [baseImageUrl appendString:poster_path];
      localUrl = [NSURL URLWithString:baseImageUrl];
  
    }
    else{
        UIImage *defaultImage = [UIImage imageNamed: @"images-3.jpeg"];
        
        [memoryCache setObject:defaultImage forKey:indexPath];
        [cell.imageView setImage:defaultImage];
        }
   UIImage *image = [memoryCache objectForKey:indexPath];
    if(image){
       cell.imageView.image = image;

    }
    else{
        
    // get and cache image async block
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
     NSData *downloadedData = [NSData dataWithContentsOfURL:localUrl];
     
         dispatch_async(dispatch_get_main_queue(), ^{
             CustomCellTableViewCell *newCell = (CustomCellTableViewCell *)[tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
           UIImage *cellImage = [UIImage imageWithData:downloadedData];        
             newCell.imageView.image = cellImage;
             [cell setNeedsLayout];
             if(cellImage)
             [memoryCache setObject:cellImage forKey:indexPath];
         });
           });

    }
    
    
    // configure the cell
    cell.TitleLabel.text = [object description];
    cell.ratingLabel.text = [movieRating description];
    cell.releaseLabel.text = [movieRelease description];
    }
    return cell;
}

//search methods
 - (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
 {
 [self.searchResult removeAllObjects];
 NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
 
 self.searchResult = [NSMutableArray arrayWithArray: [_objects filteredArrayUsingPredicate:resultPredicate]];
 }

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    if (([scrollView contentOffset].y + scrollView.frame.size.height) == [scrollView contentSize].height){
      page++;

        downloadMoreUrl = [NSMutableString stringWithFormat:@"%@%@%ld",str, ampersandPage, (long)page ];
        
        //get full json using queue
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSURL *url=[NSURL URLWithString:downloadMoreUrl];
            NSData *data=[NSData dataWithContentsOfURL:url];
            NSError *error=nil;
            id res=[NSJSONSerialization JSONObjectWithData:data options:
                         NSJSONReadingMutableContainers error:&error];
            
            res = [res objectForKey:@"results"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                for(movieObject in res){
                    [_objects addObject: [movieObject objectForKey : @"original_title" ]];
                    [releases addObject: [movieObject objectForKey : @"release_date" ]];
                    [ratings addObject: [movieObject objectForKey : @"vote_average" ]];
                    [urls addObject: [movieObject objectForKey : @"poster_path"]];
                    [ids addObject: [movieObject objectForKey:@"id"]];
                    [self.masterView reloadData];
      
                }
                
            });
        });
        
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath;
    NSString *titleToSearch;
    NSDate *object;
    int indexFound;
    
    if ([[segue identifier] isEqualToString:@"show"]) {
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            titleToSearch = _searchResult[indexPath.row];
            [[segue destinationViewController] setDetailTitle: _searchResult[indexPath.row]];
             indexFound = [_objects indexOfObject:titleToSearch];
            object = ids[indexFound];
        }
        
        else{
        indexPath = [self.masterView indexPathForSelectedRow];
            object = ids[indexPath.row];
            [[segue destinationViewController] setDetailTitle: _objects[indexPath.row]];

        }
    [[segue destinationViewController] setDetailItem: object ];
    [[segue destinationViewController] setRelease_segue: releases[indexPath.row]];
    [[segue destinationViewController ] setRating_segue:
     [NSString stringWithFormat: @"%@" ,ratings[indexPath.row]]];
        
         
    }
}

@end
