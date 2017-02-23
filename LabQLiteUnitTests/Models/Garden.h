/*!
    Garden : LabQLiteRow
    Generated using LabQLitemodelgen.sh 1.0
    Compatible with LabQLite 1.0
 */


#import "LabQLiteRow.h"

@interface Garden : LabQLiteRow

/**
 @note corresponding SQLite declared type is TEXT
 @note corresponding SQLite affinity type is TEXT
*/
@property (nonatomic) NSString *gardenName;

/**
 @note corresponding SQLite declared type is TEXT
 @note corresponding SQLite affinity type is TEXT
*/
@property (nonatomic) NSString *address;

/**
 @note corresponding SQLite declared type is DATE
 @note corresponding SQLite affinity type is NUMERIC
*/
@property (nonatomic) NSString *dateAdded;


@end
