
#import "customizeSectionTableViewController.h"

@interface customizeSectionTableViewController (){
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
    NSMutableArray *languagesArray;
    NSMutableString *listOfLanguages;
    
    CGSize size;
    CGFloat sizeValue;
    NSMutableArray *height;
    NSArray *headers;
    UIImage *posterView;
    NSMutableString *synopsisText;
    NSMutableString *productionText;
    NSMutableString *genreText;
    NSMutableString *languageText;
}
- (void)configureView;

@end


@implementation customizeSectionTableViewController

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
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
    height = [[NSMutableArray alloc]init];
    headers = @[[ NSNull null] ,@"Poster", @"Synopsis", @"Production", @"Genre", @"Language", @"Cast"];
    
    self.dateLabel.text = self.release_segue;
    self.ratingLabel.text = self.rating_segue;
    
    posterView = [[UIImage alloc]init];
    synopsisText = [NSMutableString stringWithString:@""];
    productionText = [NSMutableString stringWithString:@""];
    genreText = [NSMutableString stringWithString:@""];
    languageText = [NSMutableString stringWithString:@""];
    
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
            listOfActors = [response objectForKey:@"cast"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *movieImage = [UIImage imageWithData:downloadedData];
            posterView = movieImage;
            [synopsisText appendString:[responseObject objectForKey:@"overview"]];
            
            if(![self.synopsis.text isEqual:[NSNull null]]){
                [self.synopsis sizeToFit];
                
                if(self.synopsis.frame.size.height < self.synopsisHeight.constant){
                    self.synopsisHeight.constant = self.synopsis.frame.size.height;
                }
            }
            
            self.titleLabel.text = [responseObject objectForKey:@"title"];
            productionText = listOfProductionCompanies;
            genreText = listOfGenres;
            languageText = listOfLanguages;
            [self.tableView reloadData];
            [self.scroller setHidden:YES];
            [self.downloadedView setHidden:NO];
            [self.scroller stopAnimating];
        });
    });
    
    // credits table
    baseUrl = [NSMutableString stringWithString:@"https://api.themoviedb.org/3/movie/"];
    [baseUrl appendString:idOfMovie.description ];
    [baseUrl appendString:credits];
    [baseUrl appendString:key];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSURL *url=[NSURL URLWithString:baseUrl];
        NSData *data=[NSData dataWithContentsOfURL:url];
        NSError *error =nil;
        id response=[NSJSONSerialization JSONObjectWithData:data options:
                     NSJSONReadingMutableContainers error:&error];
        listOfActors = [response objectForKey:@"cast"]; //2
    });
    
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
    if(section == ([headers count]-1)){
        return [listOfActors count];
    }else if(section == 0)
        return 2;
    else return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"proto" forIndexPath:indexPath];
    cell.imageView.image = nil;
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    
    switch (indexPath.section) {
        
        case 0: cell.textLabel.text = title;
            if(indexPath.row == 1){
                cell.textLabel.text = self.release_segue;
                cell.detailTextLabel.text = self.rating_segue;
            }
            [cell.textLabel sizeToFit];
            break;
            
        case 1:
            cell.textLabel.text = nil;
            cell.imageView.image = posterView;
            cell.imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            break;
            
        case 2:
            cell.textLabel.numberOfLines = 0;
            [cell.textLabel sizeToFit];
            cell.textLabel.text = synopsisText;
            break;
            
        case 3:
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.text = productionText;
            break;
            
        case 4:
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.text = genreText;
            break;
            
        case 5:
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.text = languageText;
            break;
            
        case 6:
            cell.textLabel.text = nil;
            cell.textLabel.text = [[listOfActors objectAtIndex: [indexPath row]] objectForKey:@"name"];
            cell.detailTextLabel.text = [[listOfActors objectAtIndex: [indexPath row]] objectForKey:@"character"];
            
            NSString *cast_image_path = [[listOfActors objectAtIndex: [indexPath row]] objectForKey:@"profile_path"];
            baseImgUrl = [NSMutableString stringWithString:@"http://image.tmdb.org/t/p/w45"];
            if(![cast_image_path isEqual:[NSNull null]]){
                UIImage *checkForImage = [castDictionary objectForKey:indexPath];
                if(checkForImage){
                    cell.imageView.image= checkForImage;
                }
                else {
                    [baseImgUrl appendString:cast_image_path];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        NSURL * urlImage=[NSURL URLWithString:baseImgUrl];
                        NSData *imagedata =[NSData dataWithContentsOfURL:urlImage];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(imagedata){
                                UITableViewCell *newCell = (UITableViewCell *)[tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
                                UIImage *castImage = [UIImage imageWithData:imagedata];
                                newCell.imageView.image = castImage;
                                
                                [cell setNeedsLayout];
                                if(castImage)
                                    [castDictionary setObject:castImage forKey:indexPath];
                            }
                        });
                    });
                }
            }else{
                UIImage *defaultImage = [UIImage imageNamed: @"images-3.jpeg"];
                [castDictionary setObject:defaultImage forKey:indexPath];
                [cell.imageView setImage:defaultImage];
            }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionHeader;
    if(section !=0)
        sectionHeader = [headers objectAtIndex:section];
    return sectionHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch(indexPath.section)
    {
            
        case 0:
            sizeValue = [self calculateHeightForEachSection : title ] ;
//            boundRect = [title boundingRectWithSize:CGSizeMake(screenWidth, CGFLOAT_MAX)
//                                            options:NSStringDrawingUsesLineFragmentOrigin
//                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0f]}
//                                            context:nil];
//            sizeValue = boundRect.size.height;
            
            break;
            
        case 1:
            size =  [posterView size];
            sizeValue = size.height;
            break;
            
        case 2:
            sizeValue = [self calculateHeightForEachSection : synopsisText];
//            boundRect = [synopsisText boundingRectWithSize:CGSizeMake(screenWidth, 999)
//                                                   options:NSStringDrawingUsesLineFragmentOrigin
//                                                attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0f]}
//                                                   context:nil];
//            sizeValue = boundRect.size.height;
            break;
            
        case 3:
            sizeValue = [self calculateHeightForEachSection : productionText];
//            boundRect = [productionText boundingRectWithSize:CGSizeMake(screenWidth, CGFLOAT_MAX)
//                                                     options:NSStringDrawingUsesLineFragmentOrigin
//                                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0f]}
//                                                     context:nil];
//            sizeValue = boundRect.size.height;
            break;
            
        case 4:
            sizeValue = [self calculateHeightForEachSection: genreText];
//            boundRect = [genreText boundingRectWithSize:CGSizeMake(screenWidth, CGFLOAT_MAX)
//                                                options:NSStringDrawingUsesLineFragmentOrigin
//                                             attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0f]}
//                                                context:nil];
//            sizeValue = boundRect.size.height;
            break;
            
        case 5:;
            sizeValue = [self calculateHeightForEachSection : languageText];
//            boundRect = [languageText boundingRectWithSize:CGSizeMake(screenWidth, CGFLOAT_MAX)
//                                                   options:NSStringDrawingUsesLineFragmentOrigin
//                                                attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0f]}
//                                                   context:nil];
//            sizeValue = boundRect.size.height;
            break;
    }
    return sizeValue;
}

- (CGFloat) calculateHeightForEachSection: (NSString*) component
{
    
    CGFloat calculatedHeight;
    CGRect boundRect;
    CGRect screenRect;
    screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
  

    boundRect = [component boundingRectWithSize:CGSizeMake(screenWidth, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0f]}
                                        context:nil];
    calculatedHeight = boundRect.size.height;
    return calculatedHeight;
}

@end



