//
//  RowTests.m
//  LabQLite
//
//  Created by Jacob Barnard on 3/26/16.
//
//

@import Foundation;
@import XCTest;

#import "LabQLiteTestSetupConstants.h"
#import "Garden.h"
#import "Plant.h"


@interface RowTests : XCTestCase {
    LabQLiteTestSetupConstants *_constants;
}

@end

@implementation RowTests

- (void)setUp {
    [super setUp];
    _constants = [[LabQLiteTestSetupConstants alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    NSError *deletionError = nil;
    [Garden deleteAll:&deletionError];
    NSArray *gardensRemaining = [Garden allObjects:nil];
    NSInteger numGardensRemaining = [gardensRemaining count];
    XCTAssertTrue(numGardensRemaining == 0);
    NSLog(@"Deletion of gardens after Row Test Executed - error: %@", deletionError);
    _constants = nil;
    [super tearDown];
}



#pragma Begin Tests

#pragma CREATE tests

- (void)test_01_test_CREATE_InsertSelfShouldPassWithGoodDatabaseAndCorrectTableNameAndGoodData {
    
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    Garden *goodDataGarden = [Garden new];
    goodDataGarden.gardenName = @"a_new_name";
    goodDataGarden.address = @"";
    goodDataGarden.dateAdded = @"17773144";
    
    NSError *insertionError = nil;
    BOOL insertionResult = [goodDataGarden insertSelf:&insertionError];
    
    NSLog(@"Insertion Error: %@", insertionError);
    NSLog(@"Insertion Result: %d", insertionResult);
    
    XCTAssertNil(insertionError);
    XCTAssertTrue(insertionResult);
}

- (void)test_02a_CREATE_testInsertSelfShouldFailWithNilForNonNullColumn {
    
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    Plant *badPlant = [Plant new];
    badPlant.commonName = nil;
    badPlant.commonType = @"Green Stuff";
    badPlant.iconImage = nil;
    
    NSError *insertionError = nil;
    BOOL insertionResult = [badPlant insertSelf:&insertionError];
    
    NSLog(@"Insertion Error: %@", insertionError);
    NSLog(@"Insertion Result: %d", insertionResult);
    
    XCTAssertNotNil(insertionError);
    XCTAssertFalse(insertionResult);
}

- (void)test_02b_CREATE_blockBasedTestInsertSelfShouldFailWithNilForNonNullColumn {
    
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    Plant *badPlant = [Plant new];
    badPlant.commonName = nil;
    badPlant.commonType = @"Green Stuff";
    badPlant.iconImage = nil;
    
    NSError __block *insertionError = nil;
    BOOL __block insertionResult = FALSE;
    [badPlant insertSelfWithCompletionBlock:^(BOOL success, NSError *error) {
        insertionError = error;
        insertionResult = success;
    }];
    
    NSLog(@"Insertion Error: %@", insertionError);
    NSLog(@"Insertion Result: %d", insertionResult);
    
    XCTAssertNotNil(insertionError);
    XCTAssertFalse(insertionResult);
}

- (void)test_03a_CREATE_insertMultipleHomogenousObjectsOfCorrespondingSubclassShouldSucceed {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    Garden *goodDataGarden1 = [Garden new];
    goodDataGarden1.gardenName = @"a_new_name1";
    goodDataGarden1.address = @"lorem ipsum stuff";
    goodDataGarden1.dateAdded = @"17773144";
    
    Garden *goodDataGarden2 = [Garden new];
    goodDataGarden2.gardenName = @"a_new_name2";
    goodDataGarden2.address = @"lorem ipsum stuff 2";
    goodDataGarden2.dateAdded = @"17773145";
    
    Garden *goodDataGarden3 = [Garden new];
    goodDataGarden3.gardenName = @"a_new_name3";
    goodDataGarden3.address = @"lorem ipsum stuff 3";
    goodDataGarden3.dateAdded = @"17773146";
    
    NSError *insertionError = nil;
    BOOL insertionResult = [Garden insertObjects:@[goodDataGarden1, goodDataGarden2, goodDataGarden3]
                                           error:&insertionError];
    
    NSLog(@"Insertion Error: %@", insertionError);
    NSLog(@"Insertion Result: %d", insertionResult);
    
    XCTAssertNil(insertionError);
    XCTAssertTrue(insertionResult);
}

- (void)test_03b_CREATE_blockBasedInsertMultipleHomogenousObjectsOfCorrespondingSubclassShouldSucceed {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    Garden *goodDataGarden1 = [Garden new];
    goodDataGarden1.gardenName = @"aetaeh";
    goodDataGarden1.address = @"lorem ipsum stuff";
    goodDataGarden1.dateAdded = @"17773144";
    
    Garden *goodDataGarden2 = [Garden new];
    goodDataGarden2.gardenName = @"thteaathte";
    goodDataGarden2.address = @"lorem ipsum stuff 2";
    goodDataGarden2.dateAdded = @"17773145";
    
    Garden *goodDataGarden3 = [Garden new];
    goodDataGarden3.gardenName = @"zztiiigd";
    goodDataGarden3.address = @"lorem ipsum stuff 3";
    goodDataGarden3.dateAdded = @"17773146";
    
    NSError __block *insertionError = nil;
    BOOL __block insertionResult = FALSE;
    [Garden insertObjects:@[goodDataGarden1, goodDataGarden2, goodDataGarden3]
          completionBlock:^(BOOL success, NSError *error) {
              insertionResult = success;
              insertionError = error;
          }
    ];
    
    NSLog(@"Insertion Error: %@", insertionError);
    NSLog(@"Insertion Result: %d", insertionResult);
    
    XCTAssertNil(insertionError);
    XCTAssertTrue(insertionResult);
}

- (void)test_04a_CREATE_insertHeterogenousObjectsByRowSubclassShouldFail {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    Garden *goodDataGarden1 = [Garden new];
    goodDataGarden1.gardenName = @"a_new_name1";
    goodDataGarden1.address = @"lorem ipsum stuff";
    goodDataGarden1.dateAdded = @"17773144";
    
    Garden *goodDataGarden2 = [Garden new];
    goodDataGarden2.gardenName = @"a_new_name2";
    goodDataGarden2.address = @"lorem ipsum stuff 2";
    goodDataGarden2.dateAdded = @"17773145";
    
    Plant *goodPlant = [Plant new];
    goodPlant.commonName = @"Green Thing";
    goodPlant.commonType = @"Green Stuff";
    goodPlant.iconImage = nil;
    
    NSError *insertionError = nil;
    BOOL insertionResult = [Garden insertObjects:@[goodDataGarden1, goodDataGarden2, goodPlant]
                                           error:&insertionError];
    NSString *errorMessage = [[insertionError userInfo] valueForKey:@"errorMessage"];
    
    NSLog(@"Insertion Error: %@", insertionError);
    NSLog(@"Insertion Result: %d", insertionResult);
    
    XCTAssertNotNil(insertionError);
    XCTAssertFalse(insertionResult);
    XCTAssertTrue([errorMessage compare:LabQLiteRowErrorMessageObjectsInCollectionNotAllSameClass] == NSOrderedSame);
}

- (void)test_04b_CREATE_blockBasedInsertHeterogenousObjectsByRowSubclassShouldFail {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    Garden *goodDataGarden1 = [Garden new];
    goodDataGarden1.gardenName = @"a_new_name1a";
    goodDataGarden1.address = @"lorem ipsum stuff";
    goodDataGarden1.dateAdded = @"17773144";
    
    Garden *goodDataGarden2 = [Garden new];
    goodDataGarden2.gardenName = @"a_new_name2a";
    goodDataGarden2.address = @"lorem ipsum stuff 2";
    goodDataGarden2.dateAdded = @"17773145";
    
    Plant *goodPlant = [Plant new];
    goodPlant.commonName = @"Green Thinga";
    goodPlant.commonType = @"Green Stuff";
    goodPlant.iconImage = nil;
    
    NSError __block *insertionError = nil;
    BOOL __block insertionResult = FALSE;
    [Garden insertObjects:@[goodDataGarden1, goodDataGarden2, goodPlant]
          completionBlock:^(BOOL success, NSError *error) {
              insertionResult = success;
              insertionError = error;
          }
     ];
    
    NSString *errorMessage = [[insertionError userInfo] valueForKey:@"errorMessage"];
    
    NSLog(@"Insertion Error: %@", insertionError);
    NSLog(@"Insertion Result: %d", insertionResult);
    
    XCTAssertNotNil(insertionError);
    XCTAssertFalse(insertionResult);
    XCTAssertTrue([errorMessage compare:LabQLiteRowErrorMessageObjectsInCollectionNotAllSameClass] == NSOrderedSame);
}

- (void)test_05_CREATE_insertMultipleHomogenousObjectsOfNonCorrespondingSubclassShouldFail {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    Garden *goodDataGarden1 = [Garden new];
    goodDataGarden1.gardenName = @"a_new_name1";
    goodDataGarden1.address = @"lorem ipsum stuff";
    goodDataGarden1.dateAdded = @"17773144";
    
    Garden *goodDataGarden2 = [Garden new];
    goodDataGarden2.gardenName = @"a_new_name2";
    goodDataGarden2.address = @"lorem ipsum stuff 2";
    goodDataGarden2.dateAdded = @"17773145";

    Garden *goodDataGarden3 = [Garden new];
    goodDataGarden3.gardenName = @"a_new_name3";
    goodDataGarden3.address = @"lorem ipsum stuff 3";
    goodDataGarden3.dateAdded = @"17773146";
    
    NSError *insertionError = nil;
    BOOL insertionResult = [Plant insertObjects:@[goodDataGarden1, goodDataGarden2, goodDataGarden3]
                                           error:&insertionError];
    NSString *errorMessage = [[insertionError userInfo] valueForKey:@"errorMessage"];
    
    NSLog(@"Insertion Error: %@", insertionError);
    NSLog(@"Insertion Result: %d", insertionResult);
    
    XCTAssertNotNil(insertionError);
    XCTAssertFalse(insertionResult);
    XCTAssertTrue([errorMessage compare:LabQLiteRowErrorMessageObjectsInCollectionNotAllSameClass] == NSOrderedSame);
}



#pragma RETRIEVE tests

- (void)test_06_RETRIEVE_retrieveIndividualRowByValidPrimaryKeyShouldSucceed {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    
    NSError *retrievalError = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:@"garden_name"
                                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                                     value:@"Butchart Gardens"
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil
                                                                     error:nil];
    
    NSArray *retrievalResults = [Garden objectsAtOffset:0
                                                  limit:1
                                               orderdBy:nil
                                       withStipulations:@[s]
                                                  error:&retrievalError];
    
    NSString *errorMessage = [[retrievalError userInfo] valueForKey:@"errorMessage"];
    NSInteger resultsCount = [retrievalResults count];
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertTrue(resultsCount == 1);
    XCTAssertNil(insertionError);
    XCTAssertNil(retrievalError);
    XCTAssertNil(errorMessage);
    XCTAssertNotNil(retrievalResults);
}

- (void)test_06a_RETRIEVE_blockBasedRetrieveIndividualRowByValidPrimaryKeyShouldSucceed {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    
    NSError __block *retrievalError = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:@"garden_name"
                                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                                     value:@"Butchart Gardens"
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil
                                                                     error:nil];
    
    NSArray __block *retrievalResults;
    
    [Garden objectsAtOffset:0
            numberOfObjects:1
             sortedByColumn:nil
           withStipulations:@[s]
            completionBlock:^(NSArray *results, NSError *error) {
                retrievalResults = results;
                retrievalError = error;
            }
     ];
    
    NSString *errorMessage = [[retrievalError userInfo] valueForKey:@"errorMessage"];
    NSInteger resultsCount = [retrievalResults count];
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertTrue(resultsCount == 1);
    XCTAssertNil(insertionError);
    XCTAssertNil(retrievalError);
    XCTAssertNil(errorMessage);
    XCTAssertNotNil(retrievalResults);
}

