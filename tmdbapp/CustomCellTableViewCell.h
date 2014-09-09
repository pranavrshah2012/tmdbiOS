//
//  CustomCellTableViewCell.h
//  tmdbapp
//
//  Created by Pranav on 9/4/14.
//  Copyright (c) 2014 ___Pranav___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;


@end
