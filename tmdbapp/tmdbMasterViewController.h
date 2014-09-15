//
//  tmdbMasterViewController.h
//  tmdbapp
//
//  Created by Pranav on 9/3/14.
//  Copyright (c) 2014 ___Pranav___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tmdbMasterViewController : UIViewController <UISearchDisplayDelegate>
@property (readwrite) int index;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (readwrite) NSString *chosenTitle;
@property (strong, nonatomic) IBOutlet UITableView *masterView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *scrollWheel;
@property (nonatomic, strong) NSMutableArray *searchResult;

@end

