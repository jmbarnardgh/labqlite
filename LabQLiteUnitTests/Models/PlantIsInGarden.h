/*!
    PlantIsInGarden : LabQLiteRow
    Generated using LabQLitemodelgen.sh 1.0
    Compatible with LabQLite 1.0
 */


#import "LabQLiteRow.h"

@interface PlantIsInGarden : LabQLiteRow

/**
 @note corresponding SQLite declared type is TEXT
 @note corresponding SQLite affinity type is TEXT
*/
@property (nonatomic) NSString *fkPlantSpecies;

/**
 @note corresponding SQLite declared type is TEXT
 @note corresponding SQLite affinity type is TEXT
*/
@property (nonatomic) NSString *fkGardenName;

/**
 @note corresponding SQLite declared type is TEXT
 @note corresponding SQLite affinity type is TEXT
*/
@property (nonatomic) NSString *fkGardenAddress;

/**
 @note corresponding SQLite declared type is INTEGER
 @note corresponding SQLite affinity type is INTEGER
*/
@property (nonatomic) NSNumber *countOfPlant;


@end
