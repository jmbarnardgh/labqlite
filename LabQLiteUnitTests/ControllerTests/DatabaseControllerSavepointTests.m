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

@interface DatabaseControllerSavepointTests : XCTestCase

@end

@implementation DatabaseControllerSavepointTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Testing the createSavepoint:error: Method

- (void)test_21_createSavePointShouldPassWithGoodSavePointName {
    NSError *setupError;
    NSBundle *bundleWithDB = [NSBundle bundleForClass:[self class]];
    
    NSString *sourceFileName = @"garden.db";
    
    NSString *writePath = @"MyAwesomeDatabase/";
    NSString *writeFile = @"db.sqlite";
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:sourceFileName
                                                                                   sourcePath:[bundleWithDB resourcePath]
                                                                  toBeCopiedToAndUsedFromPath:writePath
                                                                                writeFileName:writeFile
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertTrue(databaseOpened);
    
    NSError *error;
    NSString *savePointKey = @"save_point_key_0";
    [controller openDatabase:nil];
    BOOL savePointCreated = [controller createSavepoint:savePointKey
                                                  error:&error];
    [controller closeDatabase:nil];
    XCTAssertNotNil(controller);
    XCTAssertTrue(savePointCreated);
}

- (void)test_22_createSavePointShouldFailWithNilName {
    NSError *setupError;
    NSBundle *bundleWithDB = [NSBundle bundleForClass:[self class]];
    
    NSString *sourceFileName = @"garden.db";
    
    NSString *writePath = @"MyAwesomeDatabase/";
    NSString *writeFile = @"db.sqlite";
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:sourceFileName
                                                                                   sourcePath:[bundleWithDB resourcePath]
                                                                  toBeCopiedToAndUsedFromPath:writePath
                                                                                writeFileName:writeFile
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertTrue(databaseOpened);
    
    NSError *error;
    [controller openDatabase:nil];
    BOOL savePointCreated = [controller createSavepoint:nil
                                                  error:&error];
    [controller closeDatabase:nil];
    XCTAssertNotNil(controller);
    XCTAssertFalse(savePointCreated);
}

- (void)test_23_createSavePointShouldFailWithSQLInjectionAttempt {
    NSError *setupError;
    NSBundle *bundleWithDB = [NSBundle bundleForClass:[self class]];
    
    NSString *sourceFileName = @"garden.db";
    
    NSString *writePath = @"MyAwesomeDatabase/";
    NSString *writeFile = @"db.sqlite";
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:sourceFileName
                                                                                   sourcePath:[bundleWithDB resourcePath]
                                                                  toBeCopiedToAndUsedFromPath:writePath
                                                                                writeFileName:writeFile
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertTrue(databaseOpened);
    
    NSError *error;
    NSString *savePointKey = @"(SELECT * FROM sqlite_master)";
    [controller openDatabase:nil];
    BOOL savePointCreated = [controller createSavepoint:savePointKey
                                                  error:&error];
    [controller closeDatabase:nil];
    XCTAssertNotNil(controller);
    XCTAssertFalse(savePointCreated);
}



#pragma mark - Testing the createSavepoint:completion: Method

- (void)test_24_blockBasedCreateSavePointShouldPassWithGoodSavePointName {
    NSError *setupError;
    NSBundle *bundleWithDB = [NSBundle bundleForClass:[self class]];
    
    NSString *sourceFileName = @"garden.db";
    
    NSString *writePath = @"MyAwesomeDatabase/";
    NSString *writeFile = @"db.sqlite";
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:sourceFileName
                                                                                   sourcePath:[bundleWithDB resourcePath]
                                                                  toBeCopiedToAndUsedFromPath:writePath
                                                                                writeFileName:writeFile
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertTrue(databaseOpened);
    
    NSError __block *error;
    NSString *savePointKey = @"save_point_key_0";
    [controller openDatabase:nil];
    BOOL __block savePointCreated = FALSE;
    [controller createSavepoint:savePointKey
                     completion:^(BOOL created, NSError *e) {
                         savePointCreated = created;
                         error = e;
                     }
     ];
    [controller closeDatabase:nil];
    XCTAssertNotNil(controller);
    XCTAssertTrue(savePointCreated);
}

- (void)test_25_blockBasedCreateSavePointShouldFailWithNilName {
    NSError *setupError;
    NSBundle *bundleWithDB = [NSBundle bundleForClass:[self class]];
    
    NSString *sourceFileName = @"garden.db";
    
    NSString *writePath = @"MyAwesomeDatabase/";
    NSString *writeFile = @"db.sqlite";
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:sourceFileName
                                                                                   sourcePath:[bundleWithDB resourcePath]
                                                                  toBeCopiedToAndUsedFromPath:writePath
                                                                                writeFileName:writeFile
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertTrue(databaseOpened);
    
    NSError __block *error;
    BOOL __block savePointCreated;
    [controller openDatabase:nil];
    [controller createSavepoint:nil
                     completion:^(BOOL success, NSError *e) {
                         error = e;
                         savePointCreated = success;
                     }
     ];
    [controller closeDatabase:nil];
    XCTAssertNotNil(controller);
    XCTAssertFalse(savePointCreated);
}

- (void)test_26_blockBasedCreateSavePointShouldFailWithSQLInjectionAttempt {
    NSError *setupError;
    NSBundle *bundleWithDB = [NSBundle bundleForClass:[self class]];
    
    NSString *sourceFileName = @"garden.db";
    
    NSString *writePath = @"MyAwesomeDatabase/";
    NSString *writeFile = @"db.sqlite";
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:sourceFileName
                                                                                   sourcePath:[bundleWithDB resourcePath]
                                                                  toBeCopiedToAndUsedFromPath:writePath
                                                                                writeFileName:writeFile
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertTrue(databaseOpened);
    
    NSError *error;
    NSString *savePointKey = @"; SELECT * FROM sqlite_master";
    [controller openDatabase:nil];
    BOOL savePointCreated = [controller createSavepoint:savePointKey
                                                  error:&error];
    [controller closeDatabase:nil];
    XCTAssertNotNil(controller);
    XCTAssertFalse(savePointCreated);
}


@end