- (void)test_07_RETRIEVE_retrieveIndividualRowByInvalidColumnShouldPassWithEmptyArrayResults {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    NSError *retrievalError = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:@"treasury"
                                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                                     value:@"Butchart Gardens"
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil error:nil];
    
    NSArray *retrievalResults = [Garden objectsAtOffset:0
                                                  limit:1
                                               orderdBy:nil
                                       withStipulations:@[s]
                                                  error:&retrievalError];
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertNotNil(retrievalError);
    XCTAssertNil(retrievalResults);
    XCTAssertTrue([retrievalResults count] == 0);
}

- (void)test_08a_RETRIEVE_retrieveAllRowsShouldPass {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_yuyuanGarden
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_topiaryGardens
                                                               error:&insertionError];
    
    NSError *retrievalError = nil;
    
    NSArray *retrievalResults = [Garden allObjects:&retrievalError];
    
    for (Garden *e in retrievalResults) {
        NSLog(@"Garden: %@", e.gardenName);
    }
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertNil(retrievalError);
    XCTAssertNotNil(retrievalResults);
    XCTAssertTrue([retrievalResults count] == 3);
}

- (void)test_08b_RETRIEVE_blockBasedRetrieveAllRowsShouldPass {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_yuyuanGarden
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_topiaryGardens
                                                               error:&insertionError];
    
    NSError __block *retrievalError = nil;
    NSArray __block *retrievalResults = nil;
    [Garden allObjectsWithCompletionBlock:^(NSArray *results, NSError *error) {
        retrievalResults = results;
        retrievalError = error;
        }
    ];
    
    for (Garden *e in retrievalResults) {
        NSLog(@"Garden: %@", e.gardenName);
    }
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertNil(retrievalError);
    XCTAssertNotNil(retrievalResults);
    XCTAssertTrue([retrievalResults count] == 3);
}

