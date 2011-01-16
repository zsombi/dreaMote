//
//  ServiceListController.m
//  dreaMote
//
//  Created by Moritz Venn on 08.03.08.
//  Copyright 2008-2011 Moritz Venn. All rights reserved.
//

#import "ServiceListController.h"

#import "EventListController.h"

#import "Constants.h"
#import "RemoteConnectorObject.h"
#import "Objects/ServiceProtocol.h"

#import "ServiceEventTableViewCell.h"
#import "ServiceTableViewCell.h"

@interface ServiceListController()
- (void)fetchNowData;
- (void)fetchNextData;

/*!
 @brief Popover Controller.
 */
@property (nonatomic, retain) UIPopoverController *popoverController;
@end

@implementation ServiceListController

@synthesize popoverController;

/* initialize */
- (id)init
{
	if((self = [super init]))
	{
		self.title = NSLocalizedString(@"Services", @"Title of ServiceListController");
		_mainList = [[NSMutableArray array] retain];
		_subList = [[NSMutableArray array] retain];
		_refreshServices = YES;
		_eventListController = nil;
		_isRadio = NO;
		_delegate = nil;
		_supportsNowNext = NO;
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[_dateFormatter setTimeStyle:NSDateFormatterShortStyle];

		if([self respondsToSelector:@selector(modalPresentationStyle)])
		{
			self.modalPresentationStyle = UIModalPresentationFormSheet;
			self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		}
	}
	return self;
}

/* dealloc */
- (void)dealloc
{
	[_mainList release];
	[_subList release];
	[_eventListController release];
	[_mainXMLDoc release];
	[_subXMLDoc release];
	[_radioButton release];
	[_dateFormatter release];

	[super dealloc];
}

/* memory warning */
- (void)didReceiveMemoryWarning
{
	[_eventListController release];
	_eventListController = nil;

	[super didReceiveMemoryWarning];
}

/* getter for bouquet property */
- (NSObject<ServiceProtocol> *)bouquet
{
	return _bouquet;
}

/* setter for bouquet property */
- (void)setBouquet: (NSObject<ServiceProtocol> *)new
{
	// Same bouquet assigned, abort
	if(_bouquet == new) return;

	// Free old bouquet, retain new one
	[_bouquet release];
	_bouquet = [new copy];

	// Set Title
	self.title = new.sname;

	// Free Caches and reload data
	_supportsNowNext = [RemoteConnectorObject showNowNext];
	[self emptyData];
	_refreshServices = NO;

	// Eventually remove popover
	if(self.popoverController != nil) {
        [self.popoverController dismissPopoverAnimated:YES];
    }

	// Spawn a thread to fetch the event data so that the UI is not blocked while the
	// application parses the XML file.
	[NSThread detachNewThreadSelector:@selector(fetchData) toTarget:self withObject:nil];
}

/* getter for isRadio property */
- (BOOL)isRadio
{
	return _isRadio;
}

/* setter for isRadio property */
- (void)setIsRadio:(BOOL)new
{
	if(_isRadio == new) return;
	_isRadio = new;

	// Set title
	if(new)
	{
		self.title = NSLocalizedString(@"Radio Services", @"Title of Radio mode of ServiceListController");
		// since "radio" loses the (imo) most important information lets lose the less important one
		self.navigationController.tabBarItem.title = NSLocalizedString(@"Services", @"Title of ServiceListController");
	}
	else
	{
		self.title = NSLocalizedString(@"Services", @"Title of ServiceListController");
		self.navigationController.tabBarItem.title = self.title;
	}

	// pop to root view, needed on ipad when switching to radio in bouquet list
	[self.navigationController popToRootViewControllerAnimated: YES];

	// Refresh services
	if(_bouquet != nil)
	{
		self.bouquet = nil;
	}
	else
	{
		_refreshServices = YES;
		[self viewWillAppear: NO];
	}
}

/* switch radio mode */
- (void)switchRadio:(id)sender
{
	self.isRadio = !_isRadio;
	if(_isRadio)
		_radioButton.title = NSLocalizedString(@"TV", @"TV switch button");
	else
		_radioButton.title = NSLocalizedString(@"Radio", @"Radio switch button");
}

/* layout */
- (void)loadView
{
	_radioButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(switchRadio:)];
	if(_isRadio)
		_radioButton.title = NSLocalizedString(@"TV", @"TV switch button");
	else
		_radioButton.title = NSLocalizedString(@"Radio", @"Radio switch button");

	[super loadView];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.sectionHeaderHeight = 0;
}

