

#import <Foundation/Foundation.h>

@interface Movie : NSObject
@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) NSString *rating;
@property (nonatomic, readwrite) NSString *posterUrl;
@property (nonatomic, readwrite) NSString *releaseDate;
@property (nonatomic, readwrite) NSString *synopsis;
@property (nonatomic, readwrite) NSString *genre;
@property (nonatomic, readwrite) NSString *language;
@property (nonatomic, readwrite) NSString *production;
@property (nonatomic, readwrite) NSString *id;

- (Movie*) createMovieObjectFromJson : (NSDictionary*) results;


@end
