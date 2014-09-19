

#import "Movie.h"

@implementation Movie

- (Movie*) createMovieObjectFromJson: (NSDictionary*) results
{
//title, date, rating, synopsis, prod, genre, language
    self.title = [results objectForKey: @"original_title"];
    self.releaseDate = [results objectForKey: @"release_date"];
    self.rating = [results objectForKey:@"vote_average"];
    self.posterUrl = [results objectForKey:@"poster_path"];
    self.synopsis = [results objectForKey:@"overview"];
    self.production = [results objectForKey:@"poster_path"];
    self.genre = [results objectForKey:@"genres"];
    self.language = [ results objectForKey:@"spoken_languages"];
    self.id = [results objectForKey:@"id"];
    return self;
}

@end
