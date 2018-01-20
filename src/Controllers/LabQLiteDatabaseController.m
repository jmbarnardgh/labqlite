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

#import "LabQLiteDatabaseController.h"


@interface LabQLiteDatabaseController(PrivateMethods)

- (NSString *)appendStipulations:(NSArray *)arrayOfStipulations 
               toSQLString:(NSString *)sqlString;

- (NSString *)appendOffset:(NSUInteger)offset
         toSQLString:(NSString *)sqlString;

- (NSString *)appendRowsLimitation:(NSUInteger)limit
                 toSQLString:(NSString *)sqlString;

@end


@implementation LabQLiteDatabaseController

- (BOOL)openDatabase:(NSError **)error {
    return [_database openDatabase:error];
}

- (void)openDatabaseWithCompletionBlock:(void (^)(BOOL, NSError *))completion {
    NSError *error;
    BOOL success = [_database openDatabase:&error];
    completion(success, error);
}

- (BOOL)closeDatabase:(NSError **)error {
    return [_database closeDatabase:error];

}

- (void)closeDatabaseWithCompletionBlock:(void (^)(BOOL, NSError *))completion {
    NSError *error;
    BOOL success = [self closeDatabase:&error];
    completion(success, error);
}


- (BOOL)createSavepoint:(NSString *)savePointName
                  error:(NSError **)error {
    NSString *sql;
    if (savePointName == nil) {
        return NO;
    }
    else if ([savePointName compare:@""] == NSOrderedSame) {
        return NO;
    }
    else {
        sql = [NSString stringWithFormat:@"SAVEPOINT %@", savePointName];
    }
    
    if ([self processStatement:sql
                bindableValues:nil
                 affinityTypes:nil
                   insulatedly:NO
                         error:error]) {
        return YES;
    }
    return NO;
}

- (void)createSavepoint:(NSString *)savePointName
             completion:(void (^)(BOOL, NSError *))completion {
    NSError *error;
    BOOL success = [self createSavepoint:savePointName
                                   error:&error];
    completion(success, error);
}

- (BOOL)rollbackToSavepointWithName:(NSString *)savepointName
                              error:(NSError **)error {
    NSString *statement = [NSString stringWithFormat:@"ROLLBACK TRANSACTION TO SAVEPOINT %@", savepointName];
    if ([self processStatement:statement
                bindableValues:nil
                 affinityTypes:nil
                   insulatedly:NO
                         error:error]) {
        return YES;
    }
    return NO;
}

- (void)rollbackToSavePointWithName:(NSString *)savepointName
                        completion:(void (^)(BOOL, NSError *))completion {
    NSError *error;
    BOOL success = [self rollbackToSavepointWithName:savepointName
                                               error:&error];
    completion(success, error);
}

- (NSArray *)processStatement:(NSString *)sqlStatement
               bindableValues:(NSArray *)bindableValues
                affinityTypes:(NSArray *)affinityTypes
                  insulatedly:(BOOL)openingAndClosingOfDatabaseIsAutomatic
                        error:(NSError **)error {
    NSArray *results;
    if (openingAndClosingOfDatabaseIsAutomatic) {
        results = [self.database processStatement:sqlStatement
                                   bindableValues:bindableValues
                                    affinityTypes:affinityTypes
                                     openDatabase:YES
                                    closeDatabase:YES
                                            error:error];
    }
    else {
        results = [self.database processStatement:sqlStatement
                                   bindableValues:bindableValues
                                    affinityTypes:affinityTypes
                                     openDatabase:NO
                                    closeDatabase:NO
                                            error:error];
    }
    return results;
}

- (void)processStatement:(NSString *)sqlStatement
          bindableValues:(NSArray *)bindableValues
           affinityTypes:(NSArray *)affinityTypes
             insulatedly:(BOOL)openingAndClosingOfDatabaseIsAutomatic
              completion:(void (^)(NSArray *, NSError *))completion {
    NSError *error;
    NSArray *results;
    if (openingAndClosingOfDatabaseIsAutomatic) {
        if (![self.database openDatabase:&error]) {
            completion(nil, error);
        }
        else {
            results = [self.database
                       processStatement:sqlStatement
                       bindableValues:bindableValues
                       affinityTypes:affinityTypes
                       openDatabase:NO
                       closeDatabase:NO
                       error:&error];
            if (!results) {
                completion(nil, error);
            }
            else {
                if (![self.database closeDatabase:&error]) {
                    completion(nil, error);
                }
                else completion(results, error);
            }
        }
    }
    else {
        results = [self.database processStatement:sqlStatement
                                   bindableValues:bindableValues
                                    affinityTypes:affinityTypes
                                     openDatabase:NO
                                    closeDatabase:NO
                                            error:&error];
        completion(results, error);
    }
}

