//
//  tmdbDetailViewController.m
//  tmdbapp
//
//  Created by Pranav on 9/3/14.
//  Copyright (c) 2014 ___Pranav___. All rights reserved.
//

#import "tmdbDetailViewController.h"

@interface tmdbDetailViewController (){
    NSMutableString *baseUrl;
    NSMutableString *posterUrl;
    NSMutableString *key;
    NSString *title;
    NSMutableString *baseImgUrl;
    //   id response;
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

@implementation tmdbDetailViewController

#pragma mark - Managing the detail item

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
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        // self.detailDescriptionLabel.text = [self.detailItem description];

    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  //  NSLog(@" Release, Rating %@%@", _release_segue, _rating_segue);
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
 //   NSLog(@"append 1 is %@ %@ %@", jsonUrl, idOfMovie.description, key);
    [jsonUrl appendString:idOfMovie.description ];
    [jsonUrl appendString:key];

    /*
     NSURL *url=[NSURL URLWithString:baseUrl];
     NSData *data=[NSData dataWithContentsOfURL:url];
     // NSLog(@"baseUrl: %@", baseUrl);
     
     NSError *error=nil;
     id response;
     response=[NSJSONSerialization JSONObjectWithData:data options:
     NSJSONReadingMutableContainers error:&error];
     baseImgUrl = [NSMutableString stringWithString:@"http://image.tmdb.org/t/p/w500"];
     //  NSLog(@"response is: %@", response);
     
     title = [response objectForKey:@"title"];
     NSString *suffix =[response objectForKey:@"poster_path"];
     
     
     if(![suffix isEqual:[NSNull null]])
     [baseImgUrl appendString:suffix];
     //  NSLog(@"title below suffix: %@", title);
     //  NSLog(@"url below suffix: %@", baseImgUrl);
     */
    
    
    [self.scroller setHidden:NO];
    [self.downloadedView setHidden:YES];
    [self.scroller startAnimating];
    
    //async using queue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        NSLog(@"baseurl is %@", baseUrl);

        NSURL *url=[NSURL URLWithString:jsonUrl];
        NSData *data=[NSData dataWithContentsOfURL:url];
        
       NSLog(@"data jsonurl responseObject: %@", jsonUrl);
        
        NSError *error=nil;
        id responseObject;
        responseObject=[NSJSONSerialization JSONObjectWithData:data options:
                  NSJSONReadingMutableContainers error:&error];
        baseImgUrl = [NSMutableString stringWithString:@"http://image.tmdb.org/t/p/w342"];
        
     //   NSLog(@"response is: %@", re);
        
        title = [responseObject objectForKey:@"title"];
        genresArray = [responseObject objectForKey:@"genres"];
        production_companiesArray = [responseObject objectForKey:@"production_companies"];
        languagesArray = [responseObject objectForKey:@"spoken_languages"];
        int i=0;
        for( i =0 ; i < languagesArray.count; i++)
        {
            [listOfLanguages appendString: [languagesArray[i] objectForKey:@"name"]];
            if(i!= ([languagesArray count]-1) )
                [listOfLanguages appendString: @"," ];
            
        }
        
        
        for(i =0 ; i < genresArray.count; i++)
        {
            [listOfGenres appendString: [genresArray[i] objectForKey:@"name"] ];
            if(i!= ([genresArray count]-1) )
            [listOfGenres appendString: @","];
        }
        
        for(i =0 ; i < production_companiesArray.count; i++)
        {
            [listOfProductionCompanies appendString: [production_companiesArray[i] objectForKey:@"name"] ];
            if(i!= ([genresArray count]-1) )
            [listOfProductionCompanies appendString: @","];
        }
        
       // NSLog(@"details array %@ %@ %@ ", listOfProductionCompanies, listOfGenres, listOfLanguages);
        NSString *suffix =[responseObject objectForKey:@"poster_path"];
     //   NSLog(@"suffix is: %@", suffix);

        
        if(![suffix isEqual:[NSNull null]])
       //     NSLog(@" append suffix %@ %@" , suffix, baseImgUrl);
            [baseImgUrl appendString:suffix];
   //     NSLog(@" append after %@" , baseImgUrl);

        //  NSLog(@"title below suffix: %@", title);
        //  NSLog(@"url below suffix: %@", baseImgUrl);
        
        
        // NSLog(@"detail: %@", baseImgUrl);
        NSData *downloadedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:baseImgUrl]];

        if (downloadedData) {
            
            // STORE IN FILESYSTEM
            NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *file = [cachesDirectory stringByAppendingPathComponent:baseImgUrl];
            [downloadedData writeToFile:file atomically:YES];
            
            // STORE IN MEMORY
            [memoryCache setObject:downloadedData forKey:baseImgUrl];
            
            baseUrl = [NSMutableString stringWithString:@"https://api.themoviedb.org/3/movie/"];
   //         NSLog(@"append 7 is %@ %@ %@", baseUrl, idOfMovie.description, key);
            [baseUrl appendString:idOfMovie.description ];
            [baseUrl appendString:credits];
            [baseUrl appendString:key];

            url=[NSURL URLWithString:baseUrl];
            data=[NSData dataWithContentsOfURL:url];
            //    NSLog(@"baseUrl: %@", baseUrl);
            
            error=nil;
            id response=[NSJSONSerialization JSONObjectWithData:data options:
                      NSJSONReadingMutableContainers error:&error];
            listOfActors = [response objectForKey:@"cast"]; //2
            
        }
        
       // [NSThread sleepForTimeInterval:3];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *movieImage = [UIImage imageWithData:downloadedData];
            self.poster.image = movieImage;
            self.synopsis.text = [responseObject objectForKey:@"overview"];
            [self.synopsis sizeToFit];
            
          //  NSLog(@" self.synopsisHeight %@ ", self.synopsisHeight);
            
            
            if(self.synopsis.frame.size.height < self.synopsisHeight.constant)
            {
                self.synopsisHeight.constant = self.synopsis.frame.size.height;
            }
            
            
            
            

            
            
            self.titleLabel.text = [responseObject objectForKey:@"title"];
            self.productionLabel.text = listOfProductionCompanies;
            self.genresLabel.text = listOfGenres;
            self.languageLabel.text = listOfLanguages;
            
            [self.scroller setHidden:YES];
            [self.downloadedView setHidden:NO];
            [self.scroller stopAnimating];

            // NSLog(@"title is: %@", self.titleLabel.text);
            //height
 
        });
        
    });
    
    //credits table
     baseUrl = [NSMutableString stringWithString:@"https://api.themoviedb.org/3/movie/"];
    [baseUrl appendString:idOfMovie.description ];
     [baseUrl appendString:credits];
     [baseUrl appendString:key];
     
     NSURL *url=[NSURL URLWithString:baseUrl];
     NSData *data=[NSData dataWithContentsOfURL:url];
     //    NSLog(@"baseUrl: %@", baseUrl);
     
     NSError *error =nil;
     id response=[NSJSONSerialization JSONObjectWithData:data options:
     NSJSONReadingMutableContainers error:&error];
     //    NSLog(@"credits are: %@", response);
     listOfActors = [response objectForKey:@"cast"]; //2
     //  NSLog(@"cast is %@", listOfActors);
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listOfActors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"] ;
    cell.imageView.image= nil;
    if(!cell)
    {
        NSLog(@"Cell is nil");
    }
    // Configure the cell.
    cell.textLabel.text = [[listOfActors objectAtIndex: [indexPath row]] objectForKey:@"name"];
    
    cell.detailTextLabel.text = [[listOfActors objectAtIndex: [indexPath row]] objectForKey:@"character"];
    
    NSString *cast_image_path = [[listOfActors objectAtIndex: [indexPath row]] objectForKey:@"profile_path"];
    
    baseImgUrl = [NSMutableString stringWithString:@"http://image.tmdb.org/t/p/w45"];
    
    
    if(![cast_image_path isEqual:[NSNull null]]){
      //  NSLog(@" I am nil? %@ %@", baseImgUrl, cast_image_path);
        UIImage *checkForImage = [castDictionary objectForKey:indexPath];
        if(checkForImage)
        {
    //        NSLog(@" found image ? $@", [checkForImage description]);
            cell.imageView.image= checkForImage;
        }
        else {
        [baseImgUrl appendString:cast_image_path];
       // NSLog(@" url cast%@ ", baseImgUrl);

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        NSURL * urlImage=[NSURL URLWithString:baseImgUrl];
        NSData *imagedata =[NSData dataWithContentsOfURL:urlImage];
        //    NSLog(@" IMage path? %@", baseImgUrl);

            dispatch_async(dispatch_get_main_queue(), ^{

        if(imagedata){
            
             UITableViewCell *newCell = (UITableViewCell *)[tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
   //          NSLog(@" Image downloaded ");
            UIImage *castImage = [UIImage imageWithData:imagedata];
            
            newCell.imageView.image = castImage;
            //      NSLog(@" Image set ");

            [cell setNeedsLayout];
            if(castImage)
                [castDictionary setObject:castImage forKey:indexPath];
            
        }
          
            });
            
        });
            
        }//else
    }
    
    else
    {
       // NSLog(@"cast image is %@", cast_image_path);
        UIImage *defaultImage = [UIImage imageNamed: @"images-3.jpeg"];
        [castDictionary setObject:defaultImage forKey:indexPath];

      //  NSLog(@"default image is %@", pimage);

        [cell.imageView setImage:defaultImage];
    }
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [listOfActors removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


@end
