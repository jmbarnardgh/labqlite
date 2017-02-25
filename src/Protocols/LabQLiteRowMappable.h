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



#pragma mark - SQLite3 Affinity Rules Enumerated as NSNumbers

#define SQLITE_AFFINITY_TYPE_INTEGER @1
#define SQLITE_AFFINITY_TYPE_TEXT    @2
#define SQLITE_AFFINITY_TYPE_NONE    @3
#define SQLITE_AFFINITY_TYPE_REAL    @4
#define SQLITE_AFFINITY_TYPE_NUMERIC @5



#pragma mark - LabQLiteRowMappable Protocol

/**
 @abstract Objects which conform to this protocol are 
 processable by an LabQLiteDatabaseController. In this
 respect, such objects represent rows in a table or view.
 
 @see LabQLiteDatabaseController
 */
@protocol LabQLiteRowMappable <NSObject>

@required

/**
 @abstract Provides the table name associated with the
 row represented by the object.
 
 @return The table name associated with the row represented
 by the object.
 */
- (NSString *)tableName;


/**
 @abstract Provides list of column names in order for
 the table from whence/to-where this row came/is-going.
 */
- (NSArray *)columnNames;

/**
 @abstract Provides all of the property keys corresponding
 to the column names (attributes) of the corresponding 
 SQL row's table or view.
 
 @return The property keys corresponding to the column names
 (attributes) of the corresponding SQL row's table or view.
 */
- (NSArray *)propertyKeysMatchingAttributeColumns;

/**
 @abstract Provides all of the column types of the row
 corresponding to the property keys of this object.
 
 @return The column types of the row corresponding to the
 property keys of this object.
 */
- (NSArray *)columnTypesForAttributeColumns;

/**
 @abstract Provides all of the conditions necessary to map
 this object with a row in a SQL table or view.
 
 @return All of the conditions necessary to map this object
 with a row in a SQL table or view.
 */
- (NSArray *)SQLiteStipulationsForMapping;

/**
 @abstract Provides all of the values corresponding to the
 attributes (columns) in the corresponding SQL row.
 
 @return All of the values corresponding to the attributes
 (columns) in the corresponding SQL row.
 */
- (NSMutableArray *)valuesMatchingAttributeColumns;



@optional

/**
 @abstract A convenience method for validating objects as
 representing SQL rows correctly.
 
 @param error Standard error capturing double indirection
 pointer.
 
 @return Whether or not the object is valid.
 */
- (BOOL)isValid:(NSError **)error;


@end