static LabQLiteDatabaseController *__sharedDatabaseController;

+ (LabQLiteDatabaseController *)sharedDatabaseController {
    if (!__sharedDatabaseController) return nil;
    return __sharedDatabaseController;
}

+ (BOOL)activateSharedControllerWithFileFromLocalBundle:(NSString *)filePath
                       toBeCopiedToAndUsedFromDirectory:(NSString *)savePath
                  assumingNSDocumentDirectoryAsRootPath:(BOOL)NSDocumentDirectoryIsRootPath
                                              overwrite:(BOOL)overwrite
                                                  error:(NSError **)error{
    __sharedDatabaseController = [[LabQLiteDatabaseController alloc] initWithFileInFromMainBundle:filePath
                                                                  toBeCopiedToAndUsedFromDirectory:savePath
                                                             assumingNSDocumentDirectoryAsRootPath:NSDocumentDirectoryIsRootPath
                                                                                         overwrite:overwrite
                                                                                             error:error];
    if (__sharedDatabaseController != nil) return YES;
    return NO;
}

+ (BOOL)activateSharedControllerWithDatabasePath:(NSString *)path
                                           error:(NSError **)error {
    __sharedDatabaseController = [[LabQLiteDatabaseController alloc] initWithDatabasePath:path error:error];
    if (__sharedDatabaseController != nil) return YES;
    return NO;
}

- (instancetype)initWithDatabasePath:(NSString *)databasePath
                               error:(NSError **)error {
    self = [super init];
    if (self) {
        _databasePath = databasePath;
        _database = [[LabQLiteDatabase alloc] initWithPath:databasePath error:error];
        if (!_database) return nil;
    }
    return self;
}

/**
 @abstract Initializes an LabQLiteDatabaseController and returns it.
 
 @param databasePath The path to the low-level sqlite3 database file.
 
 @param error The standard error capturing double indirection pointer.
 
 @return An initialized LabQLiteDatabaseController object.
 */
- (instancetype)initWithFile:(NSString *)sourceDatabaseFile
                  sourcePath:(NSString *)sourcePathOfDatabaseFile
 toBeCopiedToAndUsedFromPath:(NSString *)directoryToBeCopiedTo
               writeFileName:(NSString *)newFileNameOfCopiedDatabase
assumingNSDocumentDirectoryAsRootPath:(BOOL)assumedNSDocumentDirectoryAsRootPath
                   overwrite:(BOOL)overwrite
                       error:(NSError **)error {
    self = [super init];
    if (self) {
        
        // If database does not exists at the path provided,
        // then capture this as an error and return nil.
        NSFileManager *fileManager = [NSFileManager new];
        NSError *noDatabaseToCopyError;
        BOOL fileExists = [fileManager fileExistsAtPath:[sourcePathOfDatabaseFile stringByAppendingFormat:@"/%@", sourceDatabaseFile]];
        if (!fileExists) {
            if (error != nil) {
                noDatabaseToCopyError = [NSError errorWithDomain:LabQLiteErrorDomain
                                                            code:LabQLiteErrorDatabaseDoesNotExistInBundle
                                                        userInfo:@{@"errorMessage" : LabQLiteErrorMessageDatabaseDoesNotExistInBundle}];
            }
            if (error != nil) {
                *error = noDatabaseToCopyError;
            }
            return nil;
        }
        
        // Otherwise, proceed...
        
        // If the NSDocumentDirectory is the assumed root
        // directory, then use the provided path as a subpath
        NSMutableString *writeableDBPath = [NSMutableString new];
        if (assumedNSDocumentDirectoryAsRootPath) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            [writeableDBPath appendString:documentsDirectory];
        }
        // Otherwise just use the root path of the sandbox
        else {
            [writeableDBPath appendString:@"/"];
        }
        [writeableDBPath appendFormat:@"/%@", directoryToBeCopiedTo];
        
        // If there is a database at the write path specified
        // and overwriting is not desired parametrically,
        // then do not overwrite the existing database. Otherwise,
        // copy the database file from its source path to the
        // designated write path.
        NSError *copyDatabaseFileError;
        BOOL fileExistsAtWritePath = [fileManager fileExistsAtPath:[writeableDBPath stringByAppendingFormat:@"/%@", newFileNameOfCopiedDatabase]];
        BOOL successfulCopy = NO;

        // Prepare to remove previous file if need be...
        NSError *removePreviousFileError;
        BOOL successfulRemoval = NO;
        
        if (overwrite && fileExistsAtWritePath) {
            successfulRemoval = [fileManager removeItemAtPath:[writeableDBPath stringByAppendingFormat:@"/%@", newFileNameOfCopiedDatabase]
                                                        error:&removePreviousFileError];
            if (!successfulRemoval) {
                if (error != nil) {
                    *error = removePreviousFileError;
                }
                return nil;
            }
        }
        
        if ((overwrite && fileExistsAtWritePath && successfulRemoval) ||
            !fileExistsAtWritePath) {
            
            successfulCopy = [fileManager createDirectoryAtPath:writeableDBPath
                                    withIntermediateDirectories:YES
                                                     attributes:nil
                                                          error:&copyDatabaseFileError];
            
            if (successfulCopy) {
                successfulCopy = [fileManager copyItemAtPath:[sourcePathOfDatabaseFile stringByAppendingFormat:@"/%@", sourceDatabaseFile]
                                                      toPath:[writeableDBPath stringByAppendingFormat:@"/%@", newFileNameOfCopiedDatabase]
                                                       error:&copyDatabaseFileError];
            }
            
            if (!successfulCopy) {
                if (error != nil) {
                    *error = copyDatabaseFileError;
                }
                return nil;
            }
        }
        
        
        // If copied successfully, then initialze this database
        // controller with the just-recently-copied database file.
        NSError *initializationError;
        _database = [[LabQLiteDatabase alloc] initWithPath:[writeableDBPath stringByAppendingFormat:@"%@", newFileNameOfCopiedDatabase]
                                                     error:&initializationError];
        
        // If the database is nil, then return nil for this
        // database controller.
        if (_database == nil) {
            if (error != nil) {
                *error = initializationError;
            }
            return nil;
        }
        
    }
    return self;
}

