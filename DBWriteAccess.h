//
//  DBWriteAccess.h
//  NFL 2012 Pocket Schedule
//
//  Created by Gabriel Ortega on 8/12/12.
//
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "GameResult.h"

@interface DBWriteAccess : NSObject

#pragma mark - Database access

- (void) establishDatabase;
- (NSString *)dbFilePath;

#pragma mark - Database write access

- (void) updateGameResult:(NSMutableArray *)uArray;

@end
