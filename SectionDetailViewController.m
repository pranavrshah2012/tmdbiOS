
//not used anymore.
#import "SectionDetailViewController.h"

@interface SectionDetailViewController (){
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

            
            if(![self.synopsis.text isEqual:[NSNull null]]){
                [self.synopsis sizeToFit];
                
                if(self.synopsis.frame.size.height < self.synopsisHeight.constant){
                    self.synopsisHeight.constant = self.synopsis.frame.size.height;
                }
            }
            
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
    listOfActors = [response objectForKey:@"cast"]; 
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


@end
