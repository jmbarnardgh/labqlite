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

@interface DatabaseControllerRollbackTests : XCTestCase {
    LabQLiteTestSetupConstants *_constants;
}

@end



@implementation DatabaseControllerRollbackTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    _constants = nil;
    [super tearDown];
}


#pragma mark - Testing the rollback:error: Method

- (void)test_27_rollbackShouldPassWithGoodSavepointPrecedingAndNonCommittedChangesWithinTransaction {
    NSError *setupError;
    NSBundle *bundleWithDB = [NSBundle bundleForClass:[self class]];
    
    NSString *sourceFileName = @"garden.db";
    
    NSString *writePath = @"MyAwesomeDatabase/";
    NSString *writeFile = @"gardem.db";
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:sourceFileName
                                                                                   sourcePath:[bundleWithDB resourcePath]
                                                                  toBeCopiedToAndUsedFromPath:writePath
                                                                                writeFileName:writeFile
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    
    NSError *gardenRowsRetrievalError;
    Garden *genericGarden = [Garden new];
    
    NSArray *rows = [controller processStatement:@"SELECT * FROM garden"
                                  bindableValues:nil
                                   affinityTypes:nil
                                     insulatedly:NO
                                           error:&gardenRowsRetrievalError];
    
    
    NSUInteger rowCount = [rows count];
    XCTAssertTrue(rowCount==0);
    
    NSError *savePointCreationError;
    
    NSString *savepointName = @"spname";
    
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertTrue(databaseOpened);
    
    [controller processStatement:@"BEGIN TRANSACTION"
                  bindableValues:nil
                   affinityTypes:nil
                     insulatedly:NO
                      completion:^(NSArray *a, NSError *e) {
                          
                      }
     ];
    
    BOOL savePointCreated = [controller createSavepoint:savepointName
                                                  error:&savePointCreationError];
    
    XCTAssertTrue(savePointCreated);
    
    Garden *g1 = [Garden new];
    g1.gardenName = @"SomeGarden";
    g1.address = @"SomeAddress";
    
    Garden *g2 = [Garden new];
    g2.gardenName = @"SomeGarden2";
    g2.address = @"SomeAddress2";
    
    NSError *insertionError;
    
    BOOL insertionSucceeded = [controller insertRows:@[g1, g2]
                                           intoTable:[g1 tableName]
                                         insulatedly:NO
                                               error:&insertionError];
    
    XCTAssertTrue(insertionSucceeded);
    
    NSError *rowSelection2Error;
    
    rows = [controller processStatement:@"SELECT * FROM garden"
                         bindableValues:nil
                          affinityTypes:nil
                            insulatedly:NO
                                  error:&rowSelection2Error];
    
    XCTAssertNotNil(rows);
    
    
    NSUInteger rowCount2 = [rows count];
    
    XCTAssertTrue(rowCount2==2);
    
    // After rolling back, we should see
    // that the row count is 0 again.
    
    NSError *rollbackError;
    //    BOOL didRollBack = [controller rollbackToSavepointWithName:savepointName
    //                                                         error:&rollbackError];
    
    
    NSArray *didRollBack = [controller processStatement:@"ROLLBACK"
                                         bindableValues:nil
                                          affinityTypes:nil
                                            insulatedly:NO
                                                  error:&rollbackError];
    
    XCTAssertNotNil(didRollBack);
    
    NSError *closeDatabaseError;
    [controller closeDatabase:&closeDatabaseError];
    
    
    rows = [controller rowsFromTable:[genericGarden tableName]
           asSQLite3RowsWithSubclass:[Garden class]
                        stipulations:nil
                              offset:0
          andMaxNumberOfRowsToReturn:10
                           orderedBy:nil
                               error:&gardenRowsRetrievalError];
    
    NSUInteger rowCount3 = [rows count];
    
    XCTAssertTrue(rowCount3==0);
    
    [controller closeDatabase:nil];
}

