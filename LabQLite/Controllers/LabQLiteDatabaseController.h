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

#import "LabQLiteDatabase.h"
#import "LabQLiteStipulation.h"
#import "LabQLiteRowMappable.h"
#import "LabQLiteRow.h"

@interface LabQLiteDatabaseController : NSObject {
    LabQLiteDatabase *_database;
    NSString *_databasePath;
}



#pragma mark - Low-level methods

/**
 @abstract Asks the database wrapper to open the low-level
 SQLite3 database.
 
 @param error Standard error capturing object.
 
 @return Whether or not the database was opened successfully.
 */
- (BOOL)openDatabase:(NSError **)error;

/**
 @abstract Asks the database wrapper to open the low-level
 SQLite3 database.
 
 @param completion A completion block which denotes whether or
 not the opening of the low-level database was successful. Also
 provides an error if indeed the opening failed.
 */
- (void)openDatabaseWithCompletionBlock:(void (^)(BOOL, NSError *))completion;

/**
 @abstract Asks the database wrapper to close the low-level
 SQLite3 database.
 
 @param error Standard error capturing object.
 
 @return Whether or not the database was closed successfully.
 */
- (BOOL)closeDatabase:(NSError **)error;

/**
 @abstract Asks the database wrapper to close the low-level
 SQLite3 database.
 
 @param completion A completion block which denotes whether or
 not the closing of the low-level database was successful. Also
 provides an error if indeed the closing failed.
 */
- (void)closeDatabaseWithCompletionBlock:(void (^)(BOOL, NSError *))completion;

/**
 @abstract Creates a save point in the sqlite3 database file.
 
 @param savePointName The save point name.
 
 @param error The standard error capturing double indirection
 pointer.
 
 @return Whether or not the save point creation was successful.
 */
- (BOOL)createSavepoint:(NSString *)savePointName
                  error:(NSError **)error;

/**
 @abstract Creates a save point in the sqlite3 database file.
 
 @param completion The completion block to be executed at the
 the end of processing the creation of the save point. The
 completion block BOOL denotes the success of the creation
 of the save point. The NSError captures any errors that may
 have arisen during the creation of the save point.
 */
- (void)createSavepoint:(NSString *)savePointName
             completion:(void (^)(BOOL, NSError *))completion;

/**
 @abstract Executes a "ROLLBACK" statement.
 
 @param error The standard error capturing double indirection
 pointer.
 
 @return Whether the ROLLBACK statement was executed without
 errors.
 */
- (BOOL)rollbackToSavepointWithName:(NSString *)savepointName
                              error:(NSError **)error;

/**
 @abstract Executes a "ROLLBACK" statement.
 
 @param completion The completion block to be executed at the
 the end of processing the ROLLBACK statement. The BOOL denotes
 the success of the rollback. The NSError is simply the standard
 error object.
 */
- (void)rollbackToSavePointWithName:(NSString *)savepointName
                        completion:(void (^)(BOOL, NSError *))completion;

/**
 @abstract Processes an SQL statement. The parameters
   - `bindableValues`
   - `affinityTypes`
   - `openingAndClosingOfDatabaseIsAutomatic`
  are optional.
 
 @param sqlStatement The SQL statement to be processed.
 
 @param bindableValues Any values that should be bound to `?` placeholders
 in the SQL statement.

 @param affinityTypes The column affinity types for any bindable values
 that may have been specified.

 @param openingAndClosingOfDatabaseIsAutomatic Whether this method should
 open and close the low-level database automatically.
 
 @param error The standard error capturing double indirection
 pointer.
 
 @return The results of the processed statement.
 */
- (NSArray *)processStatement:(NSString *)sqlStatement
               bindableValues:(NSArray *)bindableValues
                affinityTypes:(NSArray *)affinityTypes
                  insulatedly:(BOOL)openingAndClosingOfDatabaseIsAutomatic
                        error:(NSError **)error;

/**
 @abstract Processes an SQL statement. The parameters
 - `bindableValues`
 - `affinityTypes`
 - `openingAndClosingOfDatabaseIsAutomatic`
 are optional.
 
 @param sqlStatement The SQL statement to be processed.
 
 @param bindableValues Any values that should be bound to `?` placeholders
 in the SQL statement.
 
 @param affinityTypes The column affinity types for any bindable values
 that may have been specified.
 
 @param openingAndClosingOfDatabaseIsAutomatic Whether this method should
 open and close the low-level database automatically.
 
 @param completion The completion block with paramters for results and
 the standard error object.
 */
- (void)processStatement:(NSString *)sqlStatement
          bindableValues:(NSArray *)bindableValues
           affinityTypes:(NSArray *)affinityTypes
             insulatedly:(BOOL)openingAndClosingOfDatabaseIsAutomatic
              completion:(void (^)(NSArray *, NSError *))completion;



#pragma mark - Singleton Methods

/**
 @abstract Returns a shared LabQLiteDatabaseController object
 which points to a shared low-level sqlite3 database file. The
 controller singleton thus allows for convenient SQLite file
 manipulation from anywhere in the project's code.
 
 @return The shared instance of LabQLiteDatabaseController.
 
 @see +activateSharedControllerWithFileFromLocalBundle:toBeCopiedToAndUsedFromDirectory:assumingNSDocumentDirectoryAsRootPath:overwrite:error:
 */
