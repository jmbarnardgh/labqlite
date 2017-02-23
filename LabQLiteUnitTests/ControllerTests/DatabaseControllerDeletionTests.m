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

#import "Garden.h"
#import "LabQLiteTestSetupConstants.h"

@interface DatabaseControllerDeletionTests : XCTestCase{
    LabQLiteTestSetupConstants *_constants;
}


@end

@implementation DatabaseControllerDeletionTests

- (void)setUp {
    [super setUp];
    _constants = [[LabQLiteTestSetupConstants alloc] init];
    [_constants->_commonTestDatabase insertRows:_constants->_multiDataArray
                                      intoTable:@"garden"
                                          error:nil];
}

- (void)tearDown {
    _constants = nil;
    [super tearDown];
}


- (void)test_A6_1_processBasicDeleteAllRowsInTableShouldPassWithGoodTableName {
    
    NSError *deleteError;
    NSError *retrievalError;
    
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    NSArray *gardenRows = [controller rowsFromTable:@"garden"
                               withSpecifiedColumns:nil
                                       stipulations:nil
                                             offset:0
                         andMaxNumberOfRowsToReturn:20
                                          orderedBy:nil
                                              error:&retrievalError];
    
    XCTAssertNotNil(gardenRows);
    XCTAssertTrue([gardenRows count] == 5);
    XCTAssertNil(retrievalError);
    
    

    id success = [controller processStatement:@"DELETE FROM garden"
                               bindableValues:nil
                                affinityTypes:nil
                                  insulatedly:YES
                                        error:&deleteError];
    
    XCTAssertNotNil(success);
    XCTAssertNil(deleteError);
    
    gardenRows = [controller rowsFromTable:@"garden"
                      withSpecifiedColumns:nil
                              stipulations:nil
                                    offset:0
                andMaxNumberOfRowsToReturn:20
                                 orderedBy:nil
                                     error:&retrievalError];
    
    XCTAssertNotNil(gardenRows);
    XCTAssertTrue([gardenRows count] == 0);
    XCTAssertNil(retrievalError);
}

- (void)test_A6_2_processBasicDeleteSomeRowsInTableShouldPassWithGoodTableName {
    
    NSError *deleteError;
    NSError *retrievalError;
    
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    NSArray *gardenRows = [controller rowsFromTable:@"garden"
                               withSpecifiedColumns:nil
                                       stipulations:nil
                                             offset:0
                         andMaxNumberOfRowsToReturn:20
                                          orderedBy:nil
                                              error:&retrievalError];
    
    XCTAssertNotNil(gardenRows);
    XCTAssertTrue([gardenRows count] == 5);
    XCTAssertNil(retrievalError);
    
    
    
    id success = [controller processStatement:@"DELETE FROM garden WHERE date_added IS NULL"
                               bindableValues:nil
                                affinityTypes:nil
                                  insulatedly:YES
                                        error:&deleteError];
    
    XCTAssertNotNil(success);
    XCTAssertNil(deleteError);
    
    gardenRows = [controller rowsFromTable:@"garden"
                      withSpecifiedColumns:nil
                              stipulations:nil
                                    offset:0
                andMaxNumberOfRowsToReturn:20
                                 orderedBy:nil
                                     error:&retrievalError];
    
    XCTAssertNotNil(gardenRows);
    XCTAssertTrue([gardenRows count] == 2);
    XCTAssertNil(retrievalError);
}

- (void)test_A6_2_processBasicDeleteNoRowsInTableShouldPassWithGoodTableName {
    
    NSError *deleteError;
    NSError *retrievalError;
    
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    NSArray *gardenRows = [controller rowsFromTable:@"garden"
                               withSpecifiedColumns:nil
                                       stipulations:nil
                                             offset:0
                         andMaxNumberOfRowsToReturn:20
                                          orderedBy:nil
                                              error:&retrievalError];
    
    XCTAssertNotNil(gardenRows);
    XCTAssertTrue([gardenRows count] == 5);
    XCTAssertNil(retrievalError);
    
    
    
    id success = [controller processStatement:@"DELETE FROM garden WHERE date_added='pico de gallo'"
                               bindableValues:nil
                                affinityTypes:nil
                                  insulatedly:YES
                                        error:&deleteError];
    
    XCTAssertNotNil(success);
    XCTAssertNil(deleteError);
    
    gardenRows = [controller rowsFromTable:@"garden"
                      withSpecifiedColumns:nil
                              stipulations:nil
                                    offset:0
                andMaxNumberOfRowsToReturn:20
                                 orderedBy:nil
                                     error:&retrievalError];
    
    XCTAssertNotNil(gardenRows);
    XCTAssertTrue([gardenRows count] == 5);
    XCTAssertNil(retrievalError);
}

