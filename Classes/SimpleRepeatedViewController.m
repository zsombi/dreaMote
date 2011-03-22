//
//  SimpleRepeatedViewController.m
//  dreaMote
//
//  Created by Moritz Venn on 19.06.09.
//  Copyright 2009-2011 Moritz Venn. All rights reserved.
//

#import "SimpleRepeatedViewController.h"

#import "Constants.h"
#import "UITableViewCell+EasyInit.h"

#import "TimerProtocol.h"

@interface SimpleRepeatedViewController()
- (IBAction)doneAction:(id)sender;
@end

@implementation SimpleRepeatedViewController

/* initialize */
- (id)init
{
	if((self = [super init]))
	{
		self.title = NSLocalizedString(@"Repeated", @"Default title of SimpleRepeatedViewController");

		if([self respondsToSelector:@selector(modalPresentationStyle)])
		{
			self.modalPresentationStyle = UIModalPresentationFormSheet;
			self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		}
	}
	return self;
}

/* create new SimpleRepeatedViewController instance with given flags */
+ (SimpleRepeatedViewController *)withRepeated: (NSInteger)repeated
{
	SimpleRepeatedViewController *simpleRepeatedViewController = [[SimpleRepeatedViewController alloc] init];
	simpleRepeatedViewController.repeated = repeated;

	return [simpleRepeatedViewController autorelease];
}

- (NSInteger)repeated
{
	return _repeated;
}

- (void)setRepeated:(NSInteger)newRepeated
{
	_repeated = newRepeated;
	[(UITableView *)self.view reloadData];
}

/* dealloc */
- (void)dealloc
{
	[super dealloc];
}

/* layout */
- (void)loadView
{
	// create and configure the table view
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];	
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.rowHeight = kUIRowHeight;

	// setup our content view so that it auto-rotates along with the UViewController
	tableView.autoresizesSubviews = YES;
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

	self.view = tableView;
	[tableView release];

	if(IS_IPAD())
	{
		UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
		self.navigationItem.rightBarButtonItem = barButtonItem;
		[barButtonItem release];
	}
}

/* rotate with device */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

/* done editing */
- (IBAction)doneAction:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableView delegates

/* header */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

/* rows in section */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 7;
}

/* to determine which UITableViewCell to be used on a given row. */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [UITableViewCell reusableTableViewCellInView:tableView withIdentifier:kVanilla_ID];

	// we are creating a new cell, setup its attributes
	switch(indexPath.row)
	{
		case 0:
			TABLEVIEWCELL_TEXT(cell) = NSLocalizedString(@"Monday", @"");
			break;
		case 1:
			TABLEVIEWCELL_TEXT(cell) = NSLocalizedString(@"Tuesday", @"");
			break;
		case 2:
			TABLEVIEWCELL_TEXT(cell) = NSLocalizedString(@"Wednesday", @"");
			break;
		case 3:
			TABLEVIEWCELL_TEXT(cell) = NSLocalizedString(@"Thursday", @"");
			break;
		case 4:
			TABLEVIEWCELL_TEXT(cell) = NSLocalizedString(@"Friday", @"");
			break;
		case 5:
			TABLEVIEWCELL_TEXT(cell) = NSLocalizedString(@"Saturday", @"");
			break;
		case 6:
			TABLEVIEWCELL_TEXT(cell) = NSLocalizedString(@"Sunday", @"");
			break;
		default:
			break;
	}

	if(_repeated & (1 << indexPath.row))
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;

	return cell;
}

/* select row */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	const UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];

	[tableView deselectRowAtIndexPath: indexPath animated: YES];

	// Already selected, deselect
	if(_repeated & (1 << indexPath.row))
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
		_repeated &= ~(1 << indexPath.row);
	}
	// Not selected, select
	else
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		_repeated |= (1 << indexPath.row);
	}
}

/* set delegate */
- (void)setDelegate: (id<SimpleRepeatedDelegate>) delegate
{
	/*!
	 @note We do not retain the target, this theoretically could be a problem but
	 is not in this case.
	 */
	_delegate = delegate;
}

#pragma mark - UIViewController delegate methods

/* about to disapper */
- (void)viewWillDisappear:(BOOL)animated
{
	if(_delegate != nil)
	{
		[_delegate performSelector:@selector(simpleRepeatedSelected:) withObject: [NSNumber numberWithInteger: _repeated]];
	}
}

@end
