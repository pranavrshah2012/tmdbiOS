//
//  SectionDetailViewController.m
//  tmdbapp
//
//  Created by Pranav on 9/16/14.
//  Copyright (c) 2014 ___Pranav___. All rights reserved.
//


//not used anymore.
#import "SectionDetailViewController.h"

@interface SectionDetailViewController (){
    //copy
NSMutableString *baseUrl;
NSMutableString *posterUrl;
NSMutableString *key;
NSString *title;
NSMutableString *baseImgUrl;
NSMutableString *movieInfo;
NSString *credits;
NSMutableArray *listOfActors;
NSCache *memoryCache;
NSMutableDictionary *castDictionary;
NSMutableArray *genresArray ;
NSMutableString *listOfGenres;
NSMutableArray *production_companiesArray;
NSMutableString *listOfProductionCompanies;
NSArray *languagesArray;
NSMutableString *listOfLanguages;
}

- (void)configureView;


@end

@implementation SectionDetailViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//copy
- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    self.title = _detailTitle;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [super viewDidLoad];
    self.dateLabel.text = self.release_segue;
    self.ratingLabel.text = self.rating_segue;
    
    listOfGenres = [NSMutableString stringWithString:@""];
    listOfLanguages = [NSMutableString stringWithString:@""];
    castDictionary = [[NSMutableDictionary alloc] init];
    languagesArray = [[NSMutableArray alloc]init];
    production_companiesArray = [[NSMutableArray alloc]init];
    listOfProductionCompanies = [NSMutableString stringWithString:@"" ];
    genresArray = [[NSMutableArray alloc]init];
    credits = @"/credits";
    NSString *idOfMovie = self.detailItem;
    
    NSMutableString *jsonUrl = [NSMutableString stringWithString:@"https://api.themoviedb.org/3/movie/"];
    key = [NSMutableString stringWithString:@"?api_key=c47afb8e8b27906bca710175d6e8ba68"];
    [jsonUrl appendString:idOfMovie.description ];
    [jsonUrl appendString:key];
    
    
    //loading animation
    [self.scroller setHidden:NO];
    [self.downloadedView setHidden:YES];
    [self.scroller startAnimating];
    
    //async using queue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSURL *url=[NSURL URLWithString:jsonUrl];
        NSData *data=[NSData dataWithContentsOfURL:url];
        NSError *error=nil;
        id responseObject;
        responseObject=[NSJSONSerialization JSONObjectWithData:data options:
                        NSJSONReadingMutableContainers error:&error];
        baseImgUrl = [NSMutableString stringWithString:@"http://image.tmdb.org/t/p/w342"];
        
        title = [responseObject objectForKey:@"title"];
        genresArray = [responseObject objectForKey:@"genres"];
        production_companiesArray = [responseObject objectForKey:@"production_companies"];
        languagesArray = [responseObject objectForKey:@"spoken_languages"];
        int i=0;
        for( i =0 ; i < languagesArray.count; i++){
            [listOfLanguages appendString: [languagesArray[i] objectForKey:@"name"]];
            if(i!= ([languagesArray count]-1) )
                [listOfLanguages appendString: @"," ];
        }
        
        
        for(i =0 ; i < genresArray.count; i++){
            [listOfGenres appendString: [genresArray[i] objectForKey:@"name"] ];
            if(i!= ([genresArray count]-1) )
                [listOfGenres appendString: @","];
        }
        
        for(i =0 ; i < production_companiesArray.count; i++){
            [listOfProductionCompanies appendString: [production_companiesArray[i] objectForKey:@"name"] ];
            if(i!= ([genresArray count]-1) )
                [listOfProductionCompanies appendString: @","];
        }
        
        NSString *suffix =[responseObject objectForKey:@"poster_path"];
        if(![suffix isEqual:[NSNull null]])
            [baseImgUrl appendString:suffix];
        
        NSData *downloadedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:baseImgUrl]];
        
        if (downloadedData) {
            // caching
            [memoryCache setObject:downloadedData forKey:baseImgUrl];
            
            baseUrl = [NSMutableString stringWithString:@"https://api.themoviedb.org/3/movie/"];
            [baseUrl appendString:idOfMovie.description ];
            [baseUrl appendString:credits];
            [baseUrl appendString:key];
            
            url=[NSURL URLWithString:baseUrl];
            data=[NSData dataWithContentsOfURL:url];
            
            error=nil;
            id response=[NSJSONSerialization JSONObjectWithData:data options:
                         NSJSONReadingMutableContainers error:&error];
            listOfActors = [response objectForKey:@"cast"]; //2
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *movieImage = [UIImage imageWithData:downloadedData];
            self.poster.image = movieImage;
            self.synopsis.text = [responseObject objectForKey:@"overview"];
           // int numberOfLines = (self.synopsisHeight.constant)/17;
          //  NSLog(@" height before is %d %f" , numberOfLines, self.synopsisHeight.constant );
            
            if(![self.synopsis.text isEqual:[NSNull null]]){
                [self.synopsis sizeToFit];
                
                if(self.synopsis.frame.size.height < self.synopsisHeight.constant){
                    self.synopsisHeight.constant = self.synopsis.frame.size.height;
                }
            }
           // NSLog(@" height after is %d %f" , numberOfLines, self.synopsisHeight.constant );

            
            self.titleLabel.text = [responseObject objectForKey:@"title"];
            self.productionLabel.text = listOfProductionCompanies;
            self.genresLabel.text = listOfGenres;
            self.languageLabel.text = listOfLanguages;
            
            [self.scroller setHidden:YES];
            [self.downloadedView setHidden:NO];
            [self.scroller stopAnimating];
            
        });
        
    });
    
    //credits table
    baseUrl = [NSMutableString stringWithString:@"https://api.themoviedb.org/3/movie/"];
    [baseUrl appendString:idOfMovie.description ];
    [baseUrl appendString:credits];
    [baseUrl appendString:key];
    
    NSURL *url=[NSURL URLWithString:baseUrl];
    NSData *data=[NSData dataWithContentsOfURL:url];
    NSError *error =nil;
    id response=[NSJSONSerialization JSONObjectWithData:data options:
                 NSJSONReadingMutableContainers error:&error];
    listOfActors = [response objectForKey:@"cast"]; //2
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    
    
    // Configure the cell...
    
    return cell;
}*/


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