- (instancetype)initWithFileInFromMainBundle:(NSString *)fileName
            toBeCopiedToAndUsedFromDirectory:(NSString *)path
       assumingNSDocumentDirectoryAsRootPath:(BOOL)assumedNSDocumentDirectoryAsRootPath
                                   overwrite:(BOOL)overwrite
                                       error:(NSError **)error {
    self = [super init];
    if (self) {
        
        // Defend against empty filename
        if (fileName == nil) return nil;
        
        NSMutableString *writeableDBPath = [NSMutableString new];
        
        // If NSDocumentDirectory is assumed to be the rooth path
        // then set it up as such, followed by 'path', followed by
        // the filename
        if (assumedNSDocumentDirectoryAsRootPath) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            [writeableDBPath appendString:documentsDirectory];
        }
        // Append subpath if provided
        if (path != nil) [writeableDBPath appendString:path];
        
        NSString *pathway = [NSString stringWithString:writeableDBPath];
        [writeableDBPath appendFormat:@"/%@", fileName];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // If database does not exist at the bundle path specified
        // then we cannot proceed.
        NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
        BOOL databaseExistsInBundle = [fileManager fileExistsAtPath:bundlePath];
        if (!databaseExistsInBundle) {
            if (error != nil) {
                *error = [NSError errorWithDomain:LabQLiteErrorDomain
                                             code:LabQLiteErrorDatabaseDoesNotExistInBundle
                                         userInfo:@{@"errorMessage" : LabQLiteErrorMessageDatabaseDoesNotExistInBundle}];
                return nil;
            }
        }
        
        // Otherwise, the database DOES exist in the bundle, an we
        // can proceed!
        else {

            BOOL fileExists = [fileManager fileExistsAtPath:writeableDBPath];
            
            // If we don't want to overwrite what is already there,
            // let's check to make sure a db exists first; we can
            // return it if it does exist.
            if (fileExists && !overwrite) {
                _databasePath = [[NSString alloc] initWithString:writeableDBPath];
                _database = [[LabQLiteDatabase alloc] initWithPath:_databasePath error:error];
                if (!_database) {
                    return nil;
                }
            }

            // If no current database file exists and we don't want to
            // overwrite, that's okay. We can create a new file... because
            // that is NOT considered overwriting.

            // If the file does not exist, and we want to overwrite,
            // that's fine. It's like creating a new file anyway.
            else if (!fileExists) {
                BOOL createdPathway = [fileManager createDirectoryAtPath:pathway
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:error];
                if (!createdPathway) return nil;
                BOOL successfulCopy = [fileManager copyItemAtPath:bundlePath toPath:writeableDBPath error:error];
                if (!successfulCopy) return nil;
                _databasePath = [[NSString alloc] initWithString:writeableDBPath];
                _database = [[LabQLiteDatabase alloc] initWithPath:_databasePath error:error];
                if (!_database) {
                    return nil;
                }
            }
            
            // If no current database file exists and we don't want to
            // overwrite, that's okay. We can create a new file... because
            // that is NOT considered overwriting.
            else if (!fileExists && !overwrite) {
                BOOL createdPathway = [fileManager createDirectoryAtPath:pathway
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:error];
                if (!createdPathway) return nil;
                BOOL successfulCopy = [fileManager copyItemAtPath:bundlePath toPath:writeableDBPath error:error];
                if (!successfulCopy) return nil;
                _databasePath = [[NSString alloc] initWithString:writeableDBPath];
                _database = [[LabQLiteDatabase alloc] initWithPath:_databasePath error:error];
                if (!_database) {
                    return nil;
                }
            }
            
            // If the file exists AND we wish to overwrite it, we must remove
            // the old file, put the new one in place, and then go from there.
            else if (fileExists && overwrite) {
                BOOL removed = [fileManager removeItemAtPath:writeableDBPath error:error];
                if (!removed) return nil;
                BOOL createdPathway = [fileManager createDirectoryAtPath:pathway
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:error];
                if (!createdPathway) return nil;
                BOOL successfulCopy = [fileManager copyItemAtPath:bundlePath toPath:writeableDBPath error:error];
                if (!successfulCopy) return nil;
                _databasePath = [[NSString alloc] initWithString:writeableDBPath];
                _database = [[LabQLiteDatabase alloc] initWithPath:_databasePath error:error];
                if (!_database) {
                    return nil;
                }
            } // End of fileExists vs. overwrite condition handling
        } // End of check for does database exist in bundle
    } // End of check for self not being nil.
    return self;
}