- (void)test_A6_3_processBasicDeleteAllRowsFromNonTableShouldFail {
    NSError *deleteError;
    NSError *retrievalError;
    
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    NSArray *gardenRows = [controller rowsFromTable:@"garden"
                               withSpecifiedColumns:nil
                                       stipulations:nil
                                             offset:0
                         andMaxNumberOfRowsToReturn:20
                                          orderedBy:nil
                                              error:&retrievalError];
    
    XCTAssertNotNil(gardenRows);
    XCTAssertTrue([gardenRows count] == 5);
    XCTAssertNil(retrievalError);
    
    
    
    id success = [controller processStatement:@"DELETE FROM oaentgoaentg"
                               bindableValues:nil
                                affinityTypes:nil
                                  insulatedly:YES
                                        error:&deleteError];
    
    XCTAssertNil(success);
    XCTAssertNotNil(deleteError);
    
    gardenRows = [controller rowsFromTable:@"garden"
                      withSpecifiedColumns:nil
                              stipulations:nil
                                    offset:0
                andMaxNumberOfRowsToReturn:20
                                 orderedBy:nil
                                     error:&retrievalError];
    
    XCTAssertNotNil(gardenRows);
    XCTAssertTrue([gardenRows count] == 5);
    XCTAssertNil(retrievalError);
}

- (void)test_A6_3_processBasicDeleteSomeRowsFromNonTableShouldFail {
    NSError *deleteError;
    NSError *retrievalError;
    
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    NSArray *gardenRows = [controller rowsFromTable:@"garden"
                               withSpecifiedColumns:nil
                                       stipulations:nil
                                             offset:0
                         andMaxNumberOfRowsToReturn:20
                                          orderedBy:nil
                                              error:&retrievalError];
    
    XCTAssertNotNil(gardenRows);
    XCTAssertTrue([gardenRows count] == 5);
    XCTAssertNil(retrievalError);
    
    
    
    id success = [controller processStatement:@"DELETE FROM oaentgoaentg WHERE date_added IS NULL"
                               bindableValues:nil
                                affinityTypes:nil
                                  insulatedly:YES
                                        error:&deleteError];
    
    XCTAssertNil(success);
    XCTAssertNotNil(deleteError);
    
    gardenRows = [controller rowsFromTable:@"garden"
                      withSpecifiedColumns:nil
                              stipulations:nil
                                    offset:0
                andMaxNumberOfRowsToReturn:20
                                 orderedBy:nil
                                     error:&retrievalError];
    
    XCTAssertNotNil(gardenRows);
    XCTAssertTrue([gardenRows count] == 5);
    XCTAssertNil(retrievalError);
}

- (void)test_A6_3_processBasicDeleteNoRowsFromNonTableShouldFail {
    NSError *deleteError;
    NSError *retrievalError;
    
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    NSArray *gardenRows = [controller rowsFromTable:@"garden"
                               withSpecifiedColumns:nil
                                       stipulations:nil
                                             offset:0
                         andMaxNumberOfRowsToReturn:20
                                          orderedBy:nil
                                              error:&retrievalError];
    
    XCTAssertNotNil(gardenRows);
    XCTAssertTrue([gardenRows count] == 5);
    XCTAssertNil(retrievalError);
    
    
    
    id success = [controller processStatement:@"DELETE FROM oaentgoaentg WHERE aoergn IS NULL"
                               bindableValues:nil
                                affinityTypes:nil
                                  insulatedly:YES
                                        error:&deleteError];
    
    XCTAssertNil(success);
    XCTAssertNotNil(deleteError);
    
    gardenRows = [controller rowsFromTable:@"garden"
                      withSpecifiedColumns:nil
                              stipulations:nil
                                    offset:0
                andMaxNumberOfRowsToReturn:20
                                 orderedBy:nil
                                     error:&retrievalError];
    
    XCTAssertNotNil(gardenRows);
    XCTAssertTrue([gardenRows count] == 5);
    XCTAssertNil(retrievalError);
}


@end

