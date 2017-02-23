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

@interface DatabaseControllerUpdateTests : XCTestCase {
    LabQLiteTestSetupConstants *_constants;
}


@end

@implementation DatabaseControllerUpdateTests

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


- (void)test_43_processBasicUpdateAllRowsInTableUPDATEStatementShouldPass {

    NSError *updateError;
    NSError *retrievalError;

    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    
    id success = [controller processStatement:@"UPDATE OR ROLLBACK garden SET address=1234"
                               bindableValues:nil
                                affinityTypes:nil
                                  insulatedly:YES
                                        error:&updateError];
    
    XCTAssertNotNil(success);
    XCTAssertNil(updateError);
    
    NSArray *gardenRows = [controller rowsFromTable:@"garden"
                               withSpecifiedColumns:nil
                                       stipulations:nil
                                             offset:0
                         andMaxNumberOfRowsToReturn:20
                                          orderedBy:nil
                                              error:&retrievalError];
    
    XCTAssertNotNil(gardenRows);
    XCTAssertNil(retrievalError);
    
    XCTAssertTrue([gardenRows count] == 5);
    
    XCTAssertTrue([gardenRows[0][1] isEqualToString:@"1234"]);
    XCTAssertTrue([gardenRows[1][1] isEqualToString:@"1234"]);
    XCTAssertTrue([gardenRows[2][1] isEqualToString:@"1234"]);
    XCTAssertTrue([gardenRows[3][1] isEqualToString:@"1234"]);
    XCTAssertTrue([gardenRows[4][1] isEqualToString:@"1234"]);
    
    
}

- (void)test_44_processBasicUpdateOfSomeRowsInTableUPDATEStatementShouldPass {
    NSError *updateError;
    NSError *retrievalError;
    
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    
    id success = [controller processStatement:@"UPDATE OR ROLLBACK garden SET date_added=1234 WHERE date_added IS NULL"
                               bindableValues:nil
                                affinityTypes:nil
                                  insulatedly:YES
                                        error:&updateError];
    
    XCTAssertNotNil(success);
    XCTAssertNil(updateError);
    
    NSArray *gardenRows;
    if (success) {
        gardenRows = [controller rowsFromTable:@"garden"
                          withSpecifiedColumns:nil
                                  stipulations:nil
                                        offset:0
                    andMaxNumberOfRowsToReturn:20
                                     orderedBy:nil
                                         error:&retrievalError];
    }
    
    XCTAssertNotNil(gardenRows);
    XCTAssertNil(retrievalError);
    
    XCTAssertTrue([gardenRows count] == 5);
    
    for (NSArray *a in gardenRows) {
        if ([a[0] isEqualToString:@"Yuyuan Garden"] ||
            [a[0] isEqualToString:@"Minneapolis Sculpture Garden"] ||
            [a[0] isEqualToString:@"Keukenhof Gardens"]) {
            XCTAssertTrue([a[2] isEqualToString:@"1234"]);
        }
    }
}

- (void)test_45_processBasicUpdateOfEmptyTableUPDATEStatementShouldPass {
    NSError *updateError;
    NSError *retrievalError;
    
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    
    id success = [controller processStatement:@"UPDATE OR ROLLBACK plant_is_in_garden SET count_of_plant=10"
                               bindableValues:nil
                                affinityTypes:nil
                                  insulatedly:YES
                                        error:&updateError];
    
    XCTAssertNotNil(success);
    XCTAssertNil(updateError);
    
    NSArray *pingrows = [controller rowsFromTable:@"plant_is_in_garden"
                               withSpecifiedColumns:nil
                                       stipulations:nil
                                             offset:0
                         andMaxNumberOfRowsToReturn:20
                                          orderedBy:nil
                                              error:&retrievalError];
    
    XCTAssertNotNil(pingrows);
    XCTAssertNil(retrievalError);
    
    XCTAssertTrue([pingrows count] == 0);
}

- (void)test_46_processBasicUpdateOfAllRowsInNonTableUPDATEStatementShouldFail {
    NSError *updateError;
    
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    
    id success = [controller processStatement:@"UPDATE OR ROLLBACK aergtaerga SET count_of_plant=10"
                               bindableValues:nil
                                affinityTypes:nil
                                  insulatedly:YES
                                        error:&updateError];
    
    XCTAssertNil(success);
    XCTAssertNotNil(updateError);
}

- (void)test_47_processBasicUpdateOfSomeRowsInNonTableUPDATEStatementShouldFail {
    NSError *updateError;
    
    XCTAssertNotNil(_constants->_commonTestDatabase);
    
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    
    id success = [controller processStatement:@"UPDATE OR ROLLBACK aergtaerga SET count_of_plant=10 WHERE count_of_plant IS NULL"
                               bindableValues:nil
                                affinityTypes:nil
                                  insulatedly:YES
                                        error:&updateError];
    
    XCTAssertNil(success);
    XCTAssertNotNil(updateError);
}




@end
