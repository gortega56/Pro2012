//
//  GameResultParser.m
//  NFL 2012 Pocket Schedule
//
//  Created by Gabriel Ortega on 8/7/12.
//
//

#import "GameResultParser.h"
#import "Common.h"

@implementation GameResultParser
@synthesize gameResultID, gameID, teamID, currentPeriod, final, Q1, Q2, Q3, Q4, OT1, OT2, OT3, OT4;
@synthesize totalPlays, totalYards, passingYards, rushingYards, turnovers, timeOfPossession, timeStamp;
@synthesize receivedData, parser, currentGame, currentGameResult, currentElementValue, resultsArray;
@synthesize delegate;

- (int)constructID
{
    return gameID*100 + teamID;
}

#pragma mark - XML test methods
- (void)parseLocalXML
{
    NSString *xmlPath = [[NSBundle mainBundle] pathForResource:@"NFL2012_Pro_Pocket_Schedule_Dev" ofType:@"xml"];
    NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
    [self parse:xmlData];
}

- (void)test:(GameResult *)result
{
    NSLog(@"ID: %d",[result ID]);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:[result timeStamp]];
    NSLog(@"%@",dateString);
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

#pragma mark - XML retrieval 
- (void)getXML
{
    if ([[Common sharedInstance] bDevMode])
	{
		NSLog(@"Parsing dev instance");
		[self parse:[NSData dataWithContentsOfURL:[NSURL URLWithString:kXMLURLDev]]];
	}
	else
	{
		NSLog(@"Parsing production instance");
		[self parse:[NSData dataWithContentsOfURL:[NSURL URLWithString:kXMLURL]]];

	}
    
	//NSLog(@"getXML");
	
	//NSString *URLString = kXMLURL;

	//self.receivedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:URLString]];

	//NSString *dataString = [[NSString alloc]initWithData:self.receivedData encoding:NSASCIIStringEncoding];
    //NSLog(@"%@",dataString);
    // Comment out for production
    
    //[self parse:self.receivedData];

    //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    //if (connection)
	//self.receivedData = [NSMutableData new];
    //else {
	//NSLog(@"Connection could not be established");
        // Delegate Method: Error handling in view controller
		//}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"didReceiveResponse");
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"didReceiveData");
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"connectionDidFinishLoading");
    // Debugging... 
    NSLog(@"Succeeded! Received %d bytes of data",[self.receivedData length]);
    NSString *dataString = [[NSString alloc]initWithData:self.receivedData encoding:NSASCIIStringEncoding];
    NSLog(@"%@",dataString);
    // Comment out for production
    
    [self parse:self.receivedData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed. Error: %@ %@",[error localizedDescription],[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    // Delegate Method: Error handling
}

