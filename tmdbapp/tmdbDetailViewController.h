//
//  tmdbDetailViewController.h
//  tmdbapp
//
//  Created by Pranav on 9/3/14.
//  Copyright (c) 2014 ___Pranav___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tmdbDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (readwrite) NSString *detailTitle;
@property (weak, nonatomic) IBOutlet UILabel *cast;
@property (weak, nonatomic) IBOutlet UIImageView *poster;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *synopsis;
@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *downloadedView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scroller;



@end
