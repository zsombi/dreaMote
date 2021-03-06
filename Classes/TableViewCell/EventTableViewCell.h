//
//  EventTableViewCell.h
//  dreaMote
//
//  Created by Moritz Venn on 09.03.08.
//  Copyright 2008-2012 Moritz Venn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TableViewCell/FastTableViewCell.h>

#import <Objects/EventProtocol.h>

/*!
 @brief Cell identifier for this cell.
 */
extern NSString *kEventCell_ID;

/*!
 @brief UITableViewCell optimized to display Events.
 */
@interface EventTableViewCell : FastTableViewCell

/*!
 @brief Event.
 */
@property (nonatomic, strong) NSObject<EventProtocol> *event;

/*!
 @brief Date Formatter.
 */
@property (nonatomic, strong) NSDateFormatter *formatter;

/*!
 @brief Display service name?

 @note This needs to be set before assigning a new event to work properly.
 Also the Events needs to keep a copy of the service.
 */
@property (nonatomic, assign) BOOL showService;

@end
