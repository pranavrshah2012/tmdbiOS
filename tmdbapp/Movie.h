//
//  Movie.h
//  tmdbapp
//
//  Created by Pranav on 9/3/14.
//  Copyright (c) 2014 ___Pranav___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject
@property (nonatomic,strong, readwrite) NSString *name;
@property (nonatomic,strong, readwrite) NSString *rating;
@property (nonatomic,strong, readwrite) NSString *posterUrl;
@property (nonatomic,strong, readwrite) NSString *releaseDate;
@property (nonatomic, strong, readwrite) NSString *synopsis;
@property (nonatomic, strong, readwrite) NSString *genre;
@property (nonatomic, strong, readwrite) NSString *language;

@end
