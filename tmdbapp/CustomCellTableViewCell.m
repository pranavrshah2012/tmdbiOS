//
//  CustomCellTableViewCell.m
//  tmdbapp
//
//  Created by Pranav on 9/4/14.
//  Copyright (c) 2014 ___Pranav___. All rights reserved.
//

#import "CustomCellTableViewCell.h"

@implementation CustomCellTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