- (void)test_08c_RETRIEVE_blockBasedRetrieveAllRowsWithValidSortingShouldPass {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_yuyuanGarden
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_topiaryGardens
                                                               error:&insertionError];
    
    NSError __block *retrievalError = nil;
    NSArray __block *retrievalResults = nil;
    
    [Garden objectsAtOffset:0
            numberOfObjects:3
             sortedByColumn:@"garden_name"
           withStipulations:nil
            completionBlock:^(NSArray *results, NSError *error) {
                retrievalResults = results;
                retrievalError = error;
            }
     ];
    
    NSInteger count = [retrievalResults count];
    
    XCTAssertTrue(count == 3);
    
    NSMutableArray *gardenNames = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0; i < 3; i++) {
        Garden *g = (Garden *)[retrievalResults objectAtIndex:i];
        [gardenNames addObject:g.gardenName];
    }
    
    XCTAssertTrue([gardenNames[0] compare:@"Butchart Gardens"] == NSOrderedSame);
    XCTAssertTrue([gardenNames[1] compare:@"Levens Hall and Gardens"] == NSOrderedSame);
    XCTAssertTrue([gardenNames[2] compare:@"Yuyuan Garden"] == NSOrderedSame);
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertNil(retrievalError);
    XCTAssertNotNil(retrievalResults);
    XCTAssertTrue([retrievalResults count] == 3);
}