/* about to appear */
- (void)viewWillAppear:(BOOL)animated
{
	if(!IS_IPAD())
	{
		const BOOL isSingleBouquet =
			[[RemoteConnectorObject sharedRemoteConnector] hasFeature: kFeaturesSingleBouquet]
			&& (
				[RemoteConnectorObject isSingleBouquet] ||
				![[RemoteConnectorObject sharedRemoteConnector] hasFeature: kFeaturesBouquets]);

		// show radio button if in single bouquet mode and supported
		if(isSingleBouquet &&
			[[RemoteConnectorObject sharedRemoteConnector] hasFeature: kFeaturesRadioMode])
		{
			self.navigationItem.rightBarButtonItem = _radioButton;
		}
		else
			self.navigationItem.rightBarButtonItem = nil;
	}

	/*!
	 @brief See if we should refresh services
	 @note If bouquet is nil we are in single bouquet mode and therefore we refresh here
	 and not in setBouquet:
	 */
	if(_refreshServices && _bouquet == nil)
	{
		_supportsNowNext = [RemoteConnectorObject showNowNext];

		[self emptyData];

		// Spawn a thread to fetch the service data so that the UI is not blocked while the
		// application parses the XML file.
		[NSThread detachNewThreadSelector:@selector(fetchData) toTarget:self withObject:nil];
	}
	else
	{
		// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
		NSIndexPath *tableSelection = [_tableView indexPathForSelectedRow];
		[_tableView deselectRowAtIndexPath:tableSelection animated:YES];
	}

	_refreshServices = YES;

	[super viewWillAppear: animated];
}

/* did disappear */
- (void)viewDidDisappear:(BOOL)animated
{
	if(_refreshServices && _bouquet == nil)
	{
		[self emptyData];
	}
}

/* fetch main list */
- (void)fetchData
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[_mainXMLDoc release];
	_reloading = YES;
	if(_supportsNowNext)
	{
		pendingRequests = 2;
		[NSThread detachNewThreadSelector:@selector(fetchNextData) toTarget:self withObject:nil];
		[NSThread detachNewThreadSelector:@selector(fetchNowData) toTarget:self withObject:nil];
	}
	else
	{
		pendingRequests = 1;
		_mainXMLDoc = [[[RemoteConnectorObject sharedRemoteConnector] fetchServices: self bouquet: _bouquet isRadio:_isRadio] retain];
	}
	[pool release];
}

/* fetch now list */
- (void)fetchNowData
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	_mainXMLDoc = [[[RemoteConnectorObject sharedRemoteConnector] getNow: self bouquet: _bouquet isRadio:_isRadio] retain];
	[pool release];
}

/* fetch next list */
- (void)fetchNextData
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[_subXMLDoc release];
	_mainXMLDoc = [[[RemoteConnectorObject sharedRemoteConnector] getNext: self bouquet: _bouquet isRadio:_isRadio] retain];
	[pool release];
}

/* remove content data */
- (void)emptyData
{
	// Clean event list
	[_mainList removeAllObjects];
	[_subList removeAllObjects];
	NSIndexSet *idxSet = [NSIndexSet indexSetWithIndex: 0];
	[_tableView reloadSections:idxSet withRowAnimation:UITableViewRowAnimationRight];
	[_mainXMLDoc release];
	_mainXMLDoc = nil;
	[_subXMLDoc release];
	_subXMLDoc = nil;
}

#pragma mark -
#pragma mark DataSourceDelegate
#pragma mark -

