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
#import "LabQLiteRowMappable.h"
#import "LabQLiteDatabaseController.h"



/**
 The fundamental superclass of all classes 
 corresponding to tables or view in an SQLite
 table or (SQL) view. Classes which inherit
 from LabQLiteRow will be afforded basic CRUD
 functionality (including convenience overloaded
 methods) in accordance with the
 Active Record pattern.
 
 This class is not intended to be the
 exact, direct class of an object in normal
 application programming. As such, in regular
 use of CRUD methods, developers will
 experience warnings or errors when attempting
 to call a CRUD method on an object whose
 class (and not superclass) is merely LabQLiteRow
 
 LabQLiteRow is intended to be a superclass
 of SQL-table- or SQL-view-representative classes.
 */
@interface LabQLiteRow : NSObject <LabQLiteRowMappable> {
    NSString *_tableName;
    NSArray *_columnNames;
    NSArray *_SQLiteStipulationsForMapping;
    NSArray *_propertyKeysMatchingAttributeColumns;
    NSArray *_valuesCorrespondingToPropertyKeys;
    NSArray *_columnTypesForAttributeColumns;
}



#pragma mark - Error Handling

/**
 Error domain identifier (NSString) for LabQLiteRow
 */
FOUNDATION_EXPORT NSString *const LabQLiteRowErrorDomain;

/**
 Error codes for LabQLiteRow errors
 */
typedef enum {
    
    /** 
     Error code for when objects in a collection are
     not all of the same class, albeit said objects
     should be of the same class
     */
    LabQLiteRowErrorObjectsInCollectionNotAllSameClass = 0,
    
    /**
     Error code for when an active record method is
     called on
     */
    LabQLiteRowErrorCRUDMethodCalledOnRawSQLiteRowObject,
    
    /**
     Error code for when a key or property is specified
     on an object but the object has no such key or property
     */
    LabQLiteRowErrorObjectPropertyOrKeyNotFound
    
} LabQLiteRowError;

/**
 LabQLiteRow error message corresponding with error
 code SQLiteRowErrorObjectsInCollectionNotAllSameClass
 */
FOUNDATION_EXPORT NSString *const LabQLiteRowErrorMessageObjectsInCollectionNotAllSameClass;

/**
 LabQLiteRow Error message corresponding with error
 code LabQLiteRowErrorCRUDMethodCalledOnRawSQLiteRowObject
 */
FOUNDATION_EXPORT NSString *const LabQLiteRowErrorMessageCRUDMethodCalledOnRawSQLiteRowObject;

/**
 LabQLiteRow Error message corresponding with error
 code LabQLiteRowErrorCRUDMethodCalledOnRawSQLiteRowObject
 */
FOUNDATION_EXPORT NSString *const LabQLiteRowErrorMessageObjectPropertyOrKeyNotFound;


#pragma mark - Active Record pattern methods (CRUD methods)

#pragma mark - INSERT (Create)

/**
 @abstract Inserts self into the currently setup shared
 database controller
 
 @discussion Attempts to insert self, an  assumed subclass
 of LabQLiteRow, into the SQLite3 database represented by
 the assumed setup shared database controller. That is,
 this method is designed to operate under the assumption
 that a subclass of LabQLiteRow is calling this method,
 not an object whose (direct) class is LabQLiteRow.
 
 @param error the standard NSError double
 indirection pointer which will point to any
 error that might arise during the insertion
 attempt
 
 @return whether or not the insertion was successful
 
 @see LabQLiteDatabaseController
 
 @see [LabQLiteDatabaseController sharedDatabaseController]
 
 @see -insertRow: on LabQLiteDatabaseController
 */
- (BOOL)insertSelf:(NSError **)error;

/**
 @abstract Attempts to insert self into the currently
 setup shared database controller; at the end of attempted
 insertion, the supplied completion block will be executed
 
 @discussion See `-insertSelf:` for basic description of
 assumptions and flow of insertion
 
 @param completion a block which executes at the end
 of attempted insertion and reports whether insertion
 was successful; if failed, the error object will not
 be nil but will contain errors encountered as a result
 of the failed insertion attempt
 
 @see LabQLiteDatabaseController
 
 @see [LabQLiteDatabaseController sharedDatabaseController]
 
 @see -insertRow: on LabQLiteDatabaseController
 
 @see -insertSelf:
 */
- (void)insertSelfWithCompletionBlock:(void(^)(BOOL success, NSError *error))completion;