- (void)test_28_rollbackShouldPassWithSpecifiedGoodSavePointPreceding{
    NSError *setupError;
    NSBundle *bundleWithDB = [NSBundle bundleForClass:[self class]];
    
    NSString *sourceFileName = @"garden.db";
    
    NSString *writePath = @"MyAwesomeDatabase/";
    NSString *writeFile = @"gardem.db";
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:sourceFileName
                                                                                   sourcePath:[bundleWithDB resourcePath]
                                                                  toBeCopiedToAndUsedFromPath:writePath
                                                                                writeFileName:writeFile
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    
    NSError *gardenRowsRetrievalError;
    Garden *genericGarden = [Garden new];
    
    NSArray *rows = [controller processStatement:@"SELECT * FROM garden"
                                  bindableValues:nil
                                   affinityTypes:nil
                                     insulatedly:NO
                                           error:&gardenRowsRetrievalError];
    
    
    NSUInteger rowCount = [rows count];
    XCTAssertTrue(rowCount==0);
    
    NSError *savePointCreationError;
    
    NSString *savepointName = @"spname";
    
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertTrue(databaseOpened);
    
    [controller processStatement:@"BEGIN TRANSACTION"
                  bindableValues:nil
                   affinityTypes:nil
                     insulatedly:NO
                      completion:^(NSArray *a, NSError *e) {
                          
                      }
     ];
    
    BOOL savePointCreated = [controller createSavepoint:savepointName
                                                  error:&savePointCreationError];
    
    XCTAssertTrue(savePointCreated);
    
    Garden *g1 = [Garden new];
    g1.gardenName = @"SomeGarden";
    g1.address = @"SomeAddress";
    
    Garden *g2 = [Garden new];
    g2.gardenName = @"SomeGarden2";
    g2.address = @"SomeAddress2";
    
    NSError *insertionError;
    
    BOOL insertionSucceeded = [controller insertRows:@[g1, g2]
                                           intoTable:[g1 tableName]
                                         insulatedly:NO
                                               error:&insertionError];
    
    XCTAssertTrue(insertionSucceeded);
    
    NSError *rowSelection2Error;
    
    rows = [controller processStatement:@"SELECT * FROM garden"
                         bindableValues:nil
                          affinityTypes:nil
                            insulatedly:NO
                                  error:&rowSelection2Error];
    
    XCTAssertNotNil(rows);
    
    
    NSUInteger rowCount2 = [rows count];
    
    XCTAssertTrue(rowCount2==2);
    
    // After rolling back, we should see
    // that the row count is 0 again.
    
    NSError *rollbackError;
    //    BOOL didRollBack = [controller rollbackToSavepointWithName:savepointName
    //                                                         error:&rollbackError];
    
    
    BOOL  didRollBack = [controller rollbackToSavepointWithName:savepointName
                                                          error:&rollbackError];
    
    XCTAssertTrue(didRollBack);
    
    NSError *closeDatabaseError;
    [controller closeDatabase:&closeDatabaseError];
    
    
    rows = [controller rowsFromTable:[genericGarden tableName]
           asSQLite3RowsWithSubclass:[Garden class]
                        stipulations:nil
                              offset:0
          andMaxNumberOfRowsToReturn:10
                           orderedBy:nil
                               error:&gardenRowsRetrievalError];
    
    NSUInteger rowCount3 = [rows count];
    
    XCTAssertTrue(rowCount3==0);
    
    [controller closeDatabase:nil];
}