- (void)test_09a_RETRIEVE_retrieveSomeRowsWithValidSortingShouldPass {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_yuyuanGarden
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_topiaryGardens
                                                               error:&insertionError];
    
    NSError __block *retrievalError = nil;
    NSArray __block *retrievalResults = nil;
    
    [Garden objectsAtOffset:0
            numberOfObjects:3
             sortedByColumn:@"garden_name"
           withStipulations:nil
             completionBlock:^(NSArray *results, NSError *error) {
                 retrievalResults = results;
                 retrievalError = error;
             }
    ];
     
    NSInteger count = [retrievalResults count];
    
    XCTAssertTrue(count == 2);
    
    NSMutableArray *gardenNames = [[NSMutableArray alloc] initWithCapacity:2];
    for (int i = 0; i < 2; i++) {
        Garden *g = (Garden *)[retrievalResults objectAtIndex:i];
        [gardenNames addObject:g.gardenName];
    }
    
    XCTAssertTrue([gardenNames[0] compare:@"Levens Hall and Gardens"] == NSOrderedSame);
    XCTAssertTrue([gardenNames[1] compare:@"Yuyuan Garden"] == NSOrderedSame);
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertNil(retrievalError);
    XCTAssertNotNil(retrievalResults);
}

- (void)test_09b_RETRIEVE_retrieveSomeRowsWithInvalidSortingShouldFail {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_yuyuanGarden
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_topiaryGardens
                                                               error:&insertionError];
    
    NSError __block *retrievalError = nil;
    NSArray __block *retrievalResults = nil;
    
    [Garden objectsAtOffset:0
            numberOfObjects:3
             sortedByColumn:@"1up"
           withStipulations:nil
            completionBlock:^(NSArray *results, NSError *error) {
                retrievalResults = results;
                retrievalError = error;
            }
     ];
    
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertNil(retrievalResults);
    XCTAssertNotNil(retrievalError);
}


- (void)test_10a_RETRIEVE_convenienceMethodRetrieveAllRowsWithValidSortingShouldPass {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_yuyuanGarden
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_topiaryGardens
                                                               error:&insertionError];
    
    NSError *retrievalError = nil;
    NSArray *retrievalResults = nil;
    
    retrievalResults = [Garden allObjectsSortedBy:@"gardenName" error:&retrievalError];
    
    NSInteger count = [retrievalResults count];
    
    XCTAssertTrue(count == 3);
    
    NSMutableArray *gardenNames = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0; i < 3; i++) {
        Garden *g = (Garden *)[retrievalResults objectAtIndex:i];
        [gardenNames addObject:g.gardenName];
    }
    
    XCTAssertTrue([gardenNames[0] compare:@"Butchart Gardens"] == NSOrderedSame);
    XCTAssertTrue([gardenNames[1] compare:@"Levens Hall and Gardens"] == NSOrderedSame);
    XCTAssertTrue([gardenNames[2] compare:@"Yuyuan Garden"] == NSOrderedSame);
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertNil(retrievalError);
    XCTAssertNotNil(retrievalResults);
}

- (void)test_10b_RETRIEVE_convenienceMethodRetrieveAllRowsWithInvalidSortingShouldFail {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_yuyuanGarden
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_topiaryGardens
                                                               error:&insertionError];
    
    NSError *retrievalError = nil;
    NSArray *retrievalResults = nil;
    
    retrievalResults = [Garden allObjectsSortedBy:@"1up" error:&retrievalError]; //invalid sort criteria
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertNil(retrievalResults);
    XCTAssertNotNil(retrievalError);
}



#pragma UPDATE tests

- (void)test_11a_UPDATE_saveSelfWithNoChangeShouldPass {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    
    NSError *retrievalError = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:@"garden_name"
                                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                                     value:@"Butchart Gardens"
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil error:nil];
    
    NSArray *retrievalResults = [Garden objectsAtOffset:0
                                                  limit:1
                                               orderdBy:nil
                                       withStipulations:@[s]
                                                  error:&retrievalError];
    
    NSString *errorMessage = [[retrievalError userInfo] valueForKey:@"errorMessage"];
    NSInteger resultsCount = [retrievalResults count];
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertTrue(resultsCount == 1);
    XCTAssertNil(insertionError);
    XCTAssertNil(retrievalError);
    XCTAssertNil(errorMessage);
    XCTAssertNotNil(retrievalResults);
    
    Garden *g = (Garden *)retrievalResults[0];
    
    NSError *updateError = nil;
    g.gardenName = @"New garden name";
    [g save:&updateError];
    
    NSLog(@"Update Error: %@", updateError);

    XCTAssertNil(updateError);
    XCTAssertNil(errorMessage);
}

- (void)test_11b_UPDATE_saveSelfWithValidSinglePropertyChangeShouldPass {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    
    NSString *oldDateAdded = @"2015-11-11";
    
    NSError *retrievalError = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:@"garden_name"
                                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                                     value:@"Butchart Gardens"
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil error:nil];
    
    NSArray *retrievalResults = [Garden objectsAtOffset:0
                                                  limit:1
                                               orderdBy:nil
                                       withStipulations:@[s]
                                                  error:&retrievalError];

    Garden *g = (Garden *)retrievalResults[0];

    XCTAssertTrue([oldDateAdded compare:g.dateAdded] == NSOrderedSame);
    
    NSString *errorMessage = [[retrievalError userInfo] valueForKey:@"errorMessage"];
    NSInteger resultsCount = [retrievalResults count];
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertTrue(resultsCount == 1);
    XCTAssertNil(insertionError);
    XCTAssertNil(retrievalError);
    XCTAssertNil(errorMessage);
    XCTAssertNotNil(retrievalResults);
    
    
    NSString *newDateAdded = @"2019-05-09";
    g.dateAdded = newDateAdded;
    NSError *updateError = nil;
    [g save:&updateError];
    
    NSArray *updatedArray = [Garden objectsAtOffset:0
                                              limit:1
                                           orderdBy:nil
                                   withStipulations:@[s]
                                              error:&retrievalError];
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    NSInteger countOfUpdatedArray = [updatedArray count];
    int c = (int)countOfUpdatedArray;
    XCTAssertTrue(c == 1);
    
    NSLog(@"Count of results from updated query: %d", c);
    
    
    Garden *updatedGarden = (Garden *)[updatedArray firstObject];
    
    XCTAssertTrue([updatedGarden.gardenName compare:@"Butchart Gardens"] == NSOrderedSame);
    XCTAssertTrue([updatedGarden.dateAdded compare:newDateAdded] == NSOrderedSame);
    XCTAssertTrue([updatedGarden.dateAdded compare:oldDateAdded] != NSOrderedSame);
    XCTAssertTrue([oldDateAdded compare:newDateAdded] != NSOrderedSame);
    
    XCTAssertNil(updateError);
    XCTAssertNil(errorMessage);
}

- (void)test_11c_UPDATE_blockBasedSaveSelfWithNoChangeShouldPass {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    
    NSError *retrievalError = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:@"garden_name"
                                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                                     value:@"Butchart Gardens"
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil error:nil];
    
    NSArray *retrievalResults = [Garden objectsAtOffset:0
                                                  limit:1
                                               orderdBy:nil
                                       withStipulations:@[s]
                                                  error:&retrievalError];
    
    NSString *errorMessage = [[retrievalError userInfo] valueForKey:@"errorMessage"];
    NSInteger resultsCount = [retrievalResults count];
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertTrue(resultsCount == 1);
    XCTAssertNil(insertionError);
    XCTAssertNil(retrievalError);
    XCTAssertNil(errorMessage);
    XCTAssertNotNil(retrievalResults);
    
    Garden *g = (Garden *)retrievalResults[0];
    
    g.gardenName = @"New garden name";
    BOOL __block saved = NO;
    NSError __block *updateError;
    
    [g saveWithCompletionBlock:^(BOOL didSaveSuccessfully, NSError *error) {
            saved = didSaveSuccessfully;
            updateError = error;
        }
     ];
    
    NSLog(@"Update Error: %@", updateError);
    
    XCTAssertNil(updateError);
    XCTAssertNil(errorMessage);
}

- (void)test_11d_UPDATE_blockBasedSaveSelfWithValidSinglePropertyChangeShouldPass {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    
    NSString *oldDateAdded = @"2015-11-11";
    
    NSError *retrievalError = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:@"garden_name"
                                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                                     value:@"Butchart Gardens"
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil error:nil];
    
    NSArray *retrievalResults = [Garden objectsAtOffset:0
                                                  limit:1
                                               orderdBy:nil
                                       withStipulations:@[s]
                                                  error:&retrievalError];
    
    Garden *g = (Garden *)retrievalResults[0];
    
    XCTAssertTrue([oldDateAdded compare:g.dateAdded] == NSOrderedSame);
    
    NSString *errorMessage = [[retrievalError userInfo] valueForKey:@"errorMessage"];
    NSInteger resultsCount = [retrievalResults count];
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertTrue(resultsCount == 1);
    XCTAssertNil(insertionError);
    XCTAssertNil(retrievalError);
    XCTAssertNil(errorMessage);
    XCTAssertNotNil(retrievalResults);
    
    
    NSString *newDateAdded = @"2019-05-09";
    g.dateAdded = newDateAdded;
    BOOL __block saved = NO;
    NSError __block *updateError;
    
    [g saveWithCompletionBlock:^(BOOL didSaveSuccessfully, NSError *error) {
            saved = didSaveSuccessfully;
            updateError = error;
        }
     ];
    
    NSArray *updatedArray = [Garden objectsAtOffset:0
                                              limit:1
                                           orderdBy:nil
                                   withStipulations:@[s]
                                              error:&retrievalError];
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    NSInteger countOfUpdatedArray = [updatedArray count];
    int c = (int)countOfUpdatedArray;
    XCTAssertTrue(c == 1);
    
    NSLog(@"Count of results from updated query: %d", c);
    
    
    Garden *updatedGarden = (Garden *)[updatedArray firstObject];
    
    XCTAssertTrue([updatedGarden.gardenName compare:@"Butchart Gardens"] == NSOrderedSame);
    XCTAssertTrue([updatedGarden.dateAdded compare:newDateAdded] == NSOrderedSame);
    XCTAssertTrue([updatedGarden.dateAdded compare:oldDateAdded] != NSOrderedSame);
    XCTAssertTrue([oldDateAdded compare:newDateAdded] != NSOrderedSame);
    
    XCTAssertNil(updateError);
    XCTAssertNil(errorMessage);
}

#pragma DESTROY tests

- (void)test_12a_DELETE_deleteRowFromDatabaseCorrespondingToProvidedObjectShouldSucceed {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    
    NSError *retrievalError = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:@"garden_name"
                                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                                     value:@"Butchart Gardens"
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil error:nil];
    
    NSArray *retrievalResults = [Garden objectsAtOffset:0
                                                  limit:1
                                               orderdBy:nil
                                       withStipulations:@[s]
                                                  error:&retrievalError];
    
    Garden *g = (Garden *)retrievalResults[0];
    
    NSString *errorMessage = [[retrievalError userInfo] valueForKey:@"errorMessage"];
    NSInteger resultsCount = [retrievalResults count];
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertTrue(resultsCount == 1);
    XCTAssertNil(insertionError);
    XCTAssertNil(retrievalError);
    XCTAssertNil(errorMessage);
    XCTAssertNotNil(retrievalResults);

    NSError *deletionError = nil;
    BOOL deleted = [g deleteCorrespondingRow:&deletionError];
    
    NSArray *newRetrievalResults = [Garden objectsAtOffset:0
                                                     limit:1
                                                  orderdBy:nil
                                          withStipulations:@[s]
                                                     error:&retrievalError];
    
    NSInteger newCountOfRetrievalResults = [newRetrievalResults count];
    XCTAssertTrue(newCountOfRetrievalResults == 0);
    XCTAssertTrue(deleted);
}

- (void)test_12b_DELETE_blockBasedDeleteRowFromDatabaseCorrespondingToProvidedObjectShouldSucceed {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    
    NSError *retrievalError = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:@"garden_name"
                                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                                     value:@"Butchart Gardens"
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil error:nil];
    
    NSArray *retrievalResults = [Garden objectsAtOffset:0
                                                  limit:1
                                               orderdBy:nil
                                       withStipulations:@[s]
                                                  error:&retrievalError];
    
    Garden *g = (Garden *)retrievalResults[0];
    
    NSString *errorMessage = [[retrievalError userInfo] valueForKey:@"errorMessage"];
    NSInteger resultsCount = [retrievalResults count];
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertTrue(resultsCount == 1);
    XCTAssertNil(insertionError);
    XCTAssertNil(retrievalError);
    XCTAssertNil(errorMessage);
    XCTAssertNotNil(retrievalResults);
    
    NSError __block *deletionError = nil;
    BOOL __block deleted = NO;
    [g deleteCorrespondingRowWithCompletionBlock:^(BOOL didDeleleteCorrespondingRowSuccessfully, NSError *error) {
            deletionError = error;
            deleted = didDeleleteCorrespondingRowSuccessfully;
        }
    ];
    
    NSArray *newRetrievalResults = [Garden objectsAtOffset:0
                                                     limit:1
                                                  orderdBy:nil
                                          withStipulations:@[s]
                                                     error:&retrievalError];
    
    NSInteger newCountOfRetrievalResults = [newRetrievalResults count];
    XCTAssertTrue(newCountOfRetrievalResults == 0);
    XCTAssertTrue(deleted);
}

- (void)test_13a_DELETE_deleteAllRowsFromDatabaseCorrespondingToProvidedClassShouldSucceed {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);

    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_yuyuanGarden
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_topiaryGardens
                                                               error:&insertionError];

    NSError *retrievalError = nil;

    NSArray *retrievalResults = [Garden allObjects:&retrievalError];

    for (Garden *e in retrievalResults) {
        NSLog(@"Garden: %@", e.gardenName);
    }

    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);

    XCTAssertNil(retrievalError);
    XCTAssertNotNil(retrievalResults);
    XCTAssertTrue([retrievalResults count] == 3);
    
    NSError *deleteAllError = nil;
    [Garden deleteAll:&deleteAllError];
    
    NSError *newRetrievalError = nil;
    NSArray *newRetrievalResults = [Garden allObjects:&newRetrievalError];
    
    XCTAssertNil(newRetrievalError);
    XCTAssertNotNil(newRetrievalResults);
    XCTAssertTrue([newRetrievalResults count] == 0);
}

- (void)test_13b_DELETE_blockBasedDeleteAllRowsFromDatabaseCorrespondingToProvidedClassShouldSucceed {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_yuyuanGarden
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_topiaryGardens
                                                               error:&insertionError];
    
    NSError *retrievalError = nil;
    
    NSArray *retrievalResults = [Garden allObjects:&retrievalError];
    
    for (Garden *e in retrievalResults) {
        NSLog(@"Garden: %@", e.gardenName);
    }
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertNil(retrievalError);
    XCTAssertNotNil(retrievalResults);
    XCTAssertTrue([retrievalResults count] == 3);
    
    NSError __block *deleteAllError = nil;
    BOOL __block deleted = NO;
    [Garden deleteAllWithCompletionBlock:^(BOOL didDeleleteCorrespondingRowSuccessfully, NSError *error) {
            deleteAllError = error;
            deleted = didDeleleteCorrespondingRowSuccessfully;
        }
    ];
    
    NSError *newRetrievalError = nil;
    NSArray *newRetrievalResults = [Garden allObjects:&newRetrievalError];
    
    XCTAssertNil(newRetrievalError);
    XCTAssertNotNil(newRetrievalResults);
    XCTAssertTrue([newRetrievalResults count] == 0);
}

