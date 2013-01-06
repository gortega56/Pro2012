//
//  GameResultParser.h
//  NFL 2012 Pocket Schedule
//
//  Created by Gabriel Ortega on 8/7/12.
//
//

#import <Foundation/Foundation.h>
#import "DBAccess.h"
#import "DBWriteAccess.h"
#import "GameResult.h"

@protocol GameResultDelegate
@required

- (void)gameResultsDidUpdate;

@end


@interface GameResultParser : NSObject <NSURLConnectionDataDelegate, NSXMLParserDelegate>


@property int gameResultID;
@property int gameID;
@property int teamID;
@property int currentPeriod;
@property int final;
@property int Q1;
@property int Q2;
@property int Q3;
@property int Q4;
@property int OT1;
@property int OT2;
@property int OT3;
@property int OT4;
@property int totalPlays;
@property float totalYards;
@property float passingYards;
@property float rushingYards;
@property int turnovers;
@property int timeOfPossession;
@property (nonatomic, strong) NSDate *timeStamp;
@property (nonatomic, strong) Game *currentGame;
@property (nonatomic, strong) GameResult *currentGameResult;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) NSMutableString *currentElementValue;
@property (nonatomic, strong) NSMutableArray *resultsArray;
@property (nonatomic, unsafe_unretained) id <GameResultDelegate> delegate;

- (void)getXML;
- (void)parse:(NSData *)data;
- (void)parseLocalXML;

@end
