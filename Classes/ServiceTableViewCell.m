//
//  ServiceTableViewCell.m
//  Untitled
//
//  Created by Moritz Venn on 08.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "ServiceTableViewCell.h"

@interface ServiceTableViewCell()
- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;
@end

@implementation ServiceTableViewCell

@synthesize serviceNameLabel = _serviceNameLabel;

+ (void)initialize
{
	// TODO: anything to be done here?
}

- (void)dealloc
{
	[_serviceNameLabel release];

	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		UIView *myContentView = self.contentView;

		// you can do this here specifically or at the table level for all cells
		self.accessoryType = UITableViewCellAccessoryNone;

		// A label that displays the Servicename.
		self.serviceNameLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:14.0 bold:YES];
		self.serviceNameLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview: self.serviceNameLabel];
		[self.serviceNameLabel release];
	}

	return self;
}

- (Service*)service
{
	return _service;
}

- (void)setService:(Service *)newService
{
	if(_service == newService) return;

	[_service release];
	_service = [newService retain];

	self.serviceNameLabel.text = newService.sname;

	[self setNeedsDisplay];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect contentRect = self.contentView.bounds;
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
	if (!self.editing) {
		CGRect frame;
		
		// Place the location label.
		frame = CGRectMake(contentRect.origin.x + kLeftMargin, 1, contentRect.size.width - kRightMargin, 20);
		self.serviceNameLabel.frame = frame;
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	/*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so in newLabelForMainText: the labels are made opaque and given a white background.  To show selection properly,   |however, the views need to be transparent (so that the selection color shows through).  
	 */
	[super setSelected:selected animated:animated];
	
	UIColor *backgroundColor = nil;
	if (selected) {
		backgroundColor = [UIColor clearColor];
	} else {
		backgroundColor = [UIColor whiteColor];
	}

	self.serviceNameLabel.backgroundColor = backgroundColor;
	self.serviceNameLabel.highlighted = selected;
	self.serviceNameLabel.opaque = !selected;
}

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold
{
	/*
	 Create and configure a label.
	 */
	
	UIFont *font;
	if (bold) {
		font = [UIFont boldSystemFontOfSize:fontSize];
	} else {
		font = [UIFont systemFontOfSize:fontSize];
	}
	
	/*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so set these defaults.  To show selection properly, however, the views need to be transparent (so that the	  |selection color shows through).  This is handled in setSelected:animated:.
	 */
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	newLabel.backgroundColor = [UIColor whiteColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = selectedColor;
	newLabel.font = font;
	
	return newLabel;
}

@end
