/*
 DCTTableViewSectionController.m
 DCTUIKit
 
 Created by Daniel Tull on 16.09.2010.
 
 
 
 Copyright (c) 2010 Daniel Tull. All rights reserved.
 
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

#import "DCTTableViewSectionController.h"

@interface DCTTableViewSectionController ()
- (id<UITableViewDataSource>)dctInternal_dataSourceForIndex:(NSInteger)index;
- (NSIndexPath *)dctInternal_convertedIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)dctInternal_convertedSection:(NSInteger)section;
- (NSMutableArray *)dctInternal_tableViewDataSources;
@end

@implementation DCTTableViewSectionController {
	__strong NSMutableArray *dctInternal_tableViewDataSources;
}

@synthesize tableView;

#pragma mark - DCTTableViewSectionController methods

- (void)addTableViewDataSource:(id<UITableViewDataSource>)tableViewDataSource {
	
	NSMutableArray *ds = [self dctInternal_tableViewDataSources];
	
	[ds addObject:tableViewDataSource];
	
	SEL setTableViewSelector = @selector(setTableView:);
	if ([tableViewDataSource respondsToSelector:setTableViewSelector])
		[tableViewDataSource performSelector:setTableViewSelector withObject:self.tableView];
	
	SEL setSectionControllerSelector = @selector(setSectionController:);
	if ([tableViewDataSource respondsToSelector:setSectionControllerSelector])
		[tableViewDataSource performSelector:setSectionControllerSelector withObject:self.tableView];
		
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[ds indexOfObject:tableViewDataSource]];
	[self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)removeTableViewDataSource:(id<UITableViewDataSource>)tableViewDataSource {
	
	NSMutableArray *ds = [self dctInternal_tableViewDataSources];
	
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[ds indexOfObject:tableViewDataSource]];
	
	[ds removeObject:tableViewDataSource];
	
	[self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSArray *)tableViewDataSources {
	return [[self dctInternal_tableViewDataSources] copy];
}

- (void)setTableViewDataSources:(NSArray *)array {
	dctInternal_tableViewDataSources = [array mutableCopy];
	[self.tableView reloadData];	
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[self dctInternal_tableViewDataSources] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	
	id<UITableViewDataSource> ds = [self dctInternal_dataSourceForIndex:section];
	
	return [ds tableView:table numberOfRowsInSection:[self dctInternal_convertedSection:section]];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	id<UITableViewDataSource> ds = [self dctInternal_dataSourceForIndex:indexPath.section];
	
	return [ds tableView:tv cellForRowAtIndexPath:[self dctInternal_convertedIndexPath:indexPath]];
}

- (NSString *)tableView:(UITableView *)tv titleForFooterInSection:(NSInteger)section {
	
	id<UITableViewDataSource> ds = [self dctInternal_dataSourceForIndex:section];
	
	if ([ds respondsToSelector:_cmd])
		return [ds tableView:tv titleForFooterInSection:[self dctInternal_convertedSection:section]];
	
	return nil;
}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
	
	id<UITableViewDataSource> ds = [self dctInternal_dataSourceForIndex:section];
	
	section = [self dctInternal_convertedSection:section];
	
	if ([ds respondsToSelector:_cmd])
		return [ds tableView:tv titleForHeaderInSection:[self dctInternal_convertedSection:section]];
	
	return nil;
}

- (BOOL)tableView:(UITableView *)tv canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	
	id<UITableViewDataSource> ds = [self dctInternal_dataSourceForIndex:indexPath.section];
	
	if ([ds respondsToSelector:_cmd])
		[ds tableView:tv canEditRowAtIndexPath:[self dctInternal_convertedIndexPath:indexPath]];
	
	return NO;
	
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	id<UITableViewDataSource> ds = [self dctInternal_dataSourceForIndex:indexPath.section];
	
	if ([ds respondsToSelector:_cmd])
		[ds tableView:tv commitEditingStyle:editingStyle forRowAtIndexPath:[self dctInternal_convertedIndexPath:indexPath]];
}

#pragma mark - Private methods

- (id<UITableViewDataSource>)dctInternal_dataSourceForIndex:(NSInteger)index {
	return [[self dctInternal_tableViewDataSources] objectAtIndex:index];
}

- (NSIndexPath *)dctInternal_convertedIndexPath:(NSIndexPath *)indexPath {
	return [NSIndexPath indexPathForRow:indexPath.row inSection:[self dctInternal_convertedSection:indexPath.section]];
}

- (NSInteger)dctInternal_convertedSection:(NSInteger)section {
	return 0;
}

- (NSMutableArray *)dctInternal_tableViewDataSources {
	
	if (dctInternal_tableViewDataSources == nil) dctInternal_tableViewDataSources = [[NSMutableArray alloc] init];
	
	return dctInternal_tableViewDataSources;	
}

@end
