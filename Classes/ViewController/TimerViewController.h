//
//  TimerViewController.h
//  dreaMote
//
//  Created by Moritz Venn on 10.03.08.
//  Copyright 2008-2012 Moritz Venn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Objects/EventProtocol.h" /* EventProtocol */
#import "Objects/ServiceProtocol.h" /* ServiceProtocol */
#import "Objects/TimerProtocol.h" /* TimerProtocol */
#import "CellTextField.h" /* CellTextField */

#import "AfterEventViewController.h" /* AfterEventDelegate */
#import "ServiceListController.h" /* ServiceListDelegate */
#import "SimpleRepeatedViewController.h" /* RepeatedDelegate */
#import "MGSplitViewController.h" /* MGSplitViewControllerDelegate */

// Forward declarations...
@protocol TimerViewDelegate;

/*!
 @brief Timer View.
 
 Display further information about a timer and allow to edit its configuration.
 */
@interface TimerViewController : UIViewController <UITextFieldDelegate,
													UITableViewDelegate, UITableViewDataSource,
													ServiceListDelegate, AfterEventDelegate,
													EditableTableViewCellDelegate,
													UIPopoverControllerDelegate,
													MGSplitViewControllerDelegate>
{
@private
	UIPopoverController *popoverController;
	UIBarButtonItem *_cancelButtonItem;
	UIBarButtonItem *_popoverButtonItem;
	UITableView *_tableView;

	UITextField *_timerTitle; /*!< @brief Title Field. */
	CellTextField *_titleCell; /*!< @brief Title Cell. */
	UITextField *_timerDescription; /*!< @brief Description Field. */
	CellTextField *_descriptionCell; /*!< @brief Description Cell. */
	UISwitch *_timerEnabled; /*!< @brief Enabled Switch. */
	UISwitch *_timerJustplay; /*!< @brief Justplay Switch. */
	UISwitch *_vpsEnabled; /*!< @brief VPS-Enabled Switch. */
	UISwitch *_vpsOverwrite; /*!< @brief VPS-Overwrite Switch. */

	NSObject<EventProtocol> *_event; /*!< @brief Associated Event. */
	NSObject<TimerProtocol> *_timer; /*!< @brief Associated Timer. */
	NSObject<TimerProtocol> *_oldTimer; /*!< @brief Old Timer when changing existing one. */
	BOOL _creatingNewTimer; /*!< @brief Are we creating a new timer? */
	BOOL _shouldSave; /*!< @brief Should save on exit? */

	UIViewController *_afterEventNavigationController; /*!< @brief Navigation Controller of After Event Selector. */
	AfterEventViewController *_afterEventViewController; /*!< @brief Cached After Event Selector. */
	UIViewController *_bouquetListController; /*!< @brief Cached Bouquet List. */
}

/*!
 @brief Open new TimerViewController for given Event.
 
 @param ourEvent Base Event.
 @return TimerViewController instance.
 */
+ (TimerViewController *)newWithEvent: (NSObject<EventProtocol> *)ourEvent;

/*!
 @brief Open new TimerViewController for given Event and Service.
 
 @param ourEvent Base Event.
 @param ourService Event Service.
 @return TimerViewController instance.
 */
+ (TimerViewController *)newWithEventAndService: (NSObject<EventProtocol> *)ourEvent: (NSObject<ServiceProtocol> *)ourService;

/*!
 @brief Open new TimerViewController for given Timer.
 
 @param ourTimer Base Timer.
 @return TimerViewController instance.
 */
+ (TimerViewController *)newWithTimer: (NSObject<TimerProtocol> *)ourTimer;

/*!
 @brief Open new TimerViewController for new Timer.
 
 @return TimerViewController instance.
 */
+ (TimerViewController *)newTimer;



/*!
 @brief Timer.
 */
@property (nonatomic, strong) NSObject<TimerProtocol> *timer;

/*!
 @brief Old Timer if editing existing one.
 */
@property (nonatomic, strong) NSObject<TimerProtocol> *oldTimer;

/*!
 @brief Are we creating a new Timer?
 */
@property (assign) BOOL creatingNewTimer;

/*!
 @brief Delegate.
 */
@property (nonatomic, strong) NSObject<TimerViewDelegate> *delegate;

/*!
 @brief Table View.
 */
@property (nonatomic, readonly) UITableView *tableView;

@end



@protocol TimerViewDelegate
/*!
 @brief A timer was added successfully.

 @param tvc TimerViewController instance
 @param timer Timer that was added
 */
- (void)timerViewController:(TimerViewController *)tvc timerWasAdded:(NSObject<TimerProtocol> *)timer;

/*!
 @brief Timer was changed successfully.

 @param tvc TimerViewController instance
 @param timer Modified timer
 @param oldTimer Original timer
 */
- (void)timerViewController:(TimerViewController *)tvc timerWasEdited:(NSObject<TimerProtocol> *)timer :(NSObject<TimerProtocol> *)oldTimer;

/*
 @brief Editing was canceled.

 @param tvc TimerViewController instance
 @param timer Timer that was supposed to be changed
 */
- (void)timerViewController:(TimerViewController *)tvc editingWasCanceled:(NSObject<TimerProtocol> *)timer;
@end