/**
 @abstract Attempts to insert an array of objects, all
 of the same class type, into the shared database controller
 
 @discussion Attempts to insert several objects, all of 
 the same class type (which is assumed to subclass
 LabQLiteRow), into the shared database controller.
 This method carries out the insertion in a piece-wise
 approach. That is, if an object fails to be inserted,
 other objects that can successfully be inserted will
 be inserted.
 
 @param objects the objects to be inserted into the
 SQLite3 database represented by objects
 
 @param error the error pointer which will point to
 the error object of failed insertions; nil if no errors
 
 @return whether or not all insertions were successful
 
 @see LabQLiteDatabaseController
 
 @see [LabQLiteDatabaseController sharedDatabaseController]
 
 @see -insertRows:intoTable:error: on LabQLiteDatabaseController
 */
+ (BOOL)insertObjects:(NSArray *)objects
                error:(NSError **)error;

/**
 @abstract Attempts to insert an array of objects, all
 of the same class type, into the shared database controller;
 at the end of the insertion attempt, the provided
 completion block will be executed
 
 @discussion See `-insertObjects:error:` for basic
 description of assumptions and flow of insertion
 
 @param completion a block which executes at the end
 of attempted insertion and reports whether insertion
 was successful; if failed, the error object will not
 be nil but will contain errors encountered as a result
 of the failed insertion attempt
 
 @return whether or not all insertions were successful
 
 @see LabQLiteDatabaseController
 
 @see [LabQLiteDatabaseController sharedDatabaseController]
 
 @see -insertRows:intoTable:error: on LabQLiteDatabaseController
 
 @see -insertObjects:error:
 */
+ (void)insertObjects:(NSArray *)objects
      completionBlock:(void(^)(BOOL success, NSError *error))completion;



#pragma mark - SELECT (Retrieve)

/**
 @abstract Attempts to retrieve a limited number
 of rows (as LabQLiteRow subclassed objects) from
 the offset (index) specified
 
 @discussion This method calls SELECT on the 
 assumed-to-be-setup shared LabQLiteDatabaseController.
 The table name comes from a new, temporary object
 initialized according to the class on which this
 class method was called (which should be a subclass
 of LabQLiteRow and not the LabQLiteRow class itself).
 If the SELECT is successful, the returned result is
 an NSArray of initialized objects of said class. The
 NSArray count is at most equal to the limit parameter
 value. The offset parameter corresponds to the usual
 OFFSET in SQL statements. An array of stipulations
 specifies conditions which must be met for a
 particular row to be returned from the SELECT
 statement (and thus returned as an object by this
 method).
 
 @param offset the SQL OFFSET from which to start
 when returning rows from the SELECT statement
 
 @param maxNumberOfObjectsToReturn the SQL LIMIT
 of rows to be returned (and thus objects to
 be returned by this method)
 
 @param sortProperty the SQL table column (and thus
 class object property) by which to sort the 
 returned rows (sorting done at the SQLite3 level)
 
 @param stipulations an array of conditions which
 rows must meet to be returned by the SELECT
 statement (and thus be returned in object form
 by this method)
 
 @param error the error pointer which will point to
 the error object of failed insertions; nil if no errors
 
 @return the objects matching rows returned by the
 SELECT statement with the provided offset, limit
 sort property and conditions (stipulations)
 
 @see LabQLiteDatabaseController
 
 @see +sharedDatabaseController on LabQLiteDatabaseController
 
 @see -rowsFromTable:asSQLite3RowsWithSubclass:stipulations:offset:andMaxNumberOfRowsToReturn:orderedBy:
 on LabQLiteDatabaseController
 error:error];
 */
+ (NSArray *)objectsAtOffset:(NSUInteger)offset
                       limit:(NSUInteger)maxNumberOfObjectsToReturn
                    orderdBy:(NSString *)sortProperty
            withStipulations:(NSArray *)stipulations
                       error:(NSError **)error;

