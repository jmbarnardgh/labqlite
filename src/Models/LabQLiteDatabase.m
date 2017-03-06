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



#import "LabQLiteDatabase.h"



@interface LabQLiteDatabase (SQLStatementHelperMethods)



#pragma mark - SQL Statement Processing Helpers

/**
 @abstract Prepares an sqlite3_stmt with the provided SQL
 string and database.
 
 @discussion The SQL statement string (sqlStatement) is
 used to prepare an sqlite3_stmt. Upon completion of said
 preparation, the prepared statement is assigned to the
 provided memory address (address). This entire process
 requires the instance member database to assist in
 the processing.
 
 @param sqlStatement The string form of the SQL statement
 to be processed.
 
 @param address The memory address of an sqlite3_stmt
 into which the prepared sqlite3_stmt struct will go.
 
 @return the low level result code from the preparing
 of the low-level sqlite3_stmt
 */
- (int)resultCodeFromPreparingStatement:(NSString *)sqlStatement
       addressOfLowLevelSQLiteStatement:(sqlite3_stmt **)address;

/**
 @abstract Binds the provided values according to the
 provided affinity types to the provided low-level
 sqlite3_stmt.
 
 @discussion Binds the values provided in NSString, NSDate
 or NSNumber form to the provided lol-level sqlite3_stmt
 object using the provided affinity types. The appropriate
 sqlite3_bind method is used based on the provided affinity
 type. The provided affinity types array must be of the same
 length as the provided bindableValues array. Index i of
 bindable values must have a value which is bindable according
 to the affinity type provided at index i of affinityTypes.
 
 @param bindableVaues The values in NSString, NSNumber or NSDate
 form to be bound to the provided low-level sqlite3_stmt.
 
 @param affinityTypes The SQLite affinity types according to
 which the bindableValues should be bound, respectively.
 
 @param lowLevelStatement The low-level sqlite3_stmt to which
 the provided bindabble values should be bound.
 
 @param error Standard error-capturing double
 indirection pointer.
 
 @return Whether or not the provided values were successfully
 bound to the provided low-level statement. 
 
 @note The empty array for both bindableValues and affinityTypes
 is treated as an automatic success.
 */
- (BOOL)bindValues:(NSArray *)bindableValues
 withAffinityTypes:(NSArray *)affinityTypes
       toStatement:(sqlite3_stmt *)lowLevelStatement
             error:(NSError **)error;

/**
 @abstract Gets the results for stepping through the prepared
 low-level sqlite3_stmt.
 
 @discussion This method steps through the low-level sqlite3_stmt
 provided as a parameter. At each step, if a row is found, the
 method will aggregate the values of said row into an NSMutableArray
 (considered to be a row). The end result of this method, if
 successful, will be to return an NSArray of NSArrays where
 sub-arrays are rows that have been deserialized. The values of
 deserialized row attributes are likewise wrapped as NSObject
 subclasses:
   - NSString
   - NSNumber
   - NSDate
   - NSData
 
 @param lowLevelSQLStatement The low-level sqlit3_stmt through
 which this method should step.
 
 @param error Standard error-capturing double
 indirection pointer.
 
 @return The results from stepping through the low-level
 sqlite3_stmt that was provided.
 */
- (NSArray *)resultsFromPreparedStatement:(sqlite3_stmt *)lowLevelSQLStatement
                                    error:(NSError **)error;

@end



#pragma mark - LabQLite Error Handling

NSString *const LabQLiteErrorDomain = @"LabQLiteErrorDomain";

NSString *const LabQLiteErrorMessageCollectionContainedNonSQLiteRowObject = @"LabQLite found non-SQLiteRow object in collection that should have contained only SQLiteRow objects.";
NSString *const LabQLiteErrorMessageLabQLiteErrorTableNameNotSpecified = @"Could not process SQL statement because a table name was not provided.";
NSString *const LabQLiteErrorMessageBindableValuesCountDidNotMatchColumnAffinityTypesCount = @"Bindable values array count did not match affinity types count during statement processing.";
NSString *const LabQLiteErrorMessageAffinityTypeUknown = @"Column affinity type provided is unknown to LabQLite.";
NSString *const LabQLiteErrorMessageMultipleErrors = @"Multiple database errors encountered.";
NSString *const LabQLiteErrorMessageDatabaseDoesNotExistInBundle = @"No SQLite database found at bundle path specified with which to create LabQLiteDatabase object.";
NSString *const LabQLiteErrorMessageDatabasePathPointsToNonDatabase = @"Cannot perform operation because the file at the database path is not a database.";
NSString *const LabQLiteErrorMessageColumnsCountDidNotMatchValuesCount = @"The number of columns and the number of values did not match.";

