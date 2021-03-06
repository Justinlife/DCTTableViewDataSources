//
//  _DCTTableViewDataSourceUpdate.h
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 08.10.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTTableViewDataSource.h"

@interface _DCTTableViewDataSourceUpdate : NSObject
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) DCTTableViewDataSourceUpdateType type;
@property (nonatomic, assign) UITableViewRowAnimation animation;
- (BOOL)isSectionUpdate;
@end
