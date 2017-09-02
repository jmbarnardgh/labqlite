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
#import "sqlite3.h"

#import "LabQLiteStipulation.h"
#import "LabQLiteRowMappable.h"

@class LabQLiteDatabaseController;



#pragma mark - LabQLite Error Handling

/**
 @abstract LabQLiteDatbase error domain. Ascribed
 to NSErrors which arise due to problems with the
 functions, properties or, otherwise, operations of
 the LabQLiteDatabase class.
 
 @see LabQLiteDatabase
 */
FOUNDATION_EXPORT NSString *const LabQLiteErrorDomain;

typedef enum {
    LabQLiteErrorCollectionContainedNonSQLiteRowObject = 0,
    LabQLiteErrorTableNameNotSpecified,
    LabQLiteErrorBindableValuesCountDidNotMatchColumnAffinityTypesCount,
    LabQLiteErrorAffinityTypeUknown,
    LabQLiteErrorMultipleErrors,
    LabQLiteErrorDatabaseDoesNotExistInBundle,
    LabQLiteErrorDatabasePathPointsToNonDatabase,
    LabQLiteErrorColumnsCountDidNotMatchValuesCount
} LabQLiteError;

FOUNDATION_EXPORT NSString *const LabQLiteErrorMessageCollectionContainedNonSQLiteRowObject;
FOUNDATION_EXPORT NSString *const LabQLiteErrorMessageLabQLiteErrorTableNameNotSpecified;
FOUNDATION_EXPORT NSString *const LabQLiteErrorMessageBindableValuesCountDidNotMatchColumnAffinityTypesCount;
FOUNDATION_EXPORT NSString *const LabQLiteErrorMessageAffinityTypeUknown;
FOUNDATION_EXPORT NSString *const LabQLiteErrorMessageMultipleErrors;
FOUNDATION_EXPORT NSString *const LabQLiteErrorMessageDatabaseDoesNotExistInBundle;
FOUNDATION_EXPORT NSString *const LabQLiteErrorMessageDatabasePathPointsToNonDatabase;
FOUNDATION_EXPORT NSString *const LabQLiteErrorMessageColumnsCountDidNotMatchValuesCount;

#pragma mark - LabQLiteDatabase Class

/**
 @abstract Low-level SQLite3 database wrapper. Handles basic
 database operations such as open, close and processing of
 SQL statements.
 */
@interface LabQLiteDatabase : NSObject

/**
 @abstract Low-level SQLite3 database.
 */
@property (nonatomic) sqlite3  *database;

/**
 @abstract The path to the SQLite3 database file.
 */
@property (nonatomic) NSString *databasePath;

/**
 @abstract Date formatter which formats dates to the format
 that SQLite3 expects.
 */
@property (nonatomic) NSDateFormatter *defaultIODateFormatter;

/**
 @abstract Opens the sqlite3 low-level database.
 
 @param error Standard error-capturing double
 indirection pointer.
 */
- (BOOL)openDatabase:(NSError **)error;

/**
 @abstract Closes the sqlite3 low-level database.
 
 @param error Standard error-capturing double
 indirection pointer.
 */
- (BOOL)closeDatabase:(NSError **)error;

/**
 @abstract Processes an SQL statement using the sqlite3 low-level
 object. Processes any kind of statement.
 
 @param sqlStatement The SQL statement to process.
 
 @param bindableValues Any values to be bound in the SQL statement.
 
 @param columnAffinityTypes Those column affinity types which
 correspond to the bindable values (ordered respectively).
 
 @param shouldOpenDatabase Whether or not to open the sqlite3
 low-level database file.
 
 @param shouldCloseDatabase Whether or not to close the sqlite3
 low-level database file.
 
 @param error Standard error-capturing double
 indirection pointer.
 */
- (NSArray *)processStatement:(NSString *)sqlStatement
               bindableValues:(NSArray *)bindableValues
                affinityTypes:(NSArray *)columnAffinityTypes
                 openDatabase:(BOOL)shouldOpenDatabase
                closeDatabase:(BOOL)shouldCloseDatabase
                        error:(NSError **)error;

/**
 @abstract Processes an SQL statement using the sqlite3 low-level
 object. Processes any kind of statement.
 
 @param sqlStatement The SQL statement to process.
 
 @param shouldAutoOpenAndCloseDatabase Whether or not this
 method should open and close the database around the
 processing of the provided sqlStatement.
 
 @param bindableValues Any values to be bound in the SQL statement.
 
 @param columnAffinityTypes Those column affinity types which
 correspond to the bindable values (ordered respectively).
 
 @param error Standard error-capturing double
 indirection pointer.
 */
- (NSArray *)processStatement:(NSString *)sqlStatement
                  insulatedly:(BOOL)shouldAutoOpenAndCloseDatabase
               bindableValues:(NSArray *)bindableValues
                affinityTypes:(NSArray *)columnAffinityTypes
                        error:(NSError **)error;

/**
 @abstract Overloaded method for processing SQL statements.
 This simple version of procesing statements avoids the
 concepts of values and their bindings.
 
 @param sqlStatement The SQL statement to be processed.
 
 @param shouldAutoOpenAndCloseDatabase Whether or not this
 method should open and close the database around the 
 processing of the provided sqlStatement.
 
 @param error Standard error-capturing double
 indirection pointer.

 @return The results of processing the provided SQL statement.
 */
- (NSArray *)processStatement:(NSString *)sqlStatement
                  insulatedly:(BOOL)shouldAutoOpenAndCloseDatabase
                        error:(NSError **)error;

/**
 @abstract Overloaded method for processing SQL statements.
 This simple version of processing statements avoids
 the concepts of values, bindings and opening/closing the
 low-level database. It is assumed that this statement
 will open and close the database for the implementer.
 
 @param sqlStatement The SQL statement to be processed.
 
 @param error Standard error-capturing double
 indirection pointer.
 
 @note This method opens and closes the low-level database
 internally. There is no need to do this manually. Ensure
 that the datbase is closed prior to executing this method.
 */
- (NSArray *)processStatement:(NSString *)sqlStatement
                        error:(NSError **)error;



/**
 @abstract Basic initialization - initializes a low-level sqlite3
 database found at the provided path.
 
 @param pathToDatabaseFile The path to the low-level sqlite3 database
 file.
 
 @param error Standard error-capturing double
 indirection pointer.
 
 @return A new LabQLiteDatabase object.
 */
- (instancetype)initWithPath:(NSString *)pathToDatabaseFile
                       error:(NSError **)error;

/**
 @abstract Provides the corresponding LabQLiteError error message
 based on the provided error code.
 
 @param errorCode The error code for which the corresponding LabQLiteError
 message string should be returned.
 
 @return The error message corresponding to the provided error code.
 */
+ (NSString *)errorMessageForCode:(int)errorCode;

/**
 @abstract Generates an insertion statement based on the values of
 the members of the provided LabQLiteRowMappable object.
 
 @param rowMappable The LabQLiteRowMappable conforming object from
 which the SQL insertion statement will be generated.
 
 @return The SQL insertion statement based on the members of the
 provided LabQLiteRowMappable object.
 */
- (NSString *)insertionStatementFromSQLite3RowMappable:(id <LabQLiteRowMappable>)rowMappable;


@end

