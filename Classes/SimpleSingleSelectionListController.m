//
//  SimpleSingleSelectionListController.m
//  dreaMote
//
//  Created by Moritz Venn on 17.10.08.
//  Copyright 2008-2011 Moritz Venn. All rights reserved.
//

#import "SimpleSingleSelectionListController.h"

#import "Constants.h"
#import "RemoteConnectorObject.h"
#import "UITableViewCell+EasyInit.h"

@interface SimpleSingleSelectionListController()
/*!
 @brief done editing
 */
- (void)doneAction:(id)sender;
@property (nonatomic, retain) NSArray *items;
@end

@implementation SimpleSingleSelectionListController

@synthesize items = _items;
@synthesize selectedItem = _selectedItem;

/* initialize */
- (id)init
{
	if((self = [super init]))
	{
		self.title = nil;
		_delegate = nil;

		if([self respondsToSelector:@selector(modalPresentationStyle)])
		{
			self.modalPresentationStyle = UIModalPresentationFormSheet;
			self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		}
	}
	return self;
}

/* create SimpleSingleSelectionListController with given type preselected */
+ (SimpleSingleSelectionListController *)withItems:(NSArray *)items andSelection:(NSUInteger)selectedItem andTitle:(NSString *)title
{
	SimpleSingleSelectionListController *vc = [[SimpleSingleSelectionListController alloc] init];
	vc.selectedItem = selectedItem;
	vc.items = items;
	vc.title = title;

	return [vc autorelease];
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

	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			target:self action:@selector(doneAction:)];
	self.navigationItem.rightBarButtonItem = button;
	[button release];
}

/* finish */
- (void)doneAction:(id)sender
{
	if(IS_IPAD())
		[self.navigationController dismissModalViewControllerAnimated:YES];
	else
		[self.navigationController popViewControllerAnimated:YES];
}

/* rotate with device */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark - UITableView delegates

/* title for section */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

/* rows in section */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _items.count;
}

/* to determine which UITableViewCell to be used on a given row. */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [UITableViewCell reusableTableViewCellInView:tableView withIdentifier:kVanilla_ID];;
	const NSInteger row = indexPath.row;

	cell.textLabel.text = [_items objectAtIndex:row];

	if((NSUInteger)row == _selectedItem)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;

	return cell;
}

/* row selected */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath: indexPath animated: YES];

	UITableViewCell *cell = [tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow: _selectedItem inSection: 0]];
	cell.accessoryType = UITableViewCellAccessoryNone;

	cell = [tableView cellForRowAtIndexPath: indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;

	_selectedItem = indexPath.row;

	if(IS_IPAD())
	{
		[self dismissModalViewControllerAnimated:YES];
	}
}

/* set delegate */
- (void)setDelegate: (id<SimpleSingleSelectionListDelegate>) delegate
{
	// we only borrow the reference to our delegate, but given our life is shorter than that of our parent there should be no problem
	_delegate = delegate;
}

#pragma mark - UIViewController delegate methods

/* about to disappear */
- (void)viewWillDisappear:(BOOL)animated
{
	if(_delegate != nil)
	{
		[_delegate performSelector:@selector(itemSelected:) withObject:[NSNumber numberWithInteger:_selectedItem]];
	}
}

@end