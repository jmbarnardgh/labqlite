/**
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org>
 */

@import Foundation;
@import XCTest;

#import "LabQLiteTestSetupConstants.h"
#import "Garden.h"


@interface DatabaseControllerDataRetrievalTests : XCTestCase {
    LabQLiteTestSetupConstants *_constants;
}

@end

@implementation DatabaseControllerDataRetrievalTests

- (void)setUp {
    [super setUp];
    _constants = [[LabQLiteTestSetupConstants alloc] init];
    [_constants->_commonTestDatabase insertRows:_constants->_multiDataArray
                                      intoTable:@"garden"
                                          error:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    _constants = nil;
    [super tearDown];
}

- (void)test_A3_0_retrieveAllRowsFromATableShouldPassWithGoodDatabase {
    
    XCTAssertNotNil(_constants);
    XCTAssertNotNil(_constants->_commonTestDatabase);

    NSError *retrievalError;
    NSMutableArray *gardensArray = [_constants->_commonTestDatabase rowsFromTable:@"garden"
                                                        asSQLite3RowsWithSubclass:[Garden class]
                                                                     stipulations:nil
                                                                           offset:0
                                                       andMaxNumberOfRowsToReturn:20
                                                                        orderedBy:nil
                                                                            error:&retrievalError];

    NSInteger count = [gardensArray count];
    XCTAssertNotNil(gardensArray);
    NSLog(@"test_A3: count = %ld", (long)count);
    XCTAssertTrue(count > 0);
    XCTAssertTrue(count == 5);
}

- (void)test_A3_1_retrieveSingleRowAccordingToNameEquivalence {

    NSError *retrievalError;
    LabQLiteStipulation *stipulation = [LabQLiteStipulation stipulationWithAttribute:@"garden_name"
                                                                      binaryOperator:SQLite3BinaryOperatorEquals
                                                                               value:_constants->_minneapolisSculptureGarden.gardenName
                                                                            affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                            precedingLogicalOperator:nil
                                                                               error:nil];
    
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    NSMutableArray *gardensArray = [_constants->_commonTestDatabase rowsFromTable:@"garden"
                                                        asSQLite3RowsWithSubclass:[Garden class]
                                                                     stipulations:@[stipulation]
                                                                           offset:0
                                                       andMaxNumberOfRowsToReturn:5
                                                                        orderedBy:nil
                                                                            error:&retrievalError];
    
    NSInteger cardinality = [gardensArray count];
    XCTAssertTrue(cardinality == 1);
}

- (void)test_36_processBasicGetSomeRowsFromTableSELECTStatementShouldPass {
    
    XCTAssertNotNil(_constants);
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    NSError *retrievalError;
    NSMutableArray *gardensArray = [_constants->_commonTestDatabase rowsFromTable:@"garden"
                                                        asSQLite3RowsWithSubclass:[Garden class]
                                                                     stipulations:nil
                                                                           offset:0
                                                       andMaxNumberOfRowsToReturn:2
                                                                        orderedBy:nil
                                                                            error:&retrievalError];
    
    
    XCTAssertNotNil(gardensArray);
    XCTAssertTrue([gardensArray count] == 2);
}

- (void)test_37_processBasicGetNoRowsFromTableSELECTStatementShouldPass {
    
    XCTAssertNotNil(_constants);
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    NSError *retrievalError;
    NSMutableArray *gardensArray = [_constants->_commonTestDatabase rowsFromTable:@"garden"
                                                        asSQLite3RowsWithSubclass:[Garden class]
                                                                     stipulations:nil
                                                                           offset:0
                                                       andMaxNumberOfRowsToReturn:0
                                                                        orderedBy:nil
                                                                            error:&retrievalError];
    
    
    XCTAssertNotNil(gardensArray);
    XCTAssertTrue([gardensArray count] == 0);
}

- (void)test_38_processBasicGetSomeColumnsFromSomeRowsFromTableSELECTStatementShouldPass {
  
    XCTAssertNotNil(_constants);
    XCTAssertNotNil(_constants->_commonTestDatabase);
 
    NSError *retrievalError;
    NSMutableArray *gardensArray = [_constants->_commonTestDatabase rowsFromTable:@"garden"
                                                             withSpecifiedColumns:@[@"date_added", @"address"]
                                                                     stipulations:nil
                                                                           offset:0
                                                       andMaxNumberOfRowsToReturn:2
                                                                        orderedBy:@"address"
                                                                            error:&retrievalError];
    
    XCTAssertNotNil(gardensArray);
    
    XCTAssertTrue([gardensArray count] == 2);
    
    NSArray *g1 = gardensArray[0];
    NSArray *g2 = gardensArray[1];
    
    
    XCTAssertTrue([g1 isKindOfClass:[NSArray class]]);
    XCTAssertTrue([g1 isKindOfClass:[NSArray class]]);
    

    
    XCTAssertTrue([g1 count] == 2);
    XCTAssertTrue([g2 count] == 2);
    
    
    XCTAssertTrue([g1[0] isEqualToString:@"2015-11-11"]);
    XCTAssertTrue(g2[0] == [NSNull null]);
    
    XCTAssertTrue([g1[1] isEqualToString:@"Brentwood Bay, British Columbia, Canada"]);
    XCTAssertTrue([g2[1] isEqualToString:@"China"]);
}

- (void)test_39_processBasicGetAllRowsFromNonTableSELECTStatementShouldFail {
    
    XCTAssertNotNil(_constants);
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    NSError *retrievalError;
    NSMutableArray *gardensArray = [_constants->_commonTestDatabase rowsFromTable:@"aeorngaape"
                                                        asSQLite3RowsWithSubclass:[Garden class]
                                                                     stipulations:nil
                                                                           offset:0
                                                       andMaxNumberOfRowsToReturn:20
                                                                        orderedBy:nil
                                                                            error:&retrievalError];
    XCTAssertNotNil(retrievalError);
    XCTAssertNil(gardensArray);
}

- (void)test_40_processBasicGetSomeRowsFromNonTableSELECTStatementShouldFail {
    XCTAssertNotNil(_constants);
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    NSError *retrievalError;
    NSMutableArray *gardensArray = [_constants->_commonTestDatabase rowsFromTable:@"aeorngaape"
                                                        asSQLite3RowsWithSubclass:[Garden class]
                                                                     stipulations:nil
                                                                           offset:0
                                                       andMaxNumberOfRowsToReturn:2
                                                                        orderedBy:nil
                                                                            error:&retrievalError];
    XCTAssertNotNil(retrievalError);
    XCTAssertNil(gardensArray);
}

- (void)test_41_processBasicGetNoRowsFromNonTableSELECTStatementShouldFail {
    XCTAssertNotNil(_constants);
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    NSError *retrievalError;
    NSMutableArray *gardensArray = [_constants->_commonTestDatabase rowsFromTable:@"aeorngaape"
                                                        asSQLite3RowsWithSubclass:[Garden class]
                                                                     stipulations:nil
                                                                           offset:0
                                                       andMaxNumberOfRowsToReturn:0
                                                                        orderedBy:nil
                                                                            error:&retrievalError];
    XCTAssertNotNil(retrievalError);
    XCTAssertNil(gardensArray);
}

- (void)test_42_processBasicGetSomeColumnsFromSomeRowsFromNonTableSELECTStatementShouldFail {
    XCTAssertNotNil(_constants);
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    NSError *retrievalError;
    NSMutableArray *gardensArray = [_constants->_commonTestDatabase rowsFromTable:@"aeorngaape"
                                                             withSpecifiedColumns:@[@"date_added", @"address"]
                                                                     stipulations:nil
                                                                           offset:0
                                                       andMaxNumberOfRowsToReturn:2
                                                                        orderedBy:@"address"
                                                                            error:&retrievalError];
    XCTAssertNotNil(retrievalError);
    XCTAssertNil(gardensArray);
}


@end