@implementation LabQLiteDatabase



#pragma mark - Initialization

- (instancetype)initWithPath:(NSString *)pathToDatabaseFile error:(NSError **)error {
    self = [super init];
    if (self) {
        _databasePath = [[NSString alloc] initWithString:pathToDatabaseFile];
        if ([self openDatabase:error]) {
            if ([self closeDatabase:error]) {
                self.defaultIODateFormatter = [[NSDateFormatter alloc] init];
                [self.defaultIODateFormatter setDateFormat:@"yyyy-MM-DD HH:mm:ss ZZZZ"];
                NSError *e;
                NSArray *t = [self processStatement:@"SELECT * FROM sqlite_master" insulatedly:YES error:&e];
                if (t) {
                    return self;
                }
            }
        }
    }
    return nil;
}



#pragma mark - Basic Low-Level Operations

- (BOOL)openDatabase:(NSError **)error {
    int errorCode = sqlite3_open([_databasePath UTF8String], &_database);
    if (errorCode != SQLITE_OK) {
        if (error != NULL) {
            *error = [[NSError alloc] initWithDomain:SQLITE3_LOW_LEVEL_ERROR_DOMAIN
                                                code:errorCode
                                            userInfo:@{@"errorMessage" : [LabQLiteDatabase errorMessageForCode:errorCode]}];
        }
        return FALSE;
    }
    return TRUE;
}

- (BOOL)closeDatabase:(NSError **)error {
    NSArray *t = [self processStatement:@"SELECT * FROM sqlite_master"
                            insulatedly:NO
                                  error:error];
    if (t == nil) {
        return FALSE;
    }
    int errorCode = sqlite3_close(_database);
    if (errorCode != SQLITE_OK) {
        if (error != NULL) {
            *error = [[NSError alloc] initWithDomain:SQLITE3_LOW_LEVEL_ERROR_DOMAIN
                                                code:errorCode
                                            userInfo:@{@"errorMessage" : [LabQLiteDatabase errorMessageForCode:errorCode]}];
        }
        return FALSE;
    }
    return TRUE;
}

#pragma mark - SQL Statement Processing Helpers

- (int)resultCodeFromPreparingStatement:(NSString *)sqlStatement
       addressOfLowLevelSQLiteStatement:(sqlite3_stmt **)address {
   const char *statementToBeProcessed = [sqlStatement UTF8String];
   int code = sqlite3_prepare_v2(_database,
                                 statementToBeProcessed,
                                 -1,
                                 address,
                                 NULL);
    return code;
}

- (BOOL)bindValues:(NSArray *)bindableValues
 withAffinityTypes:(NSArray *)affinityTypes
       toStatement:(sqlite3_stmt *)lowLevelStatement
             error:(NSError **)error {
    for (int i = 0; i < [affinityTypes count]; i++) {
        id bindableValue = [bindableValues objectAtIndex:i];
        NSNumber *columnAffinityType  = (NSNumber *)[affinityTypes objectAtIndex:i];
    
        if (bindableValue == [NSNull null]) {
            sqlite3_bind_null(lowLevelStatement, (i + 1));
        }
        else if ([columnAffinityType isEqual:SQLITE_AFFINITY_TYPE_INTEGER]) {
            bindableValue = (NSNumber *)bindableValue;
            int bindable = [bindableValue intValue];
            sqlite3_bind_int(lowLevelStatement,    (i + 1), bindable);
        }
        else if ([columnAffinityType isEqual:SQLITE_AFFINITY_TYPE_TEXT]) {
            NSString *bindable = (NSString *)bindableValue;
            sqlite3_bind_text(lowLevelStatement,   (i + 1), [bindable UTF8String], -1, NULL);
        }
        else if ([columnAffinityType isEqual:SQLITE_AFFINITY_TYPE_NONE]) {
            NSData *bindable = (NSData *)bindableValue;
            sqlite3_bind_blob(lowLevelStatement,   (i + 1), [bindable bytes], -1, NULL);
        }
        else if ([columnAffinityType isEqual:SQLITE_AFFINITY_TYPE_REAL]) {
            double bindable = [bindableValue doubleValue];
            sqlite3_bind_double(lowLevelStatement, (i + 1), bindable);
        }
        else if ([columnAffinityType isEqual:SQLITE_AFFINITY_TYPE_NUMERIC]) {
            NSString *bindable = (NSString *)bindableValue;
            sqlite3_bind_text(lowLevelStatement,   (i + 1), [bindable UTF8String], -1, NULL);
        }
        else {
            NSString *domain = LabQLiteErrorDomain;
            int code = LabQLiteErrorAffinityTypeUknown;
            NSString *errorMessage = LabQLiteErrorMessageAffinityTypeUknown;
            NSString *affinityType = [NSString stringWithFormat:@"%@", columnAffinityType];
            NSDictionary *errorDetails = @{@"affinityType" : affinityType};
            NSDictionary *userInfo = @{@"errorMessage" : errorMessage,
                                       @"errorDetails" : errorDetails};
            
            *error = [NSError errorWithDomain:domain
                                         code:code
                                     userInfo:userInfo];
            return NO;
        }
    }
    return YES;
}

