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

@interface DatabaseControllerOpenDatabaseTests : XCTestCase {
    LabQLiteTestSetupConstants *_constants;
}

@end



@implementation DatabaseControllerOpenDatabaseTests

- (void)setUp {
    [super setUp];
    _constants = [[LabQLiteTestSetupConstants alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    _constants = nil;
    [super tearDown];
}



#pragma mark - Testing the -openDatabaseController: Method

- (void)test_01_openDatabaseControllerShouldPassWithGoodDatabase {
    BOOL databaseOpened = [_constants->_commonTestDatabase openDatabase:nil];
    XCTAssertTrue(databaseOpened);
    [_constants->_commonTestDatabase closeDatabase:nil];
}

- (void)test_02_openDatabaseControllerShouldFailWithCorruptDatabase {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_corruptDatabaseFileName
                                                                                   sourcePath:_constants->_goodBundleDatabaseFilePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertFalse(databaseOpened);
    [controller closeDatabase:nil];
}

- (void)test_03_openDatabaseControllerShouldFailWithNonDatabase {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_goodBundleDatabaseFileName
                                                                                   sourcePath:_constants->_nonDatabasePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertFalse(databaseOpened);
    [controller closeDatabase:nil];
}

- (void)test_04_corruptDatabaseControllerOpenFailureShouldReportAppropriateError {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_goodBundleDatabaseFileName
                                                                                   sourcePath:_constants->_corruptDatabaseFileName
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    BOOL databaseOpened = [controller openDatabase:nil];
    XCTAssertFalse(databaseOpened);
    [controller closeDatabase:nil];
}

- (void)test_05_nonDatabaseControllerOpenFailureShouldReportAppropriateError {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_corruptDatabaseFileName
                                                                                   sourcePath:_constants->_nonDatabasePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    
    [controller openDatabase:nil];
    XCTAssertTrue([setupError.userInfo[@"userInfo"] compare:SQLITE_1_ERROR_Message] == NSOrderedSame);
}



#pragma mark - Testing the -openDatabaseWithCompletionBlock: Method

- (void)test_06_blockBasedOpenDatabaseControllerShouldPassWithGoodDatabase {
    BOOL __block openSuccess = NO;
    [_constants->_commonTestDatabase openDatabaseWithCompletionBlock:^(BOOL success, NSError *blockError) {
        openSuccess = success;
    }];
    XCTAssertTrue(openSuccess);
    [_constants->_commonTestDatabase closeDatabase:nil];
}

- (void)test_07_blockBasedOpenDatabaseControllerShouldFailWithCorruptDatabase {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_corruptDatabaseFileName
                                                                                   sourcePath:_constants->_goodBundleDatabaseFilePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    BOOL __block openSuccess = NO;
    [controller openDatabaseWithCompletionBlock:^(BOOL success, NSError *blockError) {
        openSuccess = success;
    }];
    XCTAssertFalse(openSuccess);
    [controller closeDatabase:nil];
}

- (void)test_08_blockBasedOpenDatabaseControllerShouldFailWithNonDatabase {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_goodBundleDatabaseFileName
                                                                                   sourcePath:_constants->_nonDatabasePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];

    BOOL __block openSuccess = NO;
    [controller openDatabaseWithCompletionBlock:^(BOOL success, NSError *blockError) {
        openSuccess = success;
    }];
    XCTAssertFalse(openSuccess);
    [controller closeDatabase:nil];
}

- (void)test_09_corruptDatabaseBlockBasedOpenFailureShouldReportAppropriateError {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_corruptDatabaseFileName
                                                                                   sourcePath:_constants->_goodBundleDatabaseFilePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    BOOL __block openSuccess = NO;
    NSError __block *e;
    [controller openDatabaseWithCompletionBlock:^(BOOL success, NSError *blockError) {
        openSuccess = success;
        e = blockError;
    }];
    
    XCTAssertTrue([e.userInfo[@"errorMessage"] compare:SQLITE_1_ERROR_Message] == NSOrderedSame);
    [controller closeDatabase:nil];
}

- (void)test_10_nonDatabaseBlockBasedOpenFailureShouldReportAppropriateError {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_goodBundleDatabaseFileName
                                                                                   sourcePath:_constants->_nonDatabasePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    BOOL __block openSuccess = NO;
    NSError __block *e;
    [controller openDatabaseWithCompletionBlock:^(BOOL success, NSError *blockError) {
        openSuccess = success;
        e = blockError;
    }];
    
    XCTAssertTrue([e.userInfo[@"errorMessage"] compare:SQLITE_1_ERROR_Message] == NSOrderedSame);
    [controller closeDatabase:nil];
}


@end