- (LabQLiteDatabase *)database {
    return _database;
}

- (NSMutableArray *)allRows:(NSString *)tableName
         SQLite3RowSubclass:(Class)cls
                      error:(NSError **)error {
    
    NSString *q = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    NSMutableArray *rows;
    
    rows = [NSMutableArray arrayWithArray:[self processStatement:q
                                                  bindableValues:nil
                                                   affinityTypes:nil
                                                     insulatedly:YES
                                                           error:error]];
    if (rows != nil && cls != nil) {
        if ([cls conformsToProtocol:@protocol(LabQLiteRowMappable)]) {
            NSMutableArray *normalizedRows = [NSMutableArray new];
            for (NSArray *array in rows) {
                id <LabQLiteRowMappable> newRow = [[cls alloc] init];
                for (NSString *key in [newRow propertyKeysMatchingAttributeColumns]) {
                    [(NSObject *)newRow setValue:[array objectAtIndex:[[newRow propertyKeysMatchingAttributeColumns] indexOfObject:key]]
                                   forKey:key];
                }
                [normalizedRows addObject:newRow];
            }
            return normalizedRows;
        }
    }
    return rows;
}

- (NSMutableArray *)rowsFromTable:(NSString *)tableName
             withSpecifiedColumns:(NSArray *)arrayOfAttributeNames
                     stipulations:(NSArray *)stipulations
                           offset:(NSUInteger)offset
       andMaxNumberOfRowsToReturn:(NSUInteger)maxNumberOfRowsToReturn
                        orderedBy:(NSString *)orderingAttribute
                            error:(NSError **)error {
    if (tableName == nil) return nil;
    else {
        NSMutableArray *rows = nil;
        NSString *q = @"SELECT";
        if (arrayOfAttributeNames == nil) {
            q = [q stringByAppendingString:@" *"];
        }
        else if ([arrayOfAttributeNames count] == 0) {
            q = [q stringByAppendingString:@" *"];
        }
        else {
            for (int i = 0; i < [arrayOfAttributeNames count]; i++) {
                q = [q stringByAppendingFormat:@" %@", [arrayOfAttributeNames objectAtIndex:i]];
                if (i != ([arrayOfAttributeNames count] - 1)) {
                    q = [q stringByAppendingString:@","];
                }
            }
        }
        q = [q stringByAppendingFormat:@" FROM %@", tableName];
        q = [self appendStipulations:stipulations toSQLString:q];
        if (orderingAttribute) q = [q stringByAppendingFormat:@" ORDER BY %@", orderingAttribute];
        q = [self appendRowsLimitation:maxNumberOfRowsToReturn toSQLString:q];
        q = [self appendOffset:offset toSQLString:q];
        
        NSArray *values = [LabQLiteStipulation valuesForBindingFromStipulations:stipulations];
        NSArray *affinities = [LabQLiteStipulation affinitiesForBindingFromStipulations:stipulations];
        
        
        NSArray *processedStatementArray = [self processStatement:q
                                                   bindableValues:values
                                                    affinityTypes:affinities
                                                      insulatedly:YES
                                                            error:error];
        if (processedStatementArray) {
            rows = [[NSMutableArray alloc] initWithArray:processedStatementArray];
        }
        return rows;
    }
}