- (void)test_29_rollbackShouldFailWithNoSavePointPreceding {
    NSError *setupError;
    NSBundle *bundleWithDB = [NSBundle bundleForClass:[self class]];
    
    NSString *sourceFileName = @"garden.db";
    
    NSString *writePath = @"MyAwesomeDatabase/";
    NSString *writeFile = @"gardem.db";
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:sourceFileName
                                                                                   sourcePath:[bundleWithDB resourcePath]
                                                                  toBeCopiedToAndUsedFromPath:writePath
                                                                                writeFileName:writeFile
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    
    NSError *gardenRowsRetrievalError;
    
    NSArray *rows = [controller processStatement:@"SELECT * FROM garden"
                                  bindableValues:nil
                                   affinityTypes:nil
                                     insulatedly:NO
                                           error:&gardenRowsRetrievalError];
    
    
    NSUInteger rowCount = [rows count];
    XCTAssertTrue(rowCount==0);
    
    NSError *savePointCreationError;
    
    NSString *savepointName = nil;
    
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertTrue(databaseOpened);
    
    [controller processStatement:@"BEGIN TRANSACTION"
                  bindableValues:nil
                   affinityTypes:nil
                     insulatedly:NO
                      completion:^(NSArray *a, NSError *e) {
                          
                      }
     ];
    
    BOOL savePointCreated = [controller createSavepoint:savepointName
                                                  error:&savePointCreationError];
    
    XCTAssertFalse(savePointCreated);
    
    Garden *g1 = [Garden new];
    g1.gardenName = @"SomeGarden";
    g1.address = @"SomeAddress";
    
    Garden *g2 = [Garden new];
    g2.gardenName = @"SomeGarden2";
    g2.address = @"SomeAddress2";
    
    NSError *insertionError;
    
    BOOL insertionSucceeded = [controller insertRows:@[g1, g2]
                                           intoTable:[g1 tableName]
                                         insulatedly:NO
                                               error:&insertionError];
    
    XCTAssertTrue(insertionSucceeded);
    
    NSError *rowSelection2Error;
    
    rows = [controller processStatement:@"SELECT * FROM garden"
                         bindableValues:nil
                          affinityTypes:nil
                            insulatedly:NO
                                  error:&rowSelection2Error];
    
    XCTAssertNotNil(rows);
    
    
    NSUInteger rowCount2 = [rows count];
    
    XCTAssertTrue(rowCount2==2);
    
    // After rolling back, we should see
    // that the row count is 0 again.
    
    NSError *rollbackError;
    //    BOOL didRollBack = [controller rollbackToSavepointWithName:savepointName
    //                                                         error:&rollbackError];
    
    
    BOOL  didRollBack = [controller rollbackToSavepointWithName:savepointName
                                                          error:&rollbackError];
    
    XCTAssertFalse(didRollBack);
    
    rows = [controller processStatement:@"SELECT * FROM garden"
                         bindableValues:nil
                          affinityTypes:nil
                            insulatedly:NO
                                  error:&rowSelection2Error];
    
    NSUInteger rowCount3 = [rows count];
    
    // Rollback should have failed, keeping the database
    // table called 'garden' loaded with 2 rows still.
    XCTAssertTrue(rowCount3==2);
    
    [controller closeDatabase:nil];
}

