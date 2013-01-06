//
//  DBWriteAccess.m
//  NFL 2012 Pocket Schedule
//
//  Created by Gabriel Ortega on 8/12/12.
//
//

#import "DBWriteAccess.h"
#import "Common.h"

@implementation DBWriteAccess

#pragma mark - Database access

/* Copy DB from bundle to location on user's device, i.e. the app doc directory
 -- do this every time to allow for DB being updated --> Q: since the DB is static (never updated by the user) should the methods below just read from the bundle instance?  TBA  */
- (void) establishDatabase
{
	NSString *dbPath = [self dbFilePath];
	
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	
	if (![fileMgr fileExistsAtPath:dbPath])
	{
		[fileMgr copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDBName] toPath:dbPath error:nil];
	}
	else
	{
		//[fileMgr removeItemAtPath:dbPath error:nil];
		//[fileMgr copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDBName] toPath:dbPath error:nil];
		
	}
}

// Return path name (including DB name) where the DB will be store on the user's device
- (NSString *) dbFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docDir = [paths objectAtIndex:0];
	return [docDir stringByAppendingPathComponent:kDBName];
	
}

- (void)test:(GameResult *)result
{
    NSLog(@"ID: %d",[result ID]);
    NSLog(@"Period: %d",[result currentPeriod]);
    NSLog(@"Final: %d",[result final]);
    NSLog(@"Q1: %d",[result Q1]);
    NSLog(@"Q2: %d",[result Q2]);
    NSLog(@"Q3: %d",[result Q3]);
    NSLog(@"Q4: %d",[result Q4]);
    NSLog(@"OT1: %d",[result OT1]);
    NSLog(@"OT2: %d",[result OT2]);
    NSLog(@"OT3: %d",[result OT3]);
    NSLog(@"OT4: %d",[result OT4]);
    NSLog(@"Total Plays: %d",[result totalPlays]);
    NSLog(@"Total Yards: %f",[result totalYards]);
    NSLog(@"Passing Yards: %f",[result passingYards]);
    NSLog(@"Rushing Yards: %f",[result rushingYards]);
    NSLog(@"Turnovers: %d",[result turnovers]);
    NSLog(@"Time of Possession: %d",[result timeOfPossession]);
}


#pragma mark - Database write access

- (void) updateGameResult:(NSMutableArray *)uArray
{
    sqlite3 *db = [[Common sharedInstance] dbConnection];
	
	//Establish connection to db
	//if (sqlite3_open([[self dbFilePath] UTF8String], &db) == SQLITE_OK)
	//{
        const char *query = "UPDATE Game_Result SET Final = ?, Q1 = ?, Q2 = ?, Q3 = ?, Q4 = ?, OT1 = ?, OT2 = ?, OT3 = ?, OT4 = ?, Total_Plays = ?, Total_Yards = ?, Passing_Yards = ?, Rushing_Yards = ?, Turnovers = ?, Time_Of_Possession = ?, Current_Period = ?, Timestamp = ? WHERE ID = ?";
		sqlite3_stmt *compiledStatement = nil;
		
        sqlite3_exec(db, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
		for (GameResult *currentGameResult in uArray)
		{
            //Execute SQL query
            if(sqlite3_prepare(db, query, -1, &compiledStatement, NULL) == SQLITE_OK)
            {
                sqlite3_bind_int(compiledStatement, 1, [currentGameResult final]);
                sqlite3_bind_int(compiledStatement, 2, [currentGameResult Q1]);
                sqlite3_bind_int(compiledStatement, 3, [currentGameResult Q2]);
                sqlite3_bind_int(compiledStatement, 4, [currentGameResult Q3]);
                sqlite3_bind_int(compiledStatement, 5, [currentGameResult Q4]);
                sqlite3_bind_int(compiledStatement, 6, [currentGameResult OT1]);
                sqlite3_bind_int(compiledStatement, 7, [currentGameResult OT2]);
                sqlite3_bind_int(compiledStatement, 8, [currentGameResult OT3]);
                sqlite3_bind_int(compiledStatement, 9, [currentGameResult OT4]);
                sqlite3_bind_int(compiledStatement, 10, [currentGameResult totalPlays]);
                sqlite3_bind_double(compiledStatement, 11, [currentGameResult totalYards]);
                sqlite3_bind_double(compiledStatement, 12, [currentGameResult passingYards]);
                sqlite3_bind_double(compiledStatement, 13, [currentGameResult rushingYards]);
                sqlite3_bind_int(compiledStatement, 14, [currentGameResult turnovers]);
                sqlite3_bind_int(compiledStatement, 15, [currentGameResult timeOfPossession]);
                sqlite3_bind_int(compiledStatement, 16, [currentGameResult currentPeriod]);
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                NSString *dateString = [dateFormatter stringFromDate:[currentGameResult timeStamp]];
                sqlite3_bind_text(compiledStatement, 17, [dateString UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_int(compiledStatement, 18, [currentGameResult ID]);
            }
			if (sqlite3_step(compiledStatement) != SQLITE_DONE) NSLog(@"DB not updated. Error: %s",sqlite3_errmsg(db));
			sqlite3_reset(compiledStatement);
        
		}
		if (sqlite3_finalize(compiledStatement) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(db));
        if (sqlite3_exec(db, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(db));
	//sqlite3_close(db);
    //}
    //else
	//{
	//	NSLog(@"sql-error: %s", sqlite3_errmsg(db));
	//}
}
@end