- (NSMutableArray *)rowsFromTable:(NSString *)tableName
        asSQLite3RowsWithSubclass:(Class)SQLite3RowMappableConformingClass
                     stipulations:(NSArray *)stipulations
                           offset:(NSUInteger)offset
       andMaxNumberOfRowsToReturn:(NSUInteger)maxNumberOfRowsToReturn
                        orderedBy:(NSString *)orderingAttribute
                            error:(NSError **)error {
    
    NSMutableArray *rows = [self rowsFromTable:tableName
                          withSpecifiedColumns:nil
                                  stipulations:stipulations
                                        offset:offset
                    andMaxNumberOfRowsToReturn:maxNumberOfRowsToReturn
                                     orderedBy:orderingAttribute
                                         error:error];
    if (!rows) {
        return nil;
    }
    if (SQLite3RowMappableConformingClass != nil) {
        if ([SQLite3RowMappableConformingClass conformsToProtocol:@protocol(LabQLiteRowMappable)]) {
            NSMutableArray *normalizedRows = [NSMutableArray new];
            for (NSArray *array in rows) {
                id <LabQLiteRowMappable> newRow = [[SQLite3RowMappableConformingClass alloc] init];
                for (NSString *key in [newRow propertyKeysMatchingAttributeColumns]) {
                    [(NSObject *)newRow setValue:[array objectAtIndex:[[newRow propertyKeysMatchingAttributeColumns] indexOfObject:key]]
                              forKey:key];
                }
                [normalizedRows addObject:newRow];
            }
            return normalizedRows;
        }
    }
    return nil;
}

- (BOOL)populateMappableObject:(id <LabQLiteRowMappable>)mappableObject
                         error:(NSError **)error {
    NSArray *rowData = [self rowsFromTable:[mappableObject tableName]
                      withSpecifiedColumns:nil
                              stipulations:[mappableObject propertyKeysMatchingAttributeColumns]
                                    offset:0
                    andMaxNumberOfRowsToReturn:LABQLITE_WRAPPER_SELECT_LIMIT_NONE
                                 orderedBy:nil
                                     error:error];
    if (error != NULL) {
        if (*error == nil) {
            int i = 0;
            for (i = 0; i < [[mappableObject propertyKeysMatchingAttributeColumns] count]; i++) {
                [(NSObject *)mappableObject setValue:[rowData objectAtIndex:i]
                                              forKey:[[mappableObject valuesMatchingAttributeColumns] objectAtIndex:i]];
            }
            return YES;
        }
    }
    return NO;
}

- (NSUInteger)numberOfRowsInTable:(NSString *)tableName
                            error:(NSError **)error {
    NSString *q = [NSString stringWithFormat:@"SELECT count(*) FROM %@;", tableName];
    NSMutableArray *rows = [[NSMutableArray alloc] initWithArray:[self processStatement:q
                                                                         bindableValues:nil
                                                                          affinityTypes:nil
                                                                            insulatedly:YES
                                                                                  error:error]];
    if (rows != nil) {
        if ([rows count] == 1) {
            id rowCount = [[rows objectAtIndex:0] objectAtIndex:0];
            if (rowCount) {
                NSCharacterSet *numbersOnlyCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
                NSCharacterSet *rowCountCharactersSet = [NSCharacterSet characterSetWithCharactersInString:rowCount];
                if ([numbersOnlyCharacterSet isSupersetOfSet:rowCountCharactersSet]) {
                    return [rowCount integerValue];
                }
            }
        }
    }
    return 0;
}

- (BOOL)insertRow:(id <LabQLiteRowMappable>)row
            error:(NSError **)error {
    NSMutableArray *bindableValues = [row valuesMatchingAttributeColumns];
    NSString *insertionStatement = [_database insertionStatementFromSQLite3RowMappable:row];
    NSArray *affinityTypes = [row columnTypesForAttributeColumns];
    BOOL processingSucceeded = [self processStatement:insertionStatement
                                       bindableValues:bindableValues
                                        affinityTypes:affinityTypes
                                          insulatedly:YES
                                                error:error];
    return processingSucceeded;
}

- (void)insertRow:(id <LabQLiteRowMappable>)row
  completionBlock:(void(^)(BOOL success, NSError *error))completion {
    NSError *err = nil;
    NSMutableArray *bindableValues = [row valuesMatchingAttributeColumns];
    NSString *insertionStatement = [_database insertionStatementFromSQLite3RowMappable:row];
    NSArray *affinityTypes = [row columnTypesForAttributeColumns];
    BOOL processingSucceeded = [self processStatement:insertionStatement
                                       bindableValues:bindableValues
                                        affinityTypes:affinityTypes
                                          insulatedly:YES
                                                error:&err];
    if (processingSucceeded) {
        completion(YES, err);
        NSLog(@"Error within insertRowCompletionBlock: %@", err);
        return;
    }
    else {
        completion(NO, err);
    }
}

