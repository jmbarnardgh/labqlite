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


#import "LabQLiteRow.h"



#pragma mark - Error Handling

NSString *const LabQLiteRowErrorDomain = @"LabQLiteRowErrorDomain";

NSString *const LabQLiteRowErrorMessageObjectsInCollectionNotAllSameClass = @"Collection of SQLiteRow objects or SQLiteRow subclassed objects are not all of the same exact class as they ought to be.";
NSString *const LabQLiteRowErrorMessageCRUDMethodCalledOnRawSQLiteRowObject = @"Active Record method called on raw SQLiteRow object. Objects calling CRUD methods must be of type subclass of SQLiteRow.";
NSString *const LabQLiteRowErrorMessageObjectPropertyOrKeyNotFound = @"Specified object property/key not found.";

@interface LabQLiteRow(PrivateMethods)
- (NSMutableArray *)propertyValuesMatchingKeys;
@end



@implementation LabQLiteRow


- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}



#pragma mark - SQLiteRowMappable methods

- (BOOL)insertSelf:(NSError **)error {
    
    // Validity check
    BOOL isValid = [self isValid:error];
    if (!isValid) return NO;
    
    // Check for shared controller
    LabQLiteDatabaseController *dbController = [LabQLiteDatabaseController sharedDatabaseController];
    if (dbController == nil) return NO;
    
    // Attempt insertion
    BOOL inserted = [dbController insertRow:self error:error];
    return inserted;
}

- (void)insertSelfWithCompletionBlock:(void(^)(BOOL success, NSError *error))completion {
    NSError *err;
    if ([self isValid:&err]) {
        [[LabQLiteDatabaseController sharedDatabaseController] insertRow:self
                                                         completionBlock:completion];
        return;
    }
    completion(NO, err);
}


#pragma mark - ActiveRecord pattern CRUD methods

+ (BOOL)insertObjects:(NSArray *)objects
                error:(NSError **)error {
    
    // The first step is to ensure that all
    // objs provided in the objects NSArray
    // are of a uniform class type; moreoever,
    // said class must be a subclass of LabQLiteRow.
    // Moreover, said class must be the same
    // class as is calling this class method.
    Class expectedUniformClass = [self class];
    
    for (id obj in objects) {
        Class objectClass = [obj class];
        
        // Class of the obj must be a subclass
        // of LabQLiteRow
        if (![objectClass isSubclassOfClass:[LabQLiteRow class]]) {
            *error = [NSError errorWithDomain:LabQLiteRowErrorDomain
                                         code:LabQLiteRowErrorObjectsInCollectionNotAllSameClass
                                     userInfo:@{@"errorMessage" : LabQLiteRowErrorMessageObjectsInCollectionNotAllSameClass}];
            return NO;
        }
        
        // Class of the obj must be uniform with
        // every other obj class
        if (objectClass != expectedUniformClass) {
            *error = [NSError errorWithDomain:LabQLiteRowErrorDomain
                                         code:LabQLiteRowErrorObjectsInCollectionNotAllSameClass
                                     userInfo:@{@"errorMessage" : LabQLiteRowErrorMessageObjectsInCollectionNotAllSameClass}];
            return NO;
        }
    }
    
    // All objs in objects are, at this point,
    // considered subclasses of LabQLiteRow.
    // ... Next, we ask each row to validate
    // itself before this method moves on
    // to the insertion step.
    for (LabQLiteRow *row in objects) {
        if (![row isValid:error]) {
            return NO;
        }
    }
    
    // All objs in objects are, at this point,
    // considered completely valid. We now call
    // the insertion method.
    if ([[LabQLiteDatabaseController sharedDatabaseController] insertRows:objects
                                                                intoTable:[[objects objectAtIndex:0] tableName]
                                                                    error:error]) {
        return YES;
    }
    return NO;
}

+ (void)insertObjects:(NSArray *)objects
      completionBlock:(void(^)(BOOL success, NSError *error))completion {
    
    // The first step is to ensure that all
    // objs provided in the objects NSArray
    // are of a uniform class type; moreoever,
    // said class must be a subclass of LabQLiteRow.
    // Moreover, said class must be the same
    // class as is calling this class method.
    Class expectedUniformClass = [self class];
    
    // Create error object
    NSError *err;
    
    for (id obj in objects) {
        Class objectClass = [obj class];
        
        // Class of the obj must be a subclass
        // of LabQLiteRow
        if (![objectClass isSubclassOfClass:[LabQLiteRow class]]) {
            err = [NSError errorWithDomain:LabQLiteRowErrorDomain
                                      code:LabQLiteRowErrorObjectsInCollectionNotAllSameClass
                                  userInfo:@{@"errorMessage" : LabQLiteRowErrorMessageObjectsInCollectionNotAllSameClass}];
            completion(NO, err);
            return;
        }
        
        // Class of the obj must be uniform with
        // every other obj class
        if (objectClass != expectedUniformClass) {
            err = [NSError errorWithDomain:LabQLiteRowErrorDomain
                                      code:LabQLiteRowErrorObjectsInCollectionNotAllSameClass
                                  userInfo:@{@"errorMessage" : LabQLiteRowErrorMessageObjectsInCollectionNotAllSameClass}];
            completion(NO, err);
            return;
        }
    }
    
    // All objs in objects are, at this point,
    // considered subclasses of LabQLiteRow.
    // ... Next, we ask each row to validate
    // itself before this method moves on
    // to the insertion step.
    for (LabQLiteRow *row in objects) {
        if (![row isValid:&err]) {
            completion(NO, err);
            return;
        }
    }
    
    // All objs in objects are, at this point,
    // considered completely valid. We now call
    // the insertion method.
    BOOL insertionSuccess = [[LabQLiteDatabaseController sharedDatabaseController] insertRows:objects
                                                                                    intoTable:[[objects objectAtIndex:0] tableName]
                                                                                        error:&err];
    if (insertionSuccess) {
        completion(YES, nil);
        return;
    }
    completion(NO, err);
}


