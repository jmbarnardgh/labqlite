/*!
    Plant : LabQLiteRow
    Generated using LabQLitemodelgen.sh 1.0
    Compatible with LabQLite 1.0
 */


#import "LabQLiteRow.h"

@interface Plant : LabQLiteRow

/**
 @note corresponding SQLite declared type is TEXT
 @note corresponding SQLite affinity type is TEXT
*/
@property (nonatomic) NSString *commonName;

/**
 @note corresponding SQLite declared type is TEXT
 @note corresponding SQLite affinity type is TEXT
*/
@property (nonatomic) NSString *commonType;

/**
 @note corresponding SQLite declared type is BLOB
 @note corresponding SQLite affinity type is NONE
*/
@property (nonatomic) NSData *iconImage;


@end