- (void)test_30_rollbackShouldFailWithInvalidSpecifiedSavePoint {
    NSError *setupError;
    NSBundle *bundleWithDB = [NSBundle bundleForClass:[self class]];
    
    NSString *sourceFileName = @"garden.db";
    
    NSString *writePath = @"MyAwesomeDatabase/";
    NSString *writeFile = @"gardem.db";
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:sourceFileName
                                                                                   sourcePath:[bundleWithDB resourcePath]
                                                                  toBeCopiedToAndUsedFromPath:writePath
                                                                                writeFileName:writeFile
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    
    NSError *gardenRowsRetrievalError;
    
    NSArray *rows = [controller processStatement:@"SELECT * FROM garden"
                                  bindableValues:nil
                                   affinityTypes:nil
                                     insulatedly:NO
                                           error:&gardenRowsRetrievalError];
    
    
    NSUInteger rowCount = [rows count];
    XCTAssertTrue(rowCount==0);
    
    NSError *savePointCreationError;
    
    NSString *savepointName = nil;
    
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertTrue(databaseOpened);
    
    [controller processStatement:@"BEGIN TRANSACTION"
                  bindableValues:nil
                   affinityTypes:nil
                     insulatedly:NO
                      completion:^(NSArray *a, NSError *e) {
                          
                      }
     ];
    
    BOOL savePointCreated = [controller createSavepoint:savepointName
                                                  error:&savePointCreationError];
    
    XCTAssertFalse(savePointCreated);
    
    Garden *g1 = [Garden new];
    g1.gardenName = @"SomeGarden";
    g1.address = @"SomeAddress";
    
    Garden *g2 = [Garden new];
    g2.gardenName = @"SomeGarden2";
    g2.address = @"SomeAddress2";
    
    NSError *insertionError;
    
    BOOL insertionSucceeded = [controller insertRows:@[g1, g2]
                                           intoTable:[g1 tableName]
                                         insulatedly:NO
                                               error:&insertionError];
    
    XCTAssertTrue(insertionSucceeded);
    
    NSError *rowSelection2Error;
    
    rows = [controller processStatement:@"SELECT * FROM garden"
                         bindableValues:nil
                          affinityTypes:nil
                            insulatedly:NO
                                  error:&rowSelection2Error];
    
    XCTAssertNotNil(rows);
    
    
    NSUInteger rowCount2 = [rows count];
    
    XCTAssertTrue(rowCount2==2);
    
    // After rolling back, we should see
    // that the row count is 0 again.
    
    NSError *rollbackError;
    //    BOOL didRollBack = [controller rollbackToSavepointWithName:savepointName
    //                                                         error:&rollbackError];
    
    
    BOOL  didRollBack = [controller rollbackToSavepointWithName:@"invalid_save_point_name"
                                                          error:&rollbackError];
    
    XCTAssertFalse(didRollBack);
    
    rows = [controller processStatement:@"SELECT * FROM garden"
                         bindableValues:nil
                          affinityTypes:nil
                            insulatedly:NO
                                  error:&rowSelection2Error];
    
    NSUInteger rowCount3 = [rows count];
    
    // Rollback should have failed, keeping the database
    // table called 'garden' loaded with 2 rows still.
    XCTAssertTrue(rowCount3==2);
    
    [controller closeDatabase:nil];
}



#pragma mark - Testing the rollback:completion: Method

- (void)test_31_blockBasedRollbackShouldPassWithGoodSavePointPreceding {
    NSError *setupError;
    NSBundle *bundleWithDB = [NSBundle bundleForClass:[self class]];
    
    NSString *sourceFileName = @"garden.db";
    
    NSString *writePath = @"MyAwesomeDatabase/";
    NSString *writeFile = @"gardem.db";
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:sourceFileName
                                                                                   sourcePath:[bundleWithDB resourcePath]
                                                                  toBeCopiedToAndUsedFromPath:writePath
                                                                                writeFileName:writeFile
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    
    NSError *gardenRowsRetrievalError;
    
    NSArray *rows = [controller processStatement:@"SELECT * FROM garden"
                                  bindableValues:nil
                                   affinityTypes:nil
                                     insulatedly:NO
                                           error:&gardenRowsRetrievalError];
    
    
    NSUInteger rowCount = [rows count];
    XCTAssertTrue(rowCount==0);
    
    NSError *savePointCreationError;
    
    NSString *savepointName = nil;
    
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertTrue(databaseOpened);
    
    [controller processStatement:@"BEGIN TRANSACTION"
                  bindableValues:nil
                   affinityTypes:nil
                     insulatedly:NO
                      completion:^(NSArray *a, NSError *e) {
                          
                      }
     ];
    
    BOOL savePointCreated = [controller createSavepoint:savepointName
                                                  error:&savePointCreationError];
    
    XCTAssertFalse(savePointCreated);
    
    Garden *g1 = [Garden new];
    g1.gardenName = @"SomeGarden";
    g1.address = @"SomeAddress";
    
    Garden *g2 = [Garden new];
    g2.gardenName = @"SomeGarden2";
    g2.address = @"SomeAddress2";
    
    NSError *insertionError;
    
    BOOL insertionSucceeded = [controller insertRows:@[g1, g2]
                                           intoTable:[g1 tableName]
                                         insulatedly:NO
                                               error:&insertionError];
    
    XCTAssertTrue(insertionSucceeded);
    
    NSError *rowSelection2Error;
    
    rows = [controller processStatement:@"SELECT * FROM garden"
                         bindableValues:nil
                          affinityTypes:nil
                            insulatedly:NO
                                  error:&rowSelection2Error];
    
    XCTAssertNotNil(rows);
    
    
    NSUInteger rowCount2 = [rows count];
    
    XCTAssertTrue(rowCount2==2);
    
    // After rolling back, we should see
    // that the row count is 0 again.
    
    BOOL __block didRollBack = NO;
    [controller rollbackToSavePointWithName:savepointName
                                 completion:^(BOOL s, NSError *e) {
                                     didRollBack = s;
                                 }
     ];
    
    XCTAssertFalse(didRollBack);
    
    rows = [controller processStatement:@"SELECT * FROM garden"
                         bindableValues:nil
                          affinityTypes:nil
                            insulatedly:NO
                                  error:&rowSelection2Error];
    
    NSUInteger rowCount3 = [rows count];
    
    // Rollback should have failed, keeping the database
    // table called 'garden' loaded with 2 rows still.
    XCTAssertTrue(rowCount3==2);
    
    [controller closeDatabase:nil];
}