+ (NSArray *)objectsAtOffset:(NSUInteger)offset
                       limit:(NSUInteger)maxNumberOfObjectsToReturn
                    orderdBy:(NSString *)sortProperty
            withStipulations:(NSArray *)stipulations
                       error:(NSError **)error {
    NSArray *objects;
    Class c = [self class];
    if (c == [LabQLiteRow class]) {
        *error = [NSError errorWithDomain:LabQLiteErrorDomain
                                     code:LabQLiteRowErrorCRUDMethodCalledOnRawSQLiteRowObject
                                 userInfo:@{@"errorMessage" : LabQLiteRowErrorMessageCRUDMethodCalledOnRawSQLiteRowObject}];
        return objects;
    }
    id tempObj = [c new];
    if ([tempObj class] == c) {
        NSArray *stipulationsChoice;
        if (stipulations) stipulationsChoice = stipulations;
        else {
            stipulationsChoice = nil;
        }
        objects = [[LabQLiteDatabaseController sharedDatabaseController] rowsFromTable:[tempObj tableName]
                                                             asSQLite3RowsWithSubclass:c
                                                                          stipulations:stipulationsChoice
                                                                                offset:offset
                                                            andMaxNumberOfRowsToReturn:maxNumberOfObjectsToReturn
                                                                             orderedBy:sortProperty
                                                                                 error:error];
    }
    return objects;
}

+ (void)objectsAtOffset:(NSUInteger)offset
        numberOfObjects:(NSUInteger)maxNumberOfObjectsToReturn
         sortedByColumn:(NSString *)columnName
       withStipulations:(NSArray *)stipulations
        completionBlock:(void(^)(NSArray *results, NSError *error))completion {
    NSError *error;
    NSArray *objects;
    Class c = [self class];
    if (c == [LabQLiteRow class]) {
        error = [NSError errorWithDomain:LabQLiteErrorDomain
                                    code:LabQLiteRowErrorCRUDMethodCalledOnRawSQLiteRowObject
                                userInfo:@{@"errorMessage" : LabQLiteRowErrorMessageCRUDMethodCalledOnRawSQLiteRowObject}];
    }
    id tempObj = [c new];
    if ([tempObj class] == c) {
        NSArray *stipulationsChoice;
        if (stipulations) stipulationsChoice = stipulations;
        else {
            stipulationsChoice = nil;
        }
        objects = [[LabQLiteDatabaseController sharedDatabaseController] rowsFromTable:[tempObj tableName]
                                                             asSQLite3RowsWithSubclass:c
                                                                          stipulations:stipulationsChoice
                                                                                offset:offset
                                                            andMaxNumberOfRowsToReturn:maxNumberOfObjectsToReturn
                                                                             orderedBy:columnName
                                                                                 error:&error];
    }
    completion(objects, error);
}

+ (NSArray *)allObjects:(NSError **)error {
    Class c = [self class];
    id obj = [c new];
    NSString *tableName = [(id <LabQLiteRowMappable>)obj tableName];
    return [[LabQLiteDatabaseController sharedDatabaseController] allRows:tableName
                                                       SQLite3RowSubclass:c
                                                                    error:error];
}

+ (void)allObjectsWithCompletionBlock:(void(^)(NSArray *results, NSError *error))completion {
    NSError *error;
    NSArray *results;
    Class c = [self class];
    id obj = [c new];
    results = [[LabQLiteDatabaseController sharedDatabaseController] allRows:[(id <LabQLiteRowMappable>)obj tableName]
                                                          SQLite3RowSubclass:c
                                                                       error:&error];
    completion(results, error);
}

+ (NSArray *)allObjectsSortedBy:(NSString *)sortProperty
                          error:(NSError **)error {
    NSArray *objects = [[self class] allObjects:error];
    id firstObj = [objects firstObject];
    // Defend!
    BOOL understandsKey = [firstObj respondsToSelector:NSSelectorFromString(sortProperty)];
    if (!understandsKey) {
        *error = [NSError errorWithDomain:LabQLiteRowErrorDomain
                                     code:LabQLiteRowErrorObjectPropertyOrKeyNotFound
                                 userInfo:@{@"errorMessage" : LabQLiteRowErrorMessageObjectPropertyOrKeyNotFound,
                                            @"errorDetails" : sortProperty}];

        return nil;
    }
    // Ok... cool. Proceed.
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortProperty ascending:YES];
    NSArray *sortedObjects = [objects sortedArrayUsingDescriptors:@[sortDescriptor]];
    return sortedObjects;
}

