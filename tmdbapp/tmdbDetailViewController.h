//
//  tmdbDetailViewController.h
//  tmdbapp
//
//  Created by Pranav on 9/3/14.
//  Copyright (c) 2014 ___Pranav___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tmdbDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
