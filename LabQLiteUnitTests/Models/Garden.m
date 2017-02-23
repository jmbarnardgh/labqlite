/*!
    Implementation file for the Garden class.
    Generated using labqlitemodelgen.sh 1.0
    Compatible with LabQLite 1.0
 */


#import "Garden.h"

@implementation Garden


#pragma mark - Required LABQLiteRowMappable @protocol Methods
    
- (NSString *)tableName { 
    return @"garden";
}
    

- (NSArray *)propertyKeysMatchingAttributeColumns {
    return @[@"gardenName",
             @"address",
             @"dateAdded"];
}

    
- (NSArray *)columnNames {
    return @[@"garden_name",
             @"address",
             @"date_added"];
}

    
- (NSArray *)columnTypesForAttributeColumns {
    return @[SQLITE_AFFINITY_TYPE_TEXT,
             SQLITE_AFFINITY_TYPE_TEXT,
             SQLITE_AFFINITY_TYPE_NUMERIC];
}

    
- (NSArray *)SQLiteStipulationsForMapping {
    return @[[LabQLiteStipulation stipulationWithAttribute:@"garden_name"
                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                     value:self.gardenName
                                                  affinity:self.columnTypesForAttributeColumns[0]
                                  precedingLogicalOperator:nil
                                                      error:nil]
            ];
}


@end