+ (NSArray *)allObjectsSortedBy:(NSString *)sortProperty
                completionBlock:(void(^)(NSArray *results, NSError *error))completion {
    NSArray *objects;
    NSArray *sortedObjects;
    NSError *error;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortProperty ascending:YES];
    objects =  [self allObjects:&error];
    sortedObjects = [objects sortedArrayUsingDescriptors:@[sortDescriptor]];
    return sortedObjects;
}


- (BOOL)save:(NSError **)error {
    NSArray *stipulations = [self SQLiteStipulationsForMapping];
    BOOL updateSuccess = [[LabQLiteDatabaseController sharedDatabaseController] updateRow:self
                                                                                       to:self
                                                                                    where:stipulations
                                                                                    error:error];
    return updateSuccess;
}

- (void)saveWithCompletionBlock:(void(^)(BOOL didSaveSuccessfully, NSError *error))completion {
    NSError *error;
    BOOL didUpdateSuccessfully = [self save:&error];
    completion(didUpdateSuccessfully, error);
}


- (BOOL)deleteCorrespondingRow:(NSError **)error {
    return [[LabQLiteDatabaseController sharedDatabaseController] deleteRowsFromTable:self.tableName
                                                                     withStipulations:self.SQLiteStipulationsForMapping
                                                                                error:error];
}

- (void)deleteCorrespondingRowWithCompletionBlock:(void(^)(BOOL didDeleleteCorrespondingRowSuccessfully, NSError *error))completion {
    NSError *error;
    BOOL didDeleleteCorrespondingRowSuccessfully = [[LabQLiteDatabaseController sharedDatabaseController] deleteRowsFromTable:self.tableName
                                                                                               withStipulations:self.SQLiteStipulationsForMapping
                                                                                                          error:&error];
    completion(didDeleleteCorrespondingRowSuccessfully, error);
}


+ (BOOL)deleteAll:(NSError **)error {
    Class c = [self class];
    id obj = [c new];
    return [[LabQLiteDatabaseController sharedDatabaseController] deleteRowsFromTable:[(id <LabQLiteRowMappable>)obj tableName]
                                                                     withStipulations:nil
                                                                                error:error];
}

+ (void)deleteAllWithCompletionBlock:(void(^)(BOOL didDeleleteCorrespondingRowSuccessfully, NSError *error))completion {
    NSError *error;
    Class c = [self class];
    id obj = [c new];
    BOOL didDeleteAllRowsSuccessfully = [[LabQLiteDatabaseController sharedDatabaseController] deleteRowsFromTable:[(id <LabQLiteRowMappable>)obj tableName]
                                                                                                  withStipulations:nil
                                                                                                             error:&error];
    completion(didDeleteAllRowsSuccessfully, error);
}


+ (BOOL)deleteWithStipulations:(NSArray *)stipulations
                         error:(NSError **)error {
    Class c = [self class];
    id obj = [c new];
    return [[LabQLiteDatabaseController sharedDatabaseController] deleteRowsFromTable:[(id <LabQLiteRowMappable>)obj tableName]
                                                                     withStipulations:stipulations
                                                                                error:error];
}

+ (void)deleteWithStipulations:(NSArray *)stipulations
               completionBlock:(void(^)(BOOL didDeleteSuccessfully, NSError *error))completion {
    NSError *error;
    BOOL didDeleteSuccessfully = NO;
    Class c = [self class];
    id obj  = [c new];
    didDeleteSuccessfully = [[LabQLiteDatabaseController sharedDatabaseController] deleteRowsFromTable:[(id <LabQLiteRowMappable>)obj tableName]
                                                                                      withStipulations:stipulations
                                                                                                 error:&error];
    completion(didDeleteSuccessfully, error);
}

- (BOOL)isValid:(NSError **)error {
    return YES;
}

- (NSString *)tableName {
    return _tableName;
}

- (NSArray *)propertyKeysMatchingAttributeColumns {
    return _propertyKeysMatchingAttributeColumns;
}

- (NSArray *)columnTypesForAttributeColumns {
    return _columnTypesForAttributeColumns;
}

- (NSArray *)columnNames {
    return _columnNames;
}

- (NSArray *)SQLiteStipulationsForMapping {
    return _SQLiteStipulationsForMapping;
}

- (NSMutableArray *)valuesMatchingAttributeColumns {
    return [self propertyValuesMatchingKeys];
}

- (NSMutableArray *)propertyValuesMatchingKeys {
    NSMutableArray *values;
    NSArray *keys = [self propertyKeysMatchingAttributeColumns];
    if ([keys count] > 0) {
        values = [NSMutableArray new];
        for (int i = 0; i < [keys count]; i++) {
            id value = [self valueForKey:[keys objectAtIndex:i]];
            if (value == nil) {
                value = [NSNull null];
            }
            [values addObject:value];
        }
    }
    return values;
}


@end