#pragma mark - Parse XML
- (void)parse:(NSData *)data
{
	NSLog(@"parse");
    if (data) {
        self.parser = [[NSXMLParser alloc] initWithData:data];
        [self.parser setDelegate:self];
    
        BOOL success = [self.parser parse];
    
        if (success)
            NSLog(@"Parser wins");
        else
        {
            NSLog(@"Parser failed");
            // Delegate Method: Error handling
        }
    }
    else
        NSLog(@"No data to parse");
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	NSLog(@"parserDidStartDocument");
    
    self.resultsArray = nil;
    // Initialize any objects we need to store temp data
    self.resultsArray = [NSMutableArray new];
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	//NSLog(@"didStartElement");
    if ([elementName isEqualToString:@"home_team_score_detail"] ||
        [elementName isEqualToString:@"away_team_score_detail"]) {
        // Allocate a game object
        self.currentGame = [Game new];
        self.currentGameResult = [GameResult new];
    }
    
    //NSLog(@"Processing Element: %@", elementName);
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!self.currentElementValue)
        self.currentElementValue = [[NSMutableString alloc] initWithString:trimmedString];
    else
        [self.currentElementValue appendString:trimmedString];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    
    // Long if else statement...
    if ([elementName isEqualToString:@"game"]){
        // Take no action
        timeStamp = nil;
        currentElementValue = nil;
        gameID = 0;
        currentPeriod = 0;
        return;
        
    // Set our variables
    } else if ([elementName isEqualToString:@"game_ID"]) {
        [self setGameID:[currentElementValue intValue]];
        currentElementValue = nil;
        
        return;
    } else if ([elementName isEqualToString:@"timestamp"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        // We'll assign this time stamp to home/away results later
        [self setTimeStamp:[dateFormatter dateFromString:currentElementValue]];
        currentElementValue = nil;
    } else if ([elementName isEqualToString:@"home_team_ID"] ||
               [elementName isEqualToString:@"away_team_ID"]) {
        [self setTeamID:[currentElementValue intValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"current_period"]) {
        [self setCurrentPeriod:[currentElementValue intValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"final_score"]) {
        [currentGameResult setFinal:[currentElementValue intValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"Q1_score"]) {
        [currentGameResult setQ1:[currentElementValue intValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"Q2_score"]) {
        [currentGameResult setQ2:[currentElementValue intValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"Q3_score"]) {
        [currentGameResult setQ3:[currentElementValue intValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"Q4_score"]) {
        [currentGameResult setQ4:[currentElementValue intValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"OT1_score"]) {
        [currentGameResult setOT1:[currentElementValue intValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"OT2_score"]) {
        [currentGameResult setOT2:[currentElementValue intValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"OT3_score"]) {
        [currentGameResult setOT3:[currentElementValue intValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"OT4_score"]) {
        [currentGameResult setOT4:[currentElementValue intValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"total_plays"]) {
        [currentGameResult setTotalPlays:[currentElementValue intValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"total_yards"]) {
        [currentGameResult setTotalYards:[currentElementValue floatValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"passing_yards"]) {
        [currentGameResult setPassingYards:[currentElementValue floatValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"rushing_yards"]) {
        [currentGameResult setRushingYards:[currentElementValue floatValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"turnovers"]) {
        [currentGameResult setTurnovers:[currentElementValue intValue]];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"time_of_possession_seconds"]) {
        [currentGameResult setTimeOfPossession:[currentElementValue intValue]];
        currentElementValue = nil;
        return;
        
    // Add game result to array here
    } else if ([elementName isEqualToString:@"home_team_score_detail"] ||
               [elementName isEqualToString:@"away_team_score_detail"]) {
        // Get a GameResultID
        gameResultID = gameID*100 + teamID;
        [currentGameResult setID:gameResultID];
        
        // Assign current period
        [currentGameResult setCurrentPeriod:currentPeriod];
        
        // Assign time stamp
        [currentGameResult setTimeStamp:timeStamp];
        
        // Add to array
        [self.resultsArray addObject:currentGameResult];
        
        //[self test:currentGameResult];
        // Set Values to nil
        currentElementValue = nil;
        currentGameResult = nil;
        return;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    DBAccess *dbAccess = [DBAccess new];
    DBWriteAccess *dbWriteAccess = [DBWriteAccess new];
    NSMutableArray *updatedArray = [NSMutableArray new];
    
    NSArray *dbResults = [dbAccess getGameResults];
    [dbResults sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ID" ascending:YES]]];
    [resultsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ID" ascending:YES]]];
    
    NSDate *dbDate, *rDate;
    // Cycle through game results and update DB
    for (int i=0;i<[resultsArray count];i++) {
        dbDate = [[dbResults objectAtIndex:i] timeStamp];
        rDate = [[resultsArray objectAtIndex:i] timeStamp];
        
        if (![dbDate isEqualToDate:rDate]){
            [updatedArray addObject:[resultsArray objectAtIndex:i]];
        }
    }
    
    
    // Update DB
    if ([updatedArray count]>0) 
        [dbWriteAccess updateGameResult:updatedArray];
    /*
    NSMutableArray *rArray = [dbAccess getGameResults];
    for (GameResult *cResult in rArray) {
        [self test:cResult];
    }*/
    //GameResult *test = [dbAccess getGameResultsForID:102];
    //[self test:test];
    
    [delegate gameResultsDidUpdate];
}

@end