- (NSArray *)resultsFromPreparedStatement:(sqlite3_stmt *)lowLevelSQLStatement
                                    error:(NSError **)error {
    
    // Prepare an array to receive rows of data
    NSMutableArray *arrayOfRows = [[NSMutableArray alloc] init];
    
    // Prepare to step through the low-level SQLite statement
    int stepValue = 0;
    stepValue = sqlite3_step(lowLevelSQLStatement);
    
    // Continuously step through the low-level SQLite statement
    // until done or until an error occurs
    while (stepValue == SQLITE_ROW) {
        int m = sqlite3_column_count(lowLevelSQLStatement);
        NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:m];
        for (int i = 0; i < m; i++) {
            const unsigned char *value = sqlite3_column_text(lowLevelSQLStatement, i);
            const char *declType = sqlite3_column_decltype(lowLevelSQLStatement, i);
            
            NSString *declaredType = [NSString stringWithFormat:@"%s", declType];
            
            // Determine affinity type...
            
            // Determine if TEXT affinity exists..
            NSRange rangeOfTEXTAffinitySubstringCHAR = [declaredType rangeOfString:@"CHAR" options:NSCaseInsensitiveSearch];
            NSRange rangeOfTEXTAffinitySubstringCLOB = [declaredType rangeOfString:@"CLOB" options:NSCaseInsensitiveSearch];
            NSRange rangeOfTEXTAffinitySubstringTEXT = [declaredType rangeOfString:@"TEXT" options:NSCaseInsensitiveSearch];
            
            BOOL isTEXTBecauseOfCHAR = rangeOfTEXTAffinitySubstringCHAR.location != NSNotFound;
            BOOL isTEXTBecauseOfCLOB = rangeOfTEXTAffinitySubstringCLOB.location != NSNotFound;
            BOOL isTEXTBecauseOfTEXT = rangeOfTEXTAffinitySubstringTEXT.location != NSNotFound;
            
            // Determine if INTEGER affinity exists
            NSRange rangeOfINTAffinitySubstringINT = [declaredType rangeOfString:@"INT" options:NSCaseInsensitiveSearch];
            
            BOOL isINTBecauseOfINT = rangeOfINTAffinitySubstringINT.location != NSNotFound;
            
            // Determine if REAL affinity exists
            NSRange rangeOfREALAffinitySubstringREAL = [declaredType rangeOfString:@"REAL" options:NSCaseInsensitiveSearch];
            NSRange rangeOfREALAffinitySubstringFLOA = [declaredType rangeOfString:@"FLOA" options:NSCaseInsensitiveSearch];
            NSRange rangeOfREALAffinitySubstringDOUB = [declaredType rangeOfString:@"DOUB" options:NSCaseInsensitiveSearch];
            
            BOOL isREALBecauseOfREAL = rangeOfREALAffinitySubstringREAL.location != NSNotFound;
            BOOL isREALBecauseOfFLOA = rangeOfREALAffinitySubstringFLOA.location != NSNotFound;
            BOOL isREALBecauseOfDOUB = rangeOfREALAffinitySubstringDOUB.location != NSNotFound;
            
            // Determine of NONE affinity exists
            NSRange rangeOfNONEAffinitySubstringBLOB = [declaredType rangeOfString:@"BLOB" options:NSCaseInsensitiveSearch];
            
            BOOL isNONEBecauseofBLOB = rangeOfNONEAffinitySubstringBLOB.location != NSNotFound;
            
            
            // Get the string value, regardless...
            NSString *objCValueWrapper = [NSString stringWithFormat:@"%s", value];
            
            // Determine whether is NULL value.
            BOOL isNULL = [objCValueWrapper isEqualToString:@"(null)"];
            
            // Conduct tests to see which affinity it is.
            // Then handle appropriately.
            
            // If NULL, use NSNull to represent
            // NULL in the row array.
            if (isNULL) {
                [row addObject:[NSNull null]];
            }
            else if (isTEXTBecauseOfCHAR || isTEXTBecauseOfCLOB || isTEXTBecauseOfTEXT) {
                [row addObject:objCValueWrapper];
            }
            else if (isINTBecauseOfINT) {
                long long longValue = [objCValueWrapper longLongValue];
                NSNumber *integerNumber = [NSNumber numberWithLongLong:longValue];
                [row addObject:integerNumber];
            }
            else if (isREALBecauseOfDOUB || isREALBecauseOfFLOA || isREALBecauseOfREAL) {
                double decimalValue = [objCValueWrapper doubleValue];
                NSNumber *decimalNumber = [NSNumber numberWithDouble:decimalValue];
                [row addObject:decimalNumber];
            }
            else if (isNONEBecauseofBLOB) {
                NSData *dataValue = [objCValueWrapper dataUsingEncoding:NSUTF8StringEncoding];
                [row addObject:dataValue];
            }
            else { // is NUMERIC
                [row addObject:objCValueWrapper];
            }
        }
        [arrayOfRows addObject:row];
        stepValue = sqlite3_step(lowLevelSQLStatement);
    }
    
    // Handle error encounter
    if (stepValue != SQLITE_DONE) {
        NSString *lowLevelErrorMessage = [NSString stringWithUTF8String:sqlite3_errmsg(_database)];
        NSString *domain = SQLITE3_LOW_LEVEL_ERROR_DOMAIN;
        int code = stepValue;
        NSString *errorMessage = [LabQLiteDatabase errorMessageForCode:stepValue];
        NSDictionary *errorDetails = @{@"lowLevelErrorMessage" : lowLevelErrorMessage};
        NSDictionary *userInfo = @{@"errorMessage" : errorMessage,
                                   @"errorDetails" : errorDetails};
        
        *error = [NSError errorWithDomain:domain
                                     code:code
                                 userInfo:userInfo];
        return nil;
    }
    NSArray *results = [NSArray arrayWithArray:arrayOfRows];
    return results;
}