/**
 @abstract Attempts to retrieve a limited number
 of rows (as LabQLiteRow subclassed objects) from
 the offset (index) specified
 
 @discussion This method calls SELECT on the
 assumed-to-be-setup shared LabQLiteDatabaseController.
 The table name comes from a new, temporary object
 initialized according to the class on which this
 class method was called (which should be a subclass
 of LabQLiteRow and not the LabQLiteRow class itself).
 If the SELECT is successful, the returned result is
 an NSArray of initialized objects of said class. The
 NSArray count is at most equal to the limit parameter
 value. The offset parameter corresponds to the usual
 OFFSET in SQL statements. An array of stipulations
 specifies conditions which must be met for a
 particular row to be returned from the SELECT
 statement (and thus returned as an object by this
 method).
 
 @param offset the SQL OFFSET from which to start
 when returning rows from the SELECT statement
 
 @param maxNumberOfObjectsToReturn the SQL LIMIT
 of rows to be returned (and thus objects to
 be returned by this method)
 
 @param sortProperty the SQL table column (and thus
 class object property) by which to sort the
 returned rows (sorting done at the SQLite3 level)
 
 @param stipulations an array of conditions which
 rows must meet to be returned by the SELECT
 statement (and thus be returned in object form
 by this method)
 
 @param completion a block which is executed at the
 end of the attempted objects' retrieval; successful
 retrieval will execute the block providing the
 results in the `results` NSArray parameter of the
 block; failure should provide a non-nil NSError
 in the error parameter of the block
 
 @see LabQLiteDatabaseController
 
 @see +sharedDatabaseController on LabQLiteDatabaseController
 
 @see -rowsFromTable:asSQLite3RowsWithSubclass:stipulations:offset:andMaxNumberOfRowsToReturn:orderedBy:
 on LabQLiteDatabaseController
 error:error];
 */
+ (void)objectsAtOffset:(NSUInteger)offset
        numberOfObjects:(NSUInteger)maxNumberOfObjectsToReturn
         sortedByColumn:(NSString *)columnName
       withStipulations:(NSArray *)stipulations
        completionBlock:(void(^)(NSArray *results, NSError *error))completion;

/**
 @abstract Attempts to return all rows corresponding
 to the table associated with the class calling this
 class method (assumed to be a subclass of LabQLiteRow).
 
 @discussion A temporary object is initialized with
 the class calling this method; the table name is then
 extracted from said temporary object. After the 
 LabQLiteDatabaseController calls SELECT * on said 
 table. The results are returned in an NSArray.
 
 @param error the error pointer which will point to
 the error object of failed insertions; nil if no errors
 
 @return all possible rows from the table associated
 with the class calling this class method (provided
 that the memory on the iOS device is sufficient)
 */
+ (NSArray *)allObjects:(NSError **)error;

/**
 @abstract Attempts to return all rows corresponding
 to the table associated with the class calling this
 class method (assumed to be a subclass of LabQLiteRow).
 
 @discussion A temporary object is initialized with
 the class calling this method; the table name is then
 extracted from said temporary object. After the
 LabQLiteDatabaseController calls SELECT * on said
 table. The results are returned in an NSArray.
 
 @param completion a completion block which handles
 returning results and/or an error depending on the
 success of the SELECT statement; the completion
 block is executed at the end of this method
 */
+ (void)allObjectsWithCompletionBlock:(void(^)(NSArray *results, NSError *error))completion;

/**
 @abstract Attempts to return all rows corresponding
 to the table associated with the class calling this
 class method (assumed to be a subclass of LabQLiteRow);
 rows sorted according to the property provided
 
 @discussion A temporary object is initialized with
 the class calling this method; the table name is then
 extracted from said temporary object. After the
 LabQLiteDatabaseController calls SELECT * on said
 table. The results are returned in an NSArray ordered
 according to the sortProperty (aka the column name).
 
 @param sortProperty the property of the class by
 which to sort the returned results (sorting is done
 at the SQLite3 level)
 
 @param error the error pointer which will point to
 the error object of failed insertions; nil if no errors
 
 @return all possible rows from the table associated
 with the class calling this class method (provided
 that the memory on the iOS device is sufficient)
 */
+ (NSArray *)allObjectsSortedBy:(NSString *)sortProperty
                          error:(NSError **)error;



#pragma mark - UPDATE

/**
 @abstract Saves the object's corresponding row
 in the database represented by the shared database
 controller based on the properties of this object
 
 @discussion This method uses the shared database
 controller to save the object on which this
 method was called. The conditions to identify
 this particular object as arow in the database
 are extracted through the LabQLiteRowMappable
 method -SQLiteStipulationsForMapping.
 
 @param error the error pointer which will point to
 the error object of failed insertions; nil if no errors
 
 @return whether or not the UPDATE was successful
 
 @see LabQLiteDatabaseController
 
 @see SQLiteRowMappable
 
 @see [LabQLiteDatabaseController sharedDatabaseController]
 
 @see +saveRow:to:where: on LabQLiteDatabaseController
 */
- (BOOL)save:(NSError **)error;

