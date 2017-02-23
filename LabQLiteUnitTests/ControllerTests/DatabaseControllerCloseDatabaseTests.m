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

@interface DatabaseControllerCloseDatabaseTests : XCTestCase {
    LabQLiteTestSetupConstants *_constants;
}

@end

@implementation DatabaseControllerCloseDatabaseTests

- (void)setUp {
    [super setUp];
    _constants = [[LabQLiteTestSetupConstants alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    _constants = nil;
    [super tearDown];
}


- (void)test_11_closeDatabaseShouldPassWithGoodDatabase {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_goodBundleDatabaseFileName
                                                                                   sourcePath:_constants->_goodBundleDatabaseFilePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    [controller openDatabase:nil];
    BOOL databaseClosed = [controller closeDatabase:nil];
    XCTAssertTrue(databaseClosed);
}

- (void)test_12_closeDatabaseShouldFailWithCorruptDatabase {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_corruptDatabaseFileName
                                                                                   sourcePath:_constants->_goodBundleDatabaseFilePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    [controller openDatabase:nil];
    BOOL databaseClosed = [controller closeDatabase:nil];
    XCTAssertFalse(databaseClosed);
}

- (void)test_13_closeDatabaseShouldFailWithNonDatabase {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_goodBundleDatabaseFileName
                                                                                   sourcePath:_constants->_nonDatabasePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    [controller openDatabase:nil];
    BOOL databaseClosed = [controller closeDatabase:nil];
    XCTAssertFalse(databaseClosed);
}

- (void)test_14_corruptDatabaseCloseFailureShouldReportAppropriateError {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_corruptDatabaseFileName
                                                                                   sourcePath:_constants->_goodBundleDatabaseFilePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    [controller openDatabase:nil];
    NSError *closeError;
    [controller closeDatabase:&closeError];
    XCTAssertTrue([closeError.userInfo[@"errorMessage"] compare:SQLITE_1_ERROR_Message] == NSOrderedSame);
}

- (void)test_15_nonDatabaseCloseFailureShouldReportAppropriateError {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_goodBundleDatabaseFileName
                                                                                   sourcePath:_constants->_nonDatabasePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    [controller openDatabase:nil];
    NSError *closeError;
    [controller closeDatabase:&closeError];
    XCTAssertTrue([closeError.userInfo[@"errorMessage"] compare:SQLITE_1_ERROR_Message] == NSOrderedSame);
}



#pragma mark - Testing the -closeDatabaseWithCompletionBlock: Method

- (void)test_16_blockBasedCloseDatabaseControllerShouldPassWithGoodDatabase {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_goodBundleDatabaseFileName
                                                                                   sourcePath:_constants->_goodBundleDatabaseFilePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    [controller openDatabase:nil];
    BOOL __block databaseClosed = NO;
    [controller closeDatabaseWithCompletionBlock:^(BOOL success, NSError *e) {
        databaseClosed = success;
    }];
    
    XCTAssertTrue(databaseClosed);
}

- (void)test_17_blockBasedCloseDatabaseControllerShouldFailWithCorruptDatabase {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_corruptDatabaseFileName
                                                                                   sourcePath:_constants->_goodBundleDatabaseFilePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    [controller openDatabase:nil];
    BOOL __block closedSuccessfully = NO;
    NSError __block *closeError;
    [controller closeDatabaseWithCompletionBlock:^(BOOL closed, NSError *error) {
        closedSuccessfully = closed;
        closeError = error;
    }];
    XCTAssertFalse(closedSuccessfully);
    XCTAssertFalse(closeError);
}

- (void)test_18_blockBasedCloseDatabaseControllerShouldFailWithNonDatabase {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_goodBundleDatabaseFileName
                                                                                   sourcePath:_constants->_nonDatabasePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    [controller openDatabase:nil];
    BOOL __block closedSuccessfully = NO;
    NSError __block *closeError;
    [controller closeDatabaseWithCompletionBlock:^(BOOL closed, NSError *error) {
        closedSuccessfully = closed;
        closeError = error;
    }];
    XCTAssertFalse(closedSuccessfully);
    XCTAssertFalse(closeError);
}

- (void)test_19_corruptDatabaseBlockBasedCloseFailureShouldReportAppropriateError {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_corruptDatabaseFileName
                                                                                   sourcePath:_constants->_goodBundleDatabaseFilePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    [controller openDatabase:nil];
    BOOL __block closedSuccessfully = NO;
    NSError __block *closeError;
    [controller closeDatabaseWithCompletionBlock:^(BOOL closed, NSError *error) {
        closedSuccessfully = closed;
        closeError = error;
    }];
    XCTAssertFalse(closedSuccessfully);
    XCTAssertFalse(closeError);
}

- (void)test_20_nonDatabaseBlockBasedCloseFailureShouldReportAppropriateError {
    NSError *setupError;
    LabQLiteDatabaseController *controller = [[LabQLiteDatabaseController alloc] initWithFile:_constants->_goodBundleDatabaseFileName
                                                                                   sourcePath:_constants->_nonDatabasePath
                                                                  toBeCopiedToAndUsedFromPath:_constants->_goodWriteFilePath
                                                                                writeFileName:_constants->_goodWriteFileName
                                                        assumingNSDocumentDirectoryAsRootPath:YES
                                                                                    overwrite:YES
                                                                                        error:&setupError];
    [controller openDatabase:nil];
    BOOL __block closedSuccessfully = NO;
    NSError __block *closeError;
    [controller closeDatabaseWithCompletionBlock:^(BOOL closed, NSError *error) {
        closedSuccessfully = closed;
        closeError = error;
    }];
    XCTAssertFalse(closedSuccessfully);
    XCTAssertFalse(closeError);
}


@end