#pragma mark - SQL Statement Processing

- (NSArray *)processStatement:(NSString *)sqlStatement
               bindableValues:(NSArray *)bindableValues
                affinityTypes:(NSArray *)columnAffinityTypes
                 openDatabase:(BOOL)shouldOpenDatabase
                closeDatabase:(BOOL)shouldCloseDatabase
                        error:(NSError **)error {
    
    // Attempt to open the database.
    BOOL databaseWasOpened = NO;
    if (shouldOpenDatabase) {
        databaseWasOpened = [self openDatabase:error];
    }
    
    // If database failed to open, return nil.
    BOOL shouldPrepareStatement = databaseWasOpened || !shouldOpenDatabase;
    if (!shouldPrepareStatement) {
        return nil;
    }
    
    // Otherwise, attempt to prepare the SQL statement.
    sqlite3_stmt *lowLevelSQLStatement;
    int resultCode = [self resultCodeFromPreparingStatement:sqlStatement
                           addressOfLowLevelSQLiteStatement:&lowLevelSQLStatement];
    
    // If a non-"ok" result was returned, capture the low-level
    // error in parametrically provided NSError address and return nil.
    if (resultCode != SQLITE_OK) {
        NSString *errorMessage = [LabQLiteDatabase errorMessageForCode:resultCode];
        NSString *errorDetails = [NSString stringWithFormat:@"SQL statement: %@", sqlStatement];
        NSDictionary *userInfo = @{@"errorMessage" : errorMessage,
                                   @"errorDetails"     : errorDetails};
        if (error != nil) {
            *error = [NSError errorWithDomain:SQLITE3_LOW_LEVEL_ERROR_DOMAIN
                                         code:resultCode
                                     userInfo:userInfo];
        }
        return nil;
    }
    
    // Determine whether or not there are values to be binded
    // to the SQL statement.
    BOOL shouldAttemptToBindValues = bindableValues != nil       &&
                                     columnAffinityTypes != nil;
    
    BOOL didBindValuesToStatement = NO;
    // If values should be bound, attempt to bind them.
    if (shouldAttemptToBindValues) {
        didBindValuesToStatement = [self bindValues:bindableValues
                                  withAffinityTypes:columnAffinityTypes
                                        toStatement:lowLevelSQLStatement
                                              error:error];
    }
    
    // If should have attempted to bind values yet
    // was unable to do so, then return nil.
    if (shouldAttemptToBindValues && !didBindValuesToStatement) {
        return nil;
    }
    
    // Otherwise, should have bound values and was
    // sucessful, or should not have bound values.
    
    // Step through the prepared statement to obtain the
    // results yielded by the database after executing.
    NSArray *results = [self resultsFromPreparedStatement:lowLevelSQLStatement
                                                    error:error];
    
    // If the step-through failed, then simply return nil.
    if (!results) {
        return nil;
    }
    
    // Otherwise, finalize the low level SQL statement
    // after a successful stepping through of the low-level
    // SQL statement.
    sqlite3_finalize(lowLevelSQLStatement);
    
    // If should close database, then attempt to do so.
    // Otherwise, skip it.
    BOOL didCloseDatabase = NO;
    if (shouldCloseDatabase) {
        didCloseDatabase = [self closeDatabase:error];
    }
    
    // If should have closed database yet was unsuccessful,
    // then return nil.
    if (shouldCloseDatabase && !didCloseDatabase) {
        return nil;
    }
    
    // Otherwise, statement should have processed successfully.
    // Return the results.
    return results;
}