- (void)dataSourceDelegate:(BaseXMLReader *)dataSource errorParsingDocument:(CXMLDocument *)document error:(NSError *)error
{
	// NOTE: this might hide an error, but we prefer missing one over getting the same one twice
	if(--pendingRequests == 0)
	{
		_reloading = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		[_tableView reloadData];

		// Alert user
		const UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to retrieve data", @"")
															  message:[error localizedDescription]
															 delegate:nil
													cancelButtonTitle:@"OK"
													otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)dataSourceDelegate:(BaseXMLReader *)dataSource finishedParsingDocument:(CXMLDocument *)document
{
	if(--pendingRequests == 0)
	{
		_reloading = NO;
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		[_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	}
}

#pragma mark -
#pragma mark NowSourceDelegate
#pragma mark -

/* add event to list */
- (void)addNowEvent:(NSObject <EventProtocol>*)event
{
	if(event != nil)
	{
		const NSInteger idx = _mainList.count;
		[_mainList addObject: event];
		[_tableView insertRowsAtIndexPaths: [NSArray arrayWithObject: [NSIndexPath indexPathForRow:idx inSection:0]]
						  withRowAnimation: UITableViewRowAnimationLeft];
	}
}

#pragma mark -
#pragma mark NextSourceDelegate
#pragma mark -

/* add event to list */
- (void)addNextEvent:(NSObject <EventProtocol>*)event
{
	if(event != nil)
	{
		[_subList addObject: event];
	}
}

#pragma mark -
#pragma mark ServiceSourceDelegate
#pragma mark -

/* add service to list */
- (void)addService: (NSObject<ServiceProtocol> *)service
{
	if(service != nil)
	{
		//const NSInteger idx = [_mainList count];
		[_mainList addObject: service];
		/*[_tableView insertRowsAtIndexPaths: [NSArray arrayWithObject: [NSIndexPath indexPathForRow:idx inSection:0]]
						  withRowAnimation: UITableViewRowAnimationLeft];
		 */
	}
}

#pragma mark	-
#pragma mark		Table View
#pragma mark	-

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(_supportsNowNext)
		return kServiceEventCellHeight;
	return kServiceCellHeight;
}

/* cell for row */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	if(_supportsNowNext)
	{
		cell = [tableView dequeueReusableCellWithIdentifier: kServiceEventCell_ID];
		if(cell == nil)
			cell = [[[ServiceEventTableViewCell alloc] initWithFrame: CGRectZero reuseIdentifier: kServiceEventCell_ID] autorelease];

		NSObject<EventProtocol> *event = [_mainList objectAtIndex:indexPath.row];
		((ServiceEventTableViewCell *)cell).formatter = _dateFormatter;
		((ServiceEventTableViewCell *)cell).now = event;
		@try {
			event = [_subList objectAtIndex:indexPath.row];
			[(ServiceEventTableViewCell *)cell setNext:event];
		}
		@catch (NSException * e) {
			[(ServiceEventTableViewCell *)cell setNext:nil];
		}
	}
	else
	{
		cell = (ServiceTableViewCell*)[tableView dequeueReusableCellWithIdentifier: kServiceCell_ID];
		if(cell == nil)
			cell = [[[ServiceTableViewCell alloc] initWithFrame: CGRectZero reuseIdentifier: kServiceCell_ID] autorelease];

		((ServiceTableViewCell *)cell).service = [_mainList objectAtIndex:indexPath.row];
	}

	return cell;
}

/* select row */
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSObject<ServiceProtocol> *service = nil;
	if(_supportsNowNext)
		service = ((NSObject<EventProtocol > *)[_mainList objectAtIndex: indexPath.row]).service;
	else
		service = [_mainList objectAtIndex: indexPath.row];

	// Check for invalid service
	if(!service || !service.valid)
		return nil;
	// Callback mode
	else if(_delegate != nil)
	{
		[_delegate performSelector:@selector(serviceSelected:) withObject: service];
		if(IS_IPAD())
			[self.navigationController dismissModalViewControllerAnimated:YES];
		else
			[self.navigationController popToViewController: _delegate animated: YES];
	}
	// Load events
	else
	{
		if(_eventListController == nil)
			_eventListController = [[EventListController alloc] init];

		_eventListController.service = service;

		_refreshServices = NO;
		[self.navigationController pushViewController: _eventListController animated:YES];
	}
	return indexPath;
}

/* number of sections */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	// TODO: handle seperators?
	return 1;
}

/* number of rows */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [_mainList count];
}

/* set delegate */
- (void)setDelegate: (id<ServiceListDelegate, NSCoding>) delegate
{
	/*!
	 @note We do not retain the target, this theoretically could be a problem but
	 is not in this case.
	 */
	_delegate = delegate;
}

/* rotate with device */
- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark -
#pragma mark Split view support
#pragma mark -

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc
{
	barButtonItem.title = aViewController.title;
	self.navigationItem.leftBarButtonItem = barButtonItem;
	self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	self.navigationItem.leftBarButtonItem = nil;
	self.popoverController = nil;
}

@end
