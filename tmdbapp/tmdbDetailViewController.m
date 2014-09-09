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
    // Update the user interface for the detail item.

    if (self.detailItem) {
       // self.detailDescriptionLabel.text = [self.detailItem description];
    


    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
 //   [self.scroller setHidden:false];
//    [self.downloadedView setHidden:true];

    credits = @"/credits";
    NSString *idOfMovie = self.detailItem;
    
    baseUrl = [NSMutableString stringWithString:@"https://api.themoviedb.org/3/movie/"];
    key = [NSMutableString stringWithString:@"?api_key=c47afb8e8b27906bca710175d6e8ba68"];
    [baseUrl appendString:idOfMovie.description ];
    [baseUrl appendString:key];
    
    
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
    
    //async using queue
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
     NSData *downloadedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:baseImgUrl]];
    // NSLog(@"detail: %@", baseImgUrl);
     
     if (downloadedData) {
     
     // STORE IN FILESYSTEM
     NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
     NSString *file = [cachesDirectory stringByAppendingPathComponent:baseImgUrl];
     [downloadedData writeToFile:file atomically:YES];
     
     // STORE IN MEMORY
     [memoryCache setObject:downloadedData forKey:baseImgUrl];
     }
     
     dispatch_async(dispatch_get_main_queue(), ^{
     UIImage *movieImage = [UIImage imageWithData:downloadedData];
     self.poster.image = movieImage;
     self.synopsis.text = [response objectForKey:@"overview"];
     self.titleLabel.text = [response objectForKey:@"title"];
   // NSLog(@"title is: %@", self.titleLabel.text);

     });
     
     });
  
    //credits table
    baseUrl = [NSMutableString stringWithString:@"https://api.themoviedb.org/3/movie/"];
    [baseUrl appendString:idOfMovie.description ];
    [baseUrl appendString:credits];
    [baseUrl appendString:key];
    
   
    url=[NSURL URLWithString:baseUrl];
    data=[NSData dataWithContentsOfURL:url];
//    NSLog(@"baseUrl: %@", baseUrl);
    
    error=nil;
    response=[NSJSONSerialization JSONObjectWithData:data options:
              NSJSONReadingMutableContainers error:&error];
  //    NSLog(@"credits are: %@", response);
    listOfActors = [response objectForKey:@"cast"]; //2
    
  //  NSLog(@"cast is %@", listOfActors);
    

	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
   // [self.scroller setHidden:TRUE];
   // [self.downloadedView setHidden:false];
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
    
  if(!cell)
  {
      NSLog(@"Cell is nil");
  }
    // Configure the cell.
    cell.textLabel.text = [[listOfActors objectAtIndex: [indexPath row]] objectForKey:@"name"];
   // cell.imageView.image =
    cell.detailTextLabel.text = [[listOfActors objectAtIndex: [indexPath row]] objectForKey:@"character"];
    
    NSString *cast_image_path = [[listOfActors objectAtIndex: [indexPath row]] objectForKey:@"profile_path"];
    
    baseImgUrl = [NSMutableString stringWithString:@"http://image.tmdb.org/t/p/w500"];
    
    
    if(![cast_image_path isEqual:[NSNull null]]){
    [baseImgUrl appendString:cast_image_path];
    
   NSLog(@" cast url %@", baseImgUrl);

    
    NSURL * urlImage=[NSURL URLWithString:baseImgUrl];
    NSData *imagedata =[NSData dataWithContentsOfURL:urlImage];
    
    if(imagedata){
    UIImage *castImage = [UIImage imageWithData:imagedata];
    cell.imageView.image = castImage;
    }
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