- (void)test_14a_DELETE_deleteRowsFromDatabaseCorrespondingToProvidedObjectWithGoodStipulationsShouldSucceed {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_yuyuanGarden
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_topiaryGardens
                                                               error:&insertionError];
    
    NSError *retrievalError = nil;
    
    NSArray *retrievalResults = [Garden allObjects:&retrievalError];
    
    for (Garden *e in retrievalResults) {
        NSLog(@"Garden: %@", e.gardenName);
    }
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertNil(retrievalError);
    XCTAssertNotNil(retrievalResults);
    XCTAssertTrue([retrievalResults count] == 3);
    
    NSError *deleteError = nil;
    BOOL deleted = NO;
    
    LabQLiteStipulation *butchartStipulation = [LabQLiteStipulation stipulationWithAttribute:@"garden_name"
                                                                              binaryOperator:SQLite3BinaryOperatorEquals
                                                                                       value:[_constants->_butchartGardens gardenName]
                                                                                    affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                                    precedingLogicalOperator:nil error:nil];
    LabQLiteStipulation *yuyuanStipulation = [LabQLiteStipulation stipulationWithAttribute:@"garden_name"
                                                                              binaryOperator:SQLite3BinaryOperatorEquals
                                                                                       value:[_constants->_yuyuanGarden gardenName]
                                                                                    affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                                    precedingLogicalOperator:SQLite3LogicalOperatorOR error:nil];
    
    deleted = [Garden deleteWithStipulations:@[butchartStipulation, yuyuanStipulation]
                                       error:&deleteError];
    
    NSError *newRetrievalError = nil;
    NSArray *newRetrievalResults = [Garden allObjects:&newRetrievalError];
    
    NSLog(@"New Retrieval Error: %@", newRetrievalError);
    NSLog(@"New Retrieval Result: %@", newRetrievalResults);
    
    XCTAssertTrue(deleted);
    XCTAssertNil(newRetrievalError);
    XCTAssertNotNil(newRetrievalResults);
    XCTAssertTrue([newRetrievalResults count] == 1);
}

- (void)test_14b_DELETE_blockBasedDeleteRowsFromDatabaseCorrespondingToProvidedObjectWithGoodStipulationsShouldSucceed {
    XCTAssertNotNil([LabQLiteDatabaseController sharedDatabaseController]);
    
    NSError *insertionError = nil;
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_butchartGardens
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_yuyuanGarden
                                                               error:&insertionError];
    [[LabQLiteDatabaseController sharedDatabaseController] insertRow:_constants->_topiaryGardens
                                                               error:&insertionError];
    
    NSError *retrievalError = nil;
    
    NSArray *retrievalResults = [Garden allObjects:&retrievalError];
    
    for (Garden *e in retrievalResults) {
        NSLog(@"Garden: %@", e.gardenName);
    }
    
    NSLog(@"Retrieval Error: %@", retrievalError);
    NSLog(@"Retrieval Result: %@", retrievalResults);
    
    XCTAssertNil(retrievalError);
    XCTAssertNotNil(retrievalResults);
    XCTAssertTrue([retrievalResults count] == 3);
    
    NSError __block *deleteError = nil;
    BOOL __block deleted = NO;
    
    LabQLiteStipulation *butchartStipulation = [LabQLiteStipulation stipulationWithAttribute:@"garden_name"
                                                                              binaryOperator:SQLite3BinaryOperatorEquals
                                                                                       value:[_constants->_butchartGardens gardenName]
                                                                                    affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                                    precedingLogicalOperator:nil error:nil];
    LabQLiteStipulation *yuyuanStipulation = [LabQLiteStipulation stipulationWithAttribute:@"garden_name"
                                                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                                                     value:[_constants->_yuyuanGarden gardenName]
                                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                                  precedingLogicalOperator:SQLite3LogicalOperatorOR error:nil];
    
    [Garden deleteWithStipulations:@[butchartStipulation, yuyuanStipulation]
                   completionBlock:^(BOOL didDeleleteCorrespondingRowSuccessfully, NSError *error) {
            deleteError = error;
            deleted = didDeleleteCorrespondingRowSuccessfully;
        }
    ];
    
    NSError *newRetrievalError = nil;
    NSArray *newRetrievalResults = [Garden allObjects:&newRetrievalError];
    
    NSLog(@"New Retrieval Error: %@", newRetrievalError);
    NSLog(@"New Retrieval Result: %@", newRetrievalResults);
    
    XCTAssertTrue(deleted);
    XCTAssertNil(newRetrievalError);
    XCTAssertNotNil(newRetrievalResults);
    XCTAssertTrue([newRetrievalResults count] == 1);
}

@end


