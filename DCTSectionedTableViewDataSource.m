/*
 DCTSectionedTableViewDataSource.m
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

#import "DCTSectionedTableViewDataSource.h"

@interface DCTSectionedTableViewDataSource ()
- (NSMutableArray *)dctInternal_tableViewDataSources;
- (void)dctInternal_setupDataSource:(id<DCTTableViewDataSource>)dataSource;
@end

@implementation DCTSectionedTableViewDataSource {
	__strong NSMutableArray *dctInternal_tableViewDataSources;
	BOOL tableViewHasSetup;
}

@synthesize type;

#pragma mark - DCTParentTableViewDataSource

- (NSArray *)childTableViewDataSources {
	return [[self dctInternal_tableViewDataSources] copy];
}

- (NSIndexPath *)childTableViewDataSource:(id<DCTTableViewDataSource>)dataSource tableViewIndexPathForDataIndexPath:(NSIndexPath *)indexPath {
	
	NSArray *dataSources = [self dctInternal_tableViewDataSources];
	
	if (self.type == DCTSectionedTableViewDataSourceTypeRow) {
		
		__block NSInteger row = indexPath.row;
		
		[dataSources enumerateObjectsUsingBlock:^(id<DCTTableViewDataSource> ds, NSUInteger idx, BOOL *stop) {
						
			if ([ds isEqual:dataSource])
				*stop = YES;
			else
				row += [ds tableView:self.tableView numberOfRowsInSection:0];
			
		}];
		
		indexPath = [NSIndexPath indexPathForRow:row inSection:0];
		
	} else {
		
		indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:[dataSources indexOfObject:dataSource]];
	}
	
	if (!self.parent) return indexPath;
	
	return [self.parent childTableViewDataSource:self tableViewIndexPathForDataIndexPath:indexPath];
}

- (NSInteger)childTableViewDataSource:(id<DCTTableViewDataSource>)dataSource tableViewSectionForDataSection:(NSInteger)section {
	
	if (self.type == DCTSectionedTableViewDataSourceTypeRow) 
		section = 0;
	else 
		section = [[self dctInternal_tableViewDataSources] indexOfObject:dataSource];
	
	if (!self.parent) return section;
	
	return [self.parent childTableViewDataSource:self tableViewSectionForDataSection:section];
}

- (NSIndexPath *)dataIndexPathForTableViewIndexPath:(NSIndexPath *)indexPath {
	
	if (self.type == DCTSectionedTableViewDataSourceTypeRow) {
		
		__block NSInteger totalRows = 0;
		NSInteger row = indexPath.row;
		
		[[self dctInternal_tableViewDataSources] enumerateObjectsUsingBlock:^(id<DCTTableViewDataSource> ds, NSUInteger idx, BOOL *stop) {
			
			NSInteger numberOfRows = [ds tableView:self.tableView numberOfRowsInSection:0];
						
			if ((totalRows + numberOfRows) > row)
				*stop = YES;
			else
				totalRows += numberOfRows;
		}];
		
		row = indexPath.row - totalRows;
		
		return [NSIndexPath indexPathForRow:row inSection:0];
	}
	
	return [NSIndexPath indexPathForRow:indexPath.row inSection:0];
}

- (NSInteger)dataSectionForTableViewSection:(NSInteger)section {
	return 0;
}

- (id<DCTTableViewDataSource>)childDataSourceForSection:(NSInteger)section {
	
	NSArray *dataSources = [self dctInternal_tableViewDataSources];
	
	if (self.type == DCTSectionedTableViewDataSourceTypeRow) {
		
		NSAssert([dataSources count] > 0, @"Something's gone wrong.");
		
		return [dataSources objectAtIndex:0];
	}
	
	return [dataSources objectAtIndex:section];
}

- (id<DCTTableViewDataSource>)childDataSourceForIndexPath:(NSIndexPath *)indexPath {
	
	if (self.type == DCTSectionedTableViewDataSourceTypeRow) {
		
		__block NSInteger totalRows = 0;
		__block id<DCTTableViewDataSource> dataSource = nil;
		NSInteger row = indexPath.row;
		
		[[self dctInternal_tableViewDataSources] enumerateObjectsUsingBlock:^(id<DCTTableViewDataSource> ds, NSUInteger idx, BOOL *stop) {
			
			NSInteger numberOfRows = [ds tableView:self.tableView numberOfRowsInSection:0];
			
			totalRows += numberOfRows;
			
			if (totalRows > row) {
				dataSource = ds;
				*stop = YES;
			}
		}];
		
		return dataSource;
	}
	
	return [[self dctInternal_tableViewDataSources] objectAtIndex:indexPath.section];
}

- (BOOL)tableViewDataSourceShouldUpdateCells:(id<DCTTableViewDataSource>)dataSource {
	
	if (!self.parent) return YES;
		
	return [self.parent tableViewDataSourceShouldUpdateCells:self];	
}


#pragma mark - DCTTableViewSectionController methods

- (void)addChildTableViewDataSource:(id<DCTTableViewDataSource>)tableViewDataSource {
	
	NSMutableArray *ds = [self dctInternal_tableViewDataSources];
	
	[ds addObject:tableViewDataSource];
	
	[self dctInternal_setupDataSource:tableViewDataSource];
	
	if (!tableViewHasSetup) return;
	
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[ds indexOfObject:tableViewDataSource]];
	[self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)removeChildTableViewDataSource:(id<DCTTableViewDataSource>)tableViewDataSource {
	
	NSMutableArray *ds = [self dctInternal_tableViewDataSources];
	
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[ds indexOfObject:tableViewDataSource]];
	
	[ds removeObject:tableViewDataSource];
	
	if (!tableViewHasSetup) return;
	
	[self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setTableViewDataSources:(NSArray *)array {
	dctInternal_tableViewDataSources = [array mutableCopy];
	
	if (!tableViewHasSetup) return;
	
	[self.tableView reloadData];	
}

- (void)setTableView:(UITableView *)tv {
	
	if (tv == self.tableView) return;
	
	[super setTableView:tv];
	
	[[self dctInternal_tableViewDataSources] enumerateObjectsUsingBlock:^(id<DCTTableViewDataSource> ds, NSUInteger idx, BOOL *stop) {
		[self dctInternal_setupDataSource:ds];
	}];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	tableViewHasSetup = YES;
	self.tableView = tv;
	return [[self dctInternal_tableViewDataSources] count];
}

#pragma mark - Private methods

- (NSMutableArray *)dctInternal_tableViewDataSources {
	
	if (!dctInternal_tableViewDataSources) 
		dctInternal_tableViewDataSources = [[NSMutableArray alloc] init];
	
	return dctInternal_tableViewDataSources;	
}
		 
- (void)dctInternal_setupDataSource:(id<DCTTableViewDataSource>)dataSource {
	dataSource.tableView = self.tableView;
	dataSource.parent = self;
}

@end
