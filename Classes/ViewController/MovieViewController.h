//
//  MovieViewController.h
//  dreaMote
//
//  Created by Moritz Venn on 09.03.08.
//  Copyright 2008-2012 Moritz Venn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MovieProtocol.h"
#import "SwipeTableView.h" /* SwipeTableViewDelegate */
#import "MGSplitViewController.h" /* MGSplitViewControllerDelegate */

@class MovieListController;

/*!
 @brief Movie View.
 
 Display further information about a movie. Also allows to start playback if RemoteConnector
 supports it.
 */
@interface MovieViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,
#if IS_FULL()
													SwipeTableViewDelegate,
#endif
													MGSplitViewControllerDelegate>
{
@private
	MovieListController *movieList; /*!< @brief Parent movie list. */
	UIPopoverController *popoverController; /*!< @brief Popover controller. */
	NSObject<MovieProtocol> *_movie; /*!< @brief Movie. */
	UITextView *_summaryView; /*!< @brief Summary of the movie. */
	UITableView *_tableView; /*!< @brief Table View. */
}

/*!
 @brief Open new view for given movie.
 
 @param newMovie Movie to open view for.
 @return MovieViewController instance.
 */
+ (MovieViewController *)withMovie: (NSObject<MovieProtocol> *) newMovie;



/*!
 @brief Movie.
 */
@property (nonatomic, strong) NSObject<MovieProtocol> *movie;

/*!
 @brief Movie List.
 */
@property (nonatomic, strong) MovieListController *movieList;

/*!
 @brief Table View.
 */
@property (nonatomic, readonly) UITableView *tableView;

@end