/**
 @abstract Saves the object's corresponding row
 in the database represented by the shared database
 controller based on the properties of this object
 
 @discussion This method uses the shared database
 controller to save the object on which this
 method was called. The conditions to identify
 this particular object as arow in the database
 are extracted through the LabQLiteRowMappable
 method -SQLiteStipulationsForMapping.
 
 !!CAUTION!!
 
    IF YOU HAVE CHANGED THE PRIMARY KEY BEFORE SAVING,
    REALIZE THAT THE ROW WILL NOT BE UPDATED BECAUSE
    SQLITE HAS NO REFERENCE POINT FOR WHICH ROW HAS
    BEEN MODIFIED OTHER THAN THE PRIMARY KEY ITSELF.
 
    In such cases, it is recommended to first update
    the LabQLiteRow object to be another row object
    using the following method:
 
    - (BOOL)updateRow:(id <LabQLiteRowMappable>)rowObject
                   to:(id <LabQLiteRowMappable>)newRowObject
                where:(NSArray *)stipulations
                error:(NSError **)error;
 
    This method is found in the LabQLiteDatabaseController.
 
    Ensure you use the newRowObject as your reference
    after that.
 
 @return whether or not the UPDATE was successful
 
 @see LabQLiteDatabaseController
 
 @see SQLiteRowMappable
 
 @see [LabQLiteDatabaseController sharedDatabaseController]
 
 @see +saveRow:to:where: on LabQLiteDatabaseController
 */
- (void)saveWithCompletionBlock:(void(^)(BOOL didSaveSuccessfully, NSError *error))completion;



#pragma mark - DELETE (Destroy)

/**
 @abstract Deletes row (represented by this object)
 from database (represented by the shared database).
 
 @discussion This method asks the shared database
 controller to execute a DELETE statement. The DELETE
 statement is executed on the table represented by
 the class receiving this message.
 
 @param error the error pointer which will point to
 the error object of failed insertions; nil if no errors
 
 @return whether or not the deletion was successful
 */
- (BOOL)deleteCorrespondingRow:(NSError **)error;

/**
 @abstract Deletes row in the shared database 
 represented by the object on which this method
 is called.
 
 @discussion This method asks the shared database
 controller to execute a DELETE statement. The DELETE
 statement is executed on the table represented by
 the class of the object receiving this message.
 
 @param completion the completion block that gets
 executed upon completion of this method; it includes
 a BOOL which denotes success or failure of deletion;
 it also provides the usual error object for
 any errors that might have arisen while processing
 the deletion
 */
- (void)deleteCorrespondingRowWithCompletionBlock:(void(^)(BOOL didDeleleteCorrespondingRowSuccessfully, NSError *error))completion;

/**
 @abstract Delete all rows from the table represented
 by the class on which this class method is called.
 
 @discussion Uses the table name associated with the
 class upon which this class method is called and
 calls the DELETE statement to delete all rows from
 said table.
 
 @param error the error pointer which will point to
 the error object of failed insertions; nil if no errors
 
 @return whether or not all rows in the table
 were deleted
 */
+ (BOOL)deleteAll:(NSError **)error;

/**
 @abstract Delete all rows from the table represented
 by the class on which this class method is called.
 
 @discussion Uses the table name associated with the
 class upon which this class method is called and
 calls the DELETE statement to delete all rows from
 said table.
 
 @param completion the completion block that gets
 executed upon completion of this method; it includes
 a BOOL which denotes success or failure of deletion;
 it also provides the usual error object for
 any errors that might have arisen while processing
 the deletion
 */
+ (void)deleteAllWithCompletionBlock:(void(^)(BOOL didDeleleteCorrespondingRowSuccessfully, NSError *error))completion;

/**
 @abstract Delete rows which match the critera of
 the provided stipulations
 
 @discussion Uses the table name associated with the
 class upon which this class method is called and
 calls the DELETE WHERE statement to delete all rows from
 said table which match the conditions specified in
 the provided stipulations
 
 @param stipulations an array of LabQLiteStipulation
 objects
 
 @param error the error pointer which will point to
 the error object of failed insertions; nil if no errors
 
 @return whether or not the rows matching the criteria
 specified by the stipulations were deleted
 
 @see LabQLiteStipulation
 */
+ (BOOL)deleteWithStipulations:(NSArray *)stipulations error:(NSError **)error;

/**
 @abstract Delete rows which match the critera of
 the provided stipulations
 
 @discussion Uses the table name associated with the
 class upon which this class method is called and
 calls the DELETE WHERE statement to delete all rows from
 said table which match the conditions specified in
 the provided stipulations
 
 @param stipulations an array of LabQLiteStipulation
 objects
 
 @param completion the completion block that gets
 executed upon completion of this method; it includes
 a BOOL which denotes success or failure of deletion;
 it also provides the usual error object for
 any errors that might have arisen while processing
 the deletion
 
 @see LabQLiteStipulation
 */
+ (void)deleteWithStipulations:(NSArray *)stipulations
               completionBlock:(void(^)(BOOL didDeleteSuccessfully, NSError *error))completion;


@end