- (void)test_33_blockBasedRollbackShouldFailWithNoSavePointPreceding {
    NSError *setupError;
    NSBundle *bundleWithDB = [NSBundle bundleForClass:[self class]];
    
    NSString *sourceFileName = @"garden.db";
    
    NSString *writePath = @"MyAwesomeDatabase/";
    NSString *writeFile = @"gardem.db";
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:sourceFileName
                                                                                   sourcePath:[bundleWithDB resourcePath]
                                                                  toBeCopiedToAndUsedFromPath:writePath
                                                                                writeFileName:writeFile
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    
    NSError *gardenRowsRetrievalError;
    
    NSArray *rows = [controller processStatement:@"SELECT * FROM garden"
                                  bindableValues:nil
                                   affinityTypes:nil
                                     insulatedly:NO
                                           error:&gardenRowsRetrievalError];
    
    NSUInteger rowCount = [rows count];
    XCTAssertTrue(rowCount==0);
    
    NSString *savepointName = nil;
    
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertTrue(databaseOpened);
    
    [controller processStatement:@"BEGIN TRANSACTION"
                  bindableValues:nil
                   affinityTypes:nil
                     insulatedly:NO
                      completion:^(NSArray *a, NSError *e) {
                          
                      }
     ];
    
    
    Garden *g1 = [Garden new];
    g1.gardenName = @"SomeGarden";
    g1.address = @"SomeAddress";
    
    Garden *g2 = [Garden new];
    g2.gardenName = @"SomeGarden2";
    g2.address = @"SomeAddress2";
    
    NSError *insertionError;
    
    BOOL insertionSucceeded = [controller insertRows:@[g1, g2]
                                           intoTable:[g1 tableName]
                                         insulatedly:NO
                                               error:&insertionError];
    
    XCTAssertTrue(insertionSucceeded);
    
    NSError *rowSelection2Error;
    
    rows = [controller processStatement:@"SELECT * FROM garden"
                         bindableValues:nil
                          affinityTypes:nil
                            insulatedly:NO
                                  error:&rowSelection2Error];
    
    XCTAssertNotNil(rows);
    
    NSUInteger rowCount2 = [rows count];
    
    XCTAssertTrue(rowCount2==2);
    
    // After rolling back, we should see
    // that the row count is 0 again.
    
    BOOL __block didRollBack = NO;
    [controller rollbackToSavePointWithName:savepointName
                                 completion:^(BOOL s, NSError *e) {
                                     didRollBack = s;
                                 }
     ];
    
    XCTAssertFalse(didRollBack);
    
    rows = [controller processStatement:@"SELECT * FROM garden"
                         bindableValues:nil
                          affinityTypes:nil
                            insulatedly:NO
                                  error:&rowSelection2Error];
    
    NSUInteger rowCount3 = [rows count];
    
    // Rollback should have failed, keeping the database
    // table called 'garden' loaded with 2 rows still.
    XCTAssertTrue(rowCount3==2);
    
    [controller closeDatabase:nil];
}