- (BOOL)insertRows:(NSArray *)rows
         intoTable:(NSString *)tableName
             error:(NSError **)error {
    if (rows != nil) {
        NSInteger rowCount = [rows count];
        if (rowCount == 0) return YES;
        else if (rowCount == 1) {
            NSObject *firstObj = [rows firstObject];
            if ([firstObj conformsToProtocol:@protocol(LabQLiteRowMappable)]) {
                id <LabQLiteRowMappable> obj = (id <LabQLiteRowMappable>)firstObj;
                [self insertRow:obj
                          error:error];
            }
            else {
                *error = [NSError errorWithDomain:LabQLiteErrorDomain
                                             code:LabQLiteErrorCollectionContainedNonSQLiteRowObject
                                         userInfo:@{@"errorMessage" : LabQLiteErrorMessageCollectionContainedNonSQLiteRowObject}];
                return NO;
            }
        }
        else {
            if ([self openDatabase:error]) {
                for (id <LabQLiteRowMappable> row in rows) {
                    NSString *insertionStatementFromRow = [_database insertionStatementFromSQLite3RowMappable:row];
                    
                    // Get property values based on property name as string
                    // using KVC
                    
                    NSArray *affinities = [row columnTypesForAttributeColumns];
                    NSArray *values = [row valuesMatchingAttributeColumns];
                    
                    if (![self processStatement:insertionStatementFromRow
                                 bindableValues:values
                                  affinityTypes:affinities
                                    insulatedly:NO
                                          error:error]) {
                        return NO;
                    }
                }                    
                if ([self closeDatabase:error]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (BOOL)insertRows:(NSArray *)rows
         intoTable:(NSString *)tableName
       insulatedly:(BOOL)openingAndClosingOfDatabaseIsAutomatic
             error:(NSError **)error {
    BOOL success = NO;
    if (rows != nil) {
        if ([rows count] == 0) return YES;
        else if ([rows count] == 1) {
            if ([[rows objectAtIndex:0] conformsToProtocol:@protocol(LabQLiteRowMappable)]) {
                [self insertRow:[rows objectAtIndex:0]
                          error:error];
            }
            else {
                *error = [NSError errorWithDomain:LabQLiteErrorDomain
                                             code:LabQLiteErrorCollectionContainedNonSQLiteRowObject
                                         userInfo:@{@"errorMessage" : LabQLiteErrorMessageCollectionContainedNonSQLiteRowObject}];
            }
        }
        else {
            
            // Must open and close database properly in
            // accordance with parametric preference
            BOOL assumedToBeOpen = YES;
            BOOL assumedToBeClosed = YES;
            
            if (openingAndClosingOfDatabaseIsAutomatic) {
                assumedToBeOpen = [self openDatabase:error];
            }
            
            if (assumedToBeOpen) {
                for (id <LabQLiteRowMappable> row in rows) {
                    NSString *insertionStatementFromRow = [_database insertionStatementFromSQLite3RowMappable:row];
                    NSArray *bindableValues = [LabQLiteStipulation valuesForBindingFromStipulations:[row SQLiteStipulationsForMapping]];
                    NSArray *affinities = [LabQLiteStipulation affinitiesForBindingFromStipulations:[row SQLiteStipulationsForMapping]];
                    if (![self processStatement:insertionStatementFromRow
                                 bindableValues:bindableValues
                                  affinityTypes:affinities
                                    insulatedly:NO
                                          error:error]) {
                        return NO;
                    }
                }
            }
            
            if (openingAndClosingOfDatabaseIsAutomatic) {
                assumedToBeClosed = [self closeDatabase:error];
            }
            
            success = assumedToBeClosed;
        }
    }
    return success;
}

- (void)insertRows:(NSArray *)SQLite3Rows
         intoTable:(NSString *)tableName
        completion:(void(^)(BOOL success, NSError *error))completion {
    
    // Prepare error capturing variables
    BOOL insertionSucceeded = YES;
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    NSError *multiError = nil;
    
    // Defensive tactic: if no rows to insert, forego the
    // rest of the algorithm and report success. Do this
    // in the case of nil rows...
    if (SQLite3Rows == nil) {
        completion(insertionSucceeded, nil);
        return;
    }
    // ...and in the case of an empty array.
    else if ([SQLite3Rows count] == 0) {
        completion(insertionSucceeded, nil);
        return;
    }
    // ... if there is just one item to insert, then
    // pass the row to the single insertion method.
    else if ([SQLite3Rows count] == 1) {
        id firstObject = [SQLite3Rows firstObject];
        if ([firstObject conformsToProtocol:@protocol(LabQLiteRowMappable)]) {
            [self insertRow:firstObject completionBlock:completion];
            return;
        }
        // But, if the item in the array is not a
        // proper row, create an error and return.
        else {
            NSError *nonRowMappableError = [NSError errorWithDomain:LabQLiteErrorDomain
                                                               code:LabQLiteErrorCollectionContainedNonSQLiteRowObject
                                                           userInfo:@{@"errorMessage" : LabQLiteErrorMessageCollectionContainedNonSQLiteRowObject}];
            [errors addObject:nonRowMappableError];
            insertionSucceeded = NO;
        }
    }
    // Otherwise, there must be multiple row objects
    // to be inserted... so, first thing's first:
    // open the database.
    else {
        NSError *databaseOpenError;
        BOOL databaseWasOpenedSuccessfully = [self openDatabase:&databaseOpenError];
        if (databaseWasOpenedSuccessfully == FALSE) {
            [errors addObject:databaseOpenError];
        }
        // If all went well with opening the database,
        // the next step is to create a savepoint in case
        // we need to rollback for a failed row insertion.
        else {
            NSError *savePointError;
            id savePointSuccess = [self processStatement:@"BEGIN TRANSACTION"
                                          bindableValues:nil
                                           affinityTypes:nil
                                             insulatedly:NO
                                                   error:&savePointError];
            if (!savePointSuccess) {
                insertionSucceeded = FALSE;
                [errors addObject:savePointError];
            }
            else {
                // For every mappable conformist, attempt
                // to insert it into its table.
                for (id <LabQLiteRowMappable>row in SQLite3Rows) {
                    
                    // Prepare insertion error variable
                    NSError *singleRowInsertionError;
                    
                    // Gather data needed for insertion from delegate methods
                    NSString *insertionStatementFromRow = [_database insertionStatementFromSQLite3RowMappable:row];
                    
                    // ...extract information from stipulations for mapping
                    // on the current row:
                    
                    NSArray *bindableValues;
                    NSArray *affinities;
                    
                    bindableValues = [row valuesMatchingAttributeColumns];
                    affinities = [row columnTypesForAttributeColumns];
                    
                    // Perform insertion without tampering with the
                    // open/close state of the database; that is
                    // handled for us in other parts of this method.
                    id singleRowInsertionSuccess = [self processStatement:insertionStatementFromRow
                                                           bindableValues:bindableValues
                                                            affinityTypes:affinities
                                                              insulatedly:NO
                                                                    error:&singleRowInsertionError];
                    if (singleRowInsertionSuccess == FALSE) {
                        // A row did not insert well... so, we have
                        // to stop the loop and record the error.
                        insertionSucceeded = FALSE;
                        [errors addObject:singleRowInsertionError];
                        break;
                    }
                }
                
                // If everything is a success so far, commit.
                // Otherwise, bypass.
                if (insertionSucceeded) {
                    NSError *commitError;
                    id committed = [self processStatement:@"COMMIT TRANSACTION"
                                           bindableValues:nil
                                            affinityTypes:nil
                                              insulatedly:NO
                                                    error:&commitError];
                    if (!committed) {
                        insertionSucceeded = FALSE;
                        [errors addObject:commitError];
                    }
                }
            }
            NSError *closeError;
            BOOL closed = [self closeDatabase:&closeError];
            if (!closed) {
                [errors addObject:closeError];
                insertionSucceeded = FALSE;
            }
        }
    }
    
    // Lastly, if any errors occurred, aggregate them
    // to be passed back in the completion block.
    if (insertionSucceeded == FALSE) {
        multiError = [NSError errorWithDomain:LabQLiteErrorDomain
                                         code:LabQLiteErrorMultipleErrors
                                     userInfo:@{@"errors" : errors}];
    }
    
    // Execute completion block.
    completion(insertionSucceeded, multiError);
}

- (BOOL)deleteRowsFromTable:(NSString *)tableName
           withStipulations:(NSArray *)stipulations
                      error:(NSError **)error {
    if (tableName == nil) {
        *error = [NSError errorWithDomain:LabQLiteErrorDomain
                                     code:LabQLiteErrorTableNameNotSpecified
                                 userInfo:@{@"errorMessage" : LabQLiteErrorMessageLabQLiteErrorTableNameNotSpecified}];
        return false;
    }
    else {
        NSString *q = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
        q = [self appendStipulations:stipulations toSQLString:q];
        NSArray *bindableValues = [LabQLiteStipulation valuesForBindingFromStipulations:stipulations];
        NSArray *affinities = [LabQLiteStipulation affinitiesForBindingFromStipulations:stipulations];
        if([self processStatement:q
                   bindableValues:bindableValues
                    affinityTypes:affinities
                      insulatedly:YES
                            error:error]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)deleteMappableObject:(id <LabQLiteRowMappable>)mappableObject
                       error:(NSError **)error {
    [self deleteRowsFromTable:[mappableObject tableName]
             withStipulations:[mappableObject SQLiteStipulationsForMapping]
                        error:error];
    if (!*error) {
        return YES;
    }
    return NO;
}

- (BOOL)updateRow:(id <LabQLiteRowMappable>)rowObject
               to:(id <LabQLiteRowMappable>)newRowObject
            where:(NSArray *)stipulations
            error:(NSError **)error {
    NSMutableArray *bindableValues = [NSMutableArray new];
    
    NSString *q = [NSMutableString stringWithFormat:@"UPDATE %@", [rowObject tableName]];
    q = [q stringByAppendingString:@" SET"];
    
    // Construct substring of query that sets all attributes
    // to values corresponding to properties of the new
    // row object
    NSArray *columns = [newRowObject columnNames];
    NSArray *values = [newRowObject valuesMatchingAttributeColumns];
    
    NSUInteger columnsCount = [columns count];
    NSUInteger valuesCount = [values count];
    
    if (columnsCount != valuesCount) {
        *error = [NSError errorWithDomain:LabQLiteErrorDomain
                                     code:LabQLiteErrorColumnsCountDidNotMatchValuesCount
                                 userInfo:@{@"errorMessage" : LabQLiteErrorMessageColumnsCountDidNotMatchValuesCount}];
        return false;
    }
    
    for (NSString *columnName in columns) {
        // Use SQLite parameters and then bind the values
        // later using the low-level method
        q = [q stringByAppendingFormat:@" %@=?", columnName];
        
        NSInteger indexOfColumn = [columns indexOfObject:columnName];
        
        // Append a comma when a serialized stipulation is
        // not the last stipulation
        if (indexOfColumn != columnsCount - 1) {
            q = [q stringByAppendingString:@","];
        }
    }
    
    // We must also prep values to bound for the stipulations
    // for this update query
    [bindableValues addObjectsFromArray:values];
    
    for (LabQLiteStipulation *s in stipulations) {
        [bindableValues addObject:s.value];
    }
    
    // Whew! Finally... all values are in the list to
    // be bound to SQLite parameters in the query
    q = [self appendStipulations:stipulations
                     toSQLString:q];
    
    // Get affinities so that bindables may be bound
    // by the low-level library
    
    NSArray *columnAffinities = [newRowObject columnTypesForAttributeColumns];
    NSArray *stipulationAffinities = [LabQLiteStipulation affinitiesForBindingFromStipulations:stipulations];
    
    NSMutableArray *affinities = [NSMutableArray new];
    [affinities addObjectsFromArray:columnAffinities];
    [affinities addObjectsFromArray:stipulationAffinities];
    
    // Ready to process the update!
    [self processStatement:q
            bindableValues:bindableValues
             affinityTypes:affinities
               insulatedly:YES
                     error:error];
    
    // Return whether or not the update was successful
    if (*error == nil) return YES;
    return NO;
}

#pragma Private Methods
         
- (NSString *)appendStipulations:(NSArray *)stipulations toSQLString:(NSString *)sqlString {
    if (stipulations != nil) {
        for (int i = 0; i < [stipulations count]; i++) {
            
            // Get the stipulation
            LabQLiteStipulation *s = (LabQLiteStipulation *)[stipulations objectAtIndex:i];
            
            // Get the chosen binary operator
            NSString *binaryOperator = s.binaryOperator;
            
            // Get the preceding logical operator
            NSString *precedingLogicalOperator = s.precedingLogicalOperator;
            
            // Get the attribute
            NSString *attribute = s.attribute;
            
            if (i == 0) {
                sqlString = [sqlString stringByAppendingString:@" WHERE"];
            }
            else {
                sqlString = [sqlString stringByAppendingFormat:@" %@", precedingLogicalOperator];
            }
            if ([binaryOperator compare:SQLite3BinaryOperatorLike] == NSOrderedSame) {
                sqlString = [sqlString stringByAppendingFormat:@" %@ %@ ?", attribute, binaryOperator];
            }
            else {
                sqlString = [sqlString stringByAppendingFormat:@" %@%@?", attribute, binaryOperator];
            }
        }
    }
    return sqlString;
}

- (NSString *)appendOffset:(NSUInteger)offset
         toSQLString:(NSString *)sqlString {
    sqlString = [sqlString stringByAppendingFormat:@" OFFSET %lu", (unsigned long)offset];
    return sqlString;
}

- (NSString *)appendRowsLimitation:(NSUInteger)limit
                 toSQLString:(NSString *)sqlString {
    sqlString = [sqlString stringByAppendingFormat:@" LIMIT %lu", (unsigned long)limit];
    return sqlString;
}


@end