+ (LabQLiteDatabaseController *)sharedDatabaseController;

/**
 @abstract Activates a global singleton shared instance of an
 LabQLiteDatabaseController with the database at the file path
 specified.
 
 @param filePath The file path to the sqlite3 database file in
 the local bundle.
 
 @param savePath The path (including file name) to which the
 sqlite3 database file retrieved from the main bundle should
 be saved.
 
 @param NSDocumentDirectoryIsRootPath Prepends the savePath with
 the path to the NSDocumentDirectory.
 
 @param overwrite If set to YES, then this method will overwrite
 any file it finds at the savePath. Otherwise, it will not.
 
 @param error The standard error capturing double indirection
 pointer.
 
 @return Whether the activation of the shared database controller
 was indeed successful.
 
 @see initWithFileInFromLocalBundle:toBeCopiedToAndUsedFromDirectory:assumingNSDocumentDirectoryAsRootPath:overwrite:error:
 */
+ (BOOL)activateSharedControllerWithFileFromLocalBundle:(NSString *)filePath
                       toBeCopiedToAndUsedFromDirectory:(NSString *)savePath
                  assumingNSDocumentDirectoryAsRootPath:(BOOL)NSDocumentDirectoryIsRootPath
                                              overwrite:(BOOL)overwrite
                                                  error:(NSError **)error;

/**
 @abstract Activates a global singleton shared instance of an
 LabQLiteDatabaseController with the database at the file path
 specified.
 
 @param filePath The file path to the sqlite3 database file.
 
 @param error The standard error capturing double indirection
 pointer.
 
 @return Whether the activation of the shared database controller
 was indeed successful.
 */
+ (BOOL)activateSharedControllerWithDatabasePath:(NSString *)filePath
                                           error:(NSError **)error;



#pragma mark - Initialization

/**
 @abstract Initializes an LabQLiteDatabaseController and returns it.
 
 @param databasePath The path to the low-level sqlite3 database file.
 
 @param error The standard error capturing double indirection pointer.
 
 @return An initialized LabQLiteDatabaseController object.
 */
- (instancetype)initWithDatabasePath:(NSString *)databasePath
                               error:(NSError **)error;

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
                       error:(NSError **)error;

/**
 @abstract Initializes an LabQLiteDatabaseController and returns it.
 
 DO NOT PUT A TRAILING SLASH AT THE END IN THE path PARAMTER.
 
 @param databasePath The path to the low-level sqlite3 database file.
 
 @param error The standard error capturing double indirection pointer.
 
 @return An initialized LabQLiteDatabaseController object.
 */
- (instancetype)initWithFileInFromMainBundle:(NSString *)fileName
             toBeCopiedToAndUsedFromDirectory:(NSString *)path
        assumingNSDocumentDirectoryAsRootPath:(BOOL)assumedNSDocumentDirectoryAsRootPath
                                    overwrite:(BOOL)overwrite
                                        error:(NSError **)error;

/**
 @abstract Returns the sqlite3 database wrapper object.
 
 @return The sqlite3 database wrapper object.
 */
- (LabQLiteDatabase *)database;

/**
 @abstract Attempts to return all rows from the table with name matching
 table name as LabQLiteRow subclassed objects.
 
 @param tableName name of the table for which to return all rows
 
 @return all rows from the specified table
 */
- (NSMutableArray *)allRows:(NSString *)tableName
         SQLite3RowSubclass:(Class)cls
                      error:(NSError **)error;


/**
 @abstract Retrieves rows from a table with the specified column names,
 stipulations (conditions), offset, limit and ordering attribute.
 
 @discussion The rows retrieved are not of any particular LabQLiteRow
 subclass. They are merely NSArrays.
 
 @param tableName The name of the table from which to extract data.
 
 @param arrayOfAttributeNames The specific column values to return in each
 row returned.
 
 @param stipulations An array of LabQLiteStipulations.
 
 @param offset The number of rows to skip.
 
 @param maxNumberOfRowsToReturn The maximum number of rows to return.
 
 @param orderingAttribute The attribute by which rows are ordered prior
 to retrieval.
 
 @param error The standard error capturing double indirection pointer.
 
 @return An array of arrays where each sub-array represents a row returned
 by the low-level sqlite3 database.
 */
- (NSMutableArray *)rowsFromTable:(NSString *)tableName
             withSpecifiedColumns:(NSArray *)arrayOfAttributeNames
                     stipulations:(NSArray *)stipulations
                           offset:(NSUInteger)offset    
       andMaxNumberOfRowsToReturn:(NSUInteger)maxNumberOfRowsToReturn
                        orderedBy:(NSString *)orderingAttribute
                            error:(NSError **)error;