- (void)test_34_blockBasedRollbackShouldFailWithInvalidSpecifiedSavePoint {
    NSError *setupError;
    NSBundle *bundleWithDB = [NSBundle bundleForClass:[self class]];
    
    NSString *sourceFileName = @"garden.db";
    
    NSString *writePath = @"MyAwesomeDatabase/";
    NSString *writeFile = @"gardem.db";
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:sourceFileName
                                                                                   sourcePath:[bundleWithDB resourcePath]
                                                                  toBeCopiedToAndUsedFromPath:writePath
                                                                                writeFileName:writeFile
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    
    NSError *gardenRowsRetrievalError;
    
    NSArray *rows = [controller processStatement:@"SELECT * FROM garden"
                                  bindableValues:nil
                                   affinityTypes:nil
                                     insulatedly:NO
                                           error:&gardenRowsRetrievalError];
    
    NSUInteger rowCount = [rows count];
    XCTAssertTrue(rowCount==0);
    
    NSError *savePointCreationError;
    
    NSString *savepointName = nil;
    
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertTrue(databaseOpened);
    
    [controller processStatement:@"BEGIN TRANSACTION"
                  bindableValues:nil
                   affinityTypes:nil
                     insulatedly:NO
                      completion:^(NSArray *a, NSError *e) {
                          
                      }
     ];
    
    BOOL savePointCreated = [controller createSavepoint:savepointName
                                                  error:&savePointCreationError];
    
    XCTAssertFalse(savePointCreated);
    
    Garden *g1 = [Garden new];
    g1.gardenName = @"SomeGarden";
    g1.address = @"SomeAddress";
    
    Garden *g2 = [Garden new];
    g2.gardenName = @"SomeGarden2";
    g2.address = @"SomeAddress2";
    
    NSError *insertionError;
    
    BOOL insertionSucceeded = [controller insertRows:@[g1, g2]
                                           intoTable:[g1 tableName]
                                         insulatedly:NO
                                               error:&insertionError];
    
    XCTAssertTrue(insertionSucceeded);
    
    NSError *rowSelection2Error;
    
    rows = [controller processStatement:@"SELECT * FROM garden"
                         bindableValues:nil
                          affinityTypes:nil
                            insulatedly:NO
                                  error:&rowSelection2Error];
    
    XCTAssertNotNil(rows);
    
    NSUInteger rowCount2 = [rows count];
    
    XCTAssertTrue(rowCount2==2);
    
    // After rolling back, we should see
    // that the row count is 0 again.
    
    BOOL __block didRollBack = NO;
    [controller rollbackToSavePointWithName:@"invalid_save_point_name"
                                 completion:^(BOOL s, NSError *e) {
                                     didRollBack = s;
                                 }
     ];
    
    XCTAssertFalse(didRollBack);
    
    rows = [controller processStatement:@"SELECT * FROM garden"
                         bindableValues:nil
                          affinityTypes:nil
                            insulatedly:NO
                                  error:&rowSelection2Error];
    
    NSUInteger rowCount3 = [rows count];
    
    // Rollback should have failed, keeping the database
    // table called 'garden' loaded with 2 rows still.
    XCTAssertTrue(rowCount3==2);
    
    [controller closeDatabase:nil];
}



@end
