

#import "tmdbMasterViewController.h"
#import "constants.h"
#import "CustomCellTableViewCell.h"
#import "Movie.h"
#import "tmdbDetailViewController.h"


@interface tmdbMasterViewController () {
    NSMutableArray *_objects;
    NSString *key;
    id movieObject;
    NSMutableArray *listOfMovies;
    NSMutableArray *results;
    NSMutableArray *ratings;
    NSMutableArray *releases;
    NSMutableArray *urls;
    NSMutableArray *ids;
    NSInteger count;
    NSMutableString *baseImageUrl;
    NSMutableDictionary *memoryCache;
    NSInteger page;
    NSMutableString *str ;
    NSMutableString *ampersandPage;
    NSMutableString *downloadMoreUrl;
    Movie *movie;
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
    listOfMovies = [[NSMutableArray alloc]init];
    
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
         
        //to make movie object
         for( movieObject in results){
             movie = [[Movie alloc]init];
             [movie createMovieObjectFromJson: movieObject];
            [listOfMovies addObject: movie];
         }
    
     dispatch_async(dispatch_get_main_queue(), ^{
         for(movieObject in results){
             [_objects addObject: [movieObject objectForKey : @"original_title" ]];
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
        return [listOfMovies count];
    }
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCellTableViewCell *cell = (CustomCellTableViewCell*)[self.masterView dequeueReusableCellWithIdentifier:@"Cell"] ;
    NSInteger indexToSearchForImage;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell.imageView.image = nil;
        Movie *foundMovie = [self.searchResult objectAtIndex:indexPath.row];
       
        cell.textLabel.text =  foundMovie.title;
        cell.ratingLabel.text = @"";
        cell.TitleLabel.text = @"";
        cell.releaseLabel.text = @"";
        
        indexToSearchForImage = [_objects indexOfObject:cell.textLabel.text];
        
        cell.imageView.image = [memoryCache objectForKey: foundMovie.posterUrl];
    }
    else {
        cell.imageView.image = nil ;
        
        NSObject *object = _objects[indexPath.row];
        
    NSObject *movieRating = ((Movie *)listOfMovies[indexPath.row]).rating ;
    NSObject *movieRelease = ((Movie *)listOfMovies [indexPath.row]).releaseDate;
    NSString *poster_path = ((Movie *) listOfMovies[indexPath.row]).posterUrl;
    baseImageUrl = [NSMutableString stringWithString:@""];
    baseImageUrl = [NSMutableString stringWithString:@"http://image.tmdb.org/t/p/w45"];
    __block  NSURL *localUrl ;
         if(![poster_path isEqual:[NSNull null]]){
    [baseImageUrl appendString:poster_path];
      localUrl = [NSURL URLWithString:baseImageUrl];
  
    }
    else{
        UIImage *defaultImage = [UIImage imageNamed: @"images-3.jpeg"];
    
        [memoryCache setObject:defaultImage forKey:poster_path];
        [cell.imageView setImage:defaultImage];
        }
   
      UIImage *image = [memoryCache objectForKey:poster_path];
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
             [memoryCache setObject:cellImage forKey:poster_path];
         });
           });

    }
    
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
     
     NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@", searchText];
     
     self.searchResult = [NSMutableArray arrayWithArray: [listOfMovies filteredArrayUsingPredicate:resultPredicate]];
 }

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {

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
            for( movieObject in res){
                movie = [[Movie alloc]init];
                [movie createMovieObjectFromJson: movieObject];
                [listOfMovies addObject: movie];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                for(movieObject in res){
                    [_objects addObject: [movieObject objectForKey : @"original_title" ]];
                    [self.masterView reloadData];
                }
            });
        });
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath;
    NSString *titleToSearch;
    NSString *chosenId;
    int indexFound;
    
    if ([[segue identifier] isEqualToString:@"customizedSection"]) {
   
    if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            titleToSearch = _searchResult[indexPath.row];
            indexFound = [_objects indexOfObject:titleToSearch];
            chosenId = ((Movie*) _searchResult[indexPath.row]).id;
        }
        
        else{
        indexPath = [self.masterView indexPathForSelectedRow];
            chosenId = ((Movie*)listOfMovies[indexPath.row]).id;
            [[segue destinationViewController] setDetailTitle: ((Movie*) listOfMovies[indexPath.row]).title];
        }
   [[segue destinationViewController] setDetailItem: chosenId ];
   [[segue destinationViewController] setRelease_segue: ((Movie*)listOfMovies[indexPath.row]).releaseDate];
        [[segue destinationViewController ] setRating_segue:
     [NSString stringWithFormat: @"%@", ((Movie *)listOfMovies[indexPath.row]).rating]];
 
        
         
    }
    
}

@end