/**
 @abstract Opens the database, processes SELECT statement, then
 closes the database.
 
 @param tableName The name of the table from which to extract data.
 
 @param LabQLiteRowSubclass The LabQLiteRow subclass type into which
 returned rows should be reconstituted as objects.
 
 @param stipulations An array of LabQLiteStipulations.
 
 @param offset The number of rows to skip.
 
 @param maxNumberOfRowsToReturn The maximum number of rows to return.
 
 @param orderingAttribute The attribute by which rows are ordered prior
 to retrieval.
 
 @param error The standard error capturing double indirection pointer.
 
 @return An array of arrays where each sub-array represents a row returned
 by the low-level sqlite3 database.
 */
- (NSMutableArray *)rowsFromTable:(NSString *)tableName
        asSQLite3RowsWithSubclass:(Class)LabQLiteRowSubclass
                     stipulations:(NSArray *)stipulations
                           offset:(NSUInteger)offset
       andMaxNumberOfRowsToReturn:(NSUInteger)maxNumberOfRowsToReturn
                        orderedBy:(NSString *)orderingAttribute
                            error:(NSError **)error;


/**
 @abstract Populates the provided mappable object with data from its
 corresponding row in the sqlite3 database.
 
 @param mappableObject The LabQLiteRowMappable conforming object which
 should be populated by its corresponding sqlite3 row.
 
 @param error The standard error capturing double
 indirection pointer.
 
 @return Whether the mappable object was populated correctly.
 */
- (BOOL)populateMappableObject:(id <LabQLiteRowMappable>)mappableObject
                                error:(NSError **)error;


/**
 @abstract Returns the number of rows in the table with the
 provided table name (if it exists).
 
 @param tableName The name of the table for which the row
 count should be returned.
 
 @param error The standard error capturing double
 indirection pointer.
 
 @return THe number of rows in the specified table (zero if
 the table does not exist).
 */
- (NSUInteger)numberOfRowsInTable:(NSString *)tableName
                            error:(NSError **)error;

/**
 @abstract Inserts an LabQLiteRowMappable conforming object as
 a row in the sqlite3 database.
 */
- (BOOL)insertRow:(id <LabQLiteRowMappable>)row
            error:(NSError **)error;

- (void)insertRow:(id <LabQLiteRowMappable>)row
  completionBlock:(void(^)(BOOL success, NSError *error))completion;

/** 
 @abstract Inserts an array of LabQLite3Row objects.
 
 @param rows An array of LabQLite3Row objects.
 
 @param tableName The name of the table into which
 the rows will be inserted.
 
 @param error The standard error capturing double
 indirection pointer.

 @return Whether or not the insertion was successful.
 */
- (BOOL)insertRows:(NSArray *)rows
         intoTable:(NSString *)tableName
             error:(NSError **)error;

/**
 @abstract Inserts an array of LabQLite3Row objects.
 
 @param rows An array of LabQLite3Row objects.
 
 @param tableName The name of the table into which
 the rows will be inserted.
 
 @param error The standard error capturing double
 indirection pointer.
 
 @param openingAndClosingOfDatabaseIsAutomatic whether
 or not the database should be opened and closed around
 the insertion of rows
 
 @return Whether or not the insertion was successful.
 */
- (BOOL)insertRows:(NSArray *)rows
         intoTable:(NSString *)tableName
       insulatedly:(BOOL)openingAndClosingOfDatabaseIsAutomatic
             error:(NSError **)error;

/**
 @abstract Inserts an array of LabQLite3Row objects.
 
 @param rows An array of LabQLite3Row objects.
 
 @param tableName The name of the table into which
 the rows will be inserted.
 
 @param error The standard error capturing double
 indirection pointer.
 
 @param completion Completion block which is executed
 at the end of the insertion attempt. The `success`
 BOOL lets you know whether the insertion was indeed
 successful. The `error` parameter is the standard
 double-indirection error capturing object.
 */
- (void)insertRows:(NSArray *)rows
         intoTable:(NSString *)tableName
        completion:(void(^)(BOOL success, NSError *error))completion;

/**
 @abstract Opens the database, processes DELETE statement, then closes the database.

 @param tableName the name of the table from which to delete data
 
 @param logicalComponents an array of SQLite3Stipulations
 
 @return whether or not the deletion was successful
 */
- (BOOL)deleteRowsFromTable:(NSString *)tableName
           withStipulations:(NSArray *)stipulations
                      error:(NSError **)error;

/**
 @abstract Deletes the row corresponding to the
 provided LabQLiteRowMappable conforming object.
 
 @param mappableObject An object which conforms
 to the LabQLiteRowMappable protocol.
 
 @param error The standard error capturing double
 indirection pointer.

 @return Whether or not the deletion was successful.
 */
- (BOOL)deleteMappableObject:(id <LabQLiteRowMappable>)mappableObject
                       error:(NSError **)error;

/**
 @abstract 
 
 @param tableName the name of the table from which to delete data
 
 @param attributeName the attribute whose value is being updated
 
 @param newValue the new value to which the attribute is being set
 
 @return an array of messages from the database (expected 1 confirmation message)
 */
- (BOOL)updateRow:(id <LabQLiteRowMappable>)rowObject
               to:(id <LabQLiteRowMappable>)newRowObject
            where:(NSArray *)stipulations
            error:(NSError **)error;


@end

