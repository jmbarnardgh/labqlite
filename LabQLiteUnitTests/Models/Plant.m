/*!
    Implementation file for the Plant class.
    Generated using LabQLitemodelgen.sh 1.0
    Compatible with LabQLite 1.0
 */


#import "Plant.h"

@implementation Plant


#pragma mark - Required LabQLiteRowMappable @protocol Methods
    
- (NSString *)tableName { 
    return @"plant";
}
    

- (NSArray *)propertyKeysMatchingAttributeColumns {
    return @[@"commonName",
             @"commonType",
             @"iconImage"];
}

    
- (NSArray *)columnTypesForAttributeColumns {
    return @[SQLITE_AFFINITY_TYPE_TEXT,
             SQLITE_AFFINITY_TYPE_TEXT,
             SQLITE_AFFINITY_TYPE_NONE];
}

- (NSArray *)valuesCorrespondingToPropertyKeys {
    return @[self.commonName,
             self.commonType,
             self.iconImage];
}

    
- (NSArray *)SQLiteStipulationsForMapping {
    return @[[LabQLiteStipulation stipulationWithAttribute:@"common_name"
                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                     value:self.commonName
                                                  affinity:self.columnTypesForAttributeColumns[0]
                                  precedingLogicalOperator:nil
                                                     error:nil]
            ];
}

@end