- (NSArray *)processStatement:(NSString *)sqlStatement
                  insulatedly:(BOOL)shouldAutoOpenAndCloseDatabase
               bindableValues:(NSArray *)bindableValues
                affinityTypes:(NSArray *)columnAffinityTypes
                        error:(NSError **)error {
    return [self processStatement:sqlStatement
                   bindableValues:bindableValues
                    affinityTypes:columnAffinityTypes
                     openDatabase:shouldAutoOpenAndCloseDatabase
                    closeDatabase:shouldAutoOpenAndCloseDatabase
                            error:error];
}

- (NSArray *)processStatement:(NSString *)sqlStatement
                  insulatedly:(BOOL)shouldAutoOpenAndCloseDatabase
                        error:(NSError **)error {
    return [self processStatement:sqlStatement
                   bindableValues:nil
                    affinityTypes:nil
                     openDatabase:shouldAutoOpenAndCloseDatabase
                    closeDatabase:shouldAutoOpenAndCloseDatabase
                            error:error];
}


- (NSArray *)processStatement:(NSString *)sqlStatement
                        error:(NSError **)error {
    return [self processStatement:sqlStatement
                   bindableValues:nil
                    affinityTypes:nil
                     openDatabase:YES
                    closeDatabase:YES
                            error:error];
}

- (NSString *)description {
    NSMutableString *desc = [NSMutableString stringWithString:[[self class] description]];
    //    [desc appendFormat:@",\n low level C object: %c", _database];
    [desc appendFormat:@",\n database path: %@", _databasePath];
    return desc;
}

+ (NSString *)errorMessageForCode:(int)errorCode {
    return [[LabQLiteConstants SQLITE_LOW_LVL_MSGS_ARRAY] objectAtIndex:errorCode];
}

- (NSString *)insertionStatementFromSQLite3RowMappable:(id <LabQLiteRowMappable>)rowMappable {
    NSMutableString *q = [NSMutableString stringWithFormat:@"INSERT OR ROLLBACK INTO %@ VALUES (", [rowMappable tableName]];
    NSMutableArray *valuesMatched = [rowMappable valuesMatchingAttributeColumns];
    NSInteger numValues = [valuesMatched count];
    for (int i = 0; i < numValues; i++) {
        
        id insertable;
        id rowMappableObject = [valuesMatched objectAtIndex:i];
        
        if (rowMappableObject == [NSNull null]) {
            insertable = @"NULL"; //since we are building the query string, use @"NULL"
        }
        else if ([rowMappableObject isKindOfClass:[NSString class]]) {
            insertable = rowMappableObject;
        }
        else if ([rowMappableObject isKindOfClass:[NSNumber class]]) {
            insertable = [rowMappableObject stringValue];
        }
        
        [q appendFormat:@"?"];
        if (i < numValues - 1) {
            [q appendString:@", "];
        }
        if (i == (numValues - 1)) {
            [q appendString:@")"];
        }
    }
    return q;
}


@end

