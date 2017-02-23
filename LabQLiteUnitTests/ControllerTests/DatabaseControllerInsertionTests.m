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

@interface DatabaseControllerInsertionTests : XCTestCase {
    LabQLiteTestSetupConstants *_constants;
}

@end

@implementation DatabaseControllerInsertionTests

- (void)setUp {
    [super setUp];
    _constants = [[LabQLiteTestSetupConstants alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    _constants = nil;
    [super tearDown];
}

- (void)test_A3_1_insertSingleRowTestShouldPassWithGoodDatabaseController {
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    BOOL didInsert = [controller insertRow:_constants->_butchartGardens
                                     error:nil];
    XCTAssertNotNil(controller);
    XCTAssertTrue(didInsert);
}

- (void)test_A3_2_insertMultipleRowsTestShouldPassWithGoodDatabaseController {
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    BOOL didInsert = [controller insertRows:@[_constants->_keukenhofGardens,
                                              _constants->_minneapolisSculptureGarden]
                                  intoTable:@"garden"
                                      error:nil];
    XCTAssertNotNil(controller);
    XCTAssertTrue(didInsert);
}

- (void)test_A3_3_blockBasedInsertMultipleRowsTestShouldPassWithGoodDatabaseController {
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    BOOL __block didInsert = NO;
    [controller insertRows:@[_constants->_topiaryGardens,
                             _constants->_yuyuanGarden]
                 intoTable:@"garden"
                completion:^(BOOL success, NSError *error) {
                    didInsert = success;
                }
    ];
    XCTAssertNotNil(controller);
    XCTAssertTrue(didInsert);
}

- (void)test_A3_4_insertDuplicateRowShouldFailWithGoodDatabaseController {
    LabQLiteDatabaseController *controller = _constants->_commonTestDatabase;
    BOOL didInsert = [controller insertRows:@[_constants->_keukenhofGardens]
                                  intoTable:@"garden"
                                      error:nil];
    XCTAssertNotNil(controller);
    XCTAssertFalse(didInsert);
}

@end
