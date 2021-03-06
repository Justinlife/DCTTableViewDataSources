/*
 DCTHorizontalTableViewDataSource.m
 DCTTableViewDataSources
 
 Created by Daniel Tull on 21.12.2011.
 
 
 
 Copyright (c) 2011 Daniel Tull. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "DCTHorizontalTableViewDataSource.h"
#import <QuartzCore/QuartzCore.h>

@implementation DCTHorizontalTableViewDataSource

- (id)initWithChildTableViewDataSource:(DCTTableViewDataSource *)childTableViewDataSource {
	self = [super init];
	if (!self) return nil;
	_childTableViewDataSource = childTableViewDataSource;
	return self;
}

- (NSArray *)childTableViewDataSources {
	return [NSArray arrayWithObject:self.childTableViewDataSource];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

	[CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	cell.transform = CGAffineTransformMakeRotation(M_PI_2);
    [CATransaction commit];

	//cell.backgroundView.transform = CGAffineTransformMakeRotation(M_PI_2);

	//cell.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
	
    return cell;
}

- (void)setTableView:(UITableView *)tableView {
	
	UIView *view = [[UIView alloc] initWithFrame:tableView.frame];
	view.autoresizingMask = tableView.autoresizingMask;

	tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
	tableView.frame = view.bounds;

	[tableView.superview insertSubview:view belowSubview:tableView];
	[tableView removeFromSuperview];
	[view addSubview:tableView];

	CGRect frame = view.frame;
	view.transform = CGAffineTransformMakeRotation(-M_PI_2);
	view.frame = frame;
	[super setTableView:tableView];
}

@end
