/*!
    Implementation file for the PlantIsInGarden class.
    Generated using LabQLitemodelgen.sh 1.0
    Compatible with LabQLite 1.0
 */


#import "PlantIsInGarden.h"

@implementation PlantIsInGarden


#pragma mark - Required LabQLiteRowMappable @protocol Methods
    
- (NSString *)tableName { 
    return @"plant_is_in_garden";
}
    

- (NSArray *)propertyKeysMatchingAttributeColumns {
    return @[@"fkPlantSpecies",
             @"fkGardenName",
             @"fkGardenAddress",
             @"countOfPlant"];
}

    
- (NSArray *)columnTypesForAttributeColumns {
    return @[SQLITE_AFFINITY_TYPE_TEXT,
             SQLITE_AFFINITY_TYPE_TEXT,
             SQLITE_AFFINITY_TYPE_TEXT,
             SQLITE_AFFINITY_TYPE_INTEGER];
}

- (NSArray *)valuesCorrespondingToPropertyKeys {
    return @[self.fkPlantSpecies,
             self.fkGardenName,
             self.fkGardenAddress,
             self.countOfPlant];
}
    
- (NSArray *)SQLiteStipulationsForMapping {
    return @[[LabQLiteStipulation stipulationWithAttribute:@"fk_plant_species"
                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                     value:self.fkPlantSpecies
                                                  affinity:self.columnTypesForAttributeColumns[0]
                                  precedingLogicalOperator:nil
                                                     error:nil],
             [LabQLiteStipulation stipulationWithAttribute:@"fk_garden_name"
                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                     value:self.fkGardenName
                                                  affinity:self.columnTypesForAttributeColumns[1]
                                  precedingLogicalOperator:SQLite3LogicalOperatorAND
                                                     error:nil],
             [LabQLiteStipulation stipulationWithAttribute:@"fk_garden_address"
                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                     value:self.fkGardenAddress
                                                  affinity:self.columnTypesForAttributeColumns[2]
                                  precedingLogicalOperator:SQLite3LogicalOperatorAND
                                                     error:nil]
            ];
}

@end
