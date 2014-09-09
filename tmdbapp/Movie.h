//
//  Movie.h
//  tmdbapp
//
//  Created by Pranav on 9/3/14.
//  Copyright (c) 2014 ___Pranav___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject
@property (nonatomic,strong) NSString *movieName;
@property (nonatomic,strong) NSString *movieRating;
@property (nonatomic,strong) NSString *movieUrl;
@property (nonatomic,strong) NSString *releaseDate;


@end
