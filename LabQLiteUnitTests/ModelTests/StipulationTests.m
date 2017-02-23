//
//  StipulationTests.m
//  LabQLite
//
//  Created by Jacob Barnard on 6/3/16.
//  Copyright © 2016 LABITORY LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LabQLiteTestSetupConstants.h"
#import "Garden.h"

@interface StipulationTests : XCTestCase

@end

@implementation StipulationTests{
    LabQLiteTestSetupConstants *_constants;
}

- (void)setUp {
    [super setUp];
    _constants = [[LabQLiteTestSetupConstants alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    NSError *deletionError = nil;
    [Garden deleteAll:&deletionError];
    NSArray *gardensRemaining = [Garden allObjects:nil];
    NSInteger numGardensRemaining = [gardensRemaining count];
    XCTAssertTrue(numGardensRemaining == 0);
    NSLog(@"Deletion of gardens after Row Test Executed - error: %@", deletionError);
    _constants = nil;
    [super tearDown];
}



#pragma Begin Tests



#pragma mark - Initialization Methods

- (void)test_01a_creatingAStipulationWithNoParamsShouldFail {
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:nil
                                                            binaryOperator:nil
                                                                     value:nil
                                                                  affinity:nil
                                                  precedingLogicalOperator:nil
                                                                     error:nil];
    XCTAssertNil(s);
}

- (void)test_01b_creatingAStipulationWithNoBinaryOperatorShouldFail {
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:[_constants->_butchartGardens columnNames][0]
                                                            binaryOperator:nil
                                                                     value:[_constants->_butchartGardens gardenName]
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil
                                                                     error:nil];

    XCTAssertNil(s);
}

- (void)test_01c_creatingAStipulationWithInvalidBinaryOperatorShouldFail {
    NSError *error = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:[_constants->_butchartGardens columnNames][0]
                                                            binaryOperator:@"X"
                                                                     value:[_constants->_butchartGardens gardenName]
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil
                                                                     error:&error];
    
    NSLog(@"Error from Bad Operator in Stipulation Creation: %@", error);
    XCTAssertNotNil(error);
    XCTAssertNil(s);
}

- (void)test_01d_creatingAStipulationWithInvalidReferencedOperatorShouldFail {
    NSError *error = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:[_constants->_butchartGardens columnNames][0]
                                                            binaryOperator:SQLite3LogicalOperatorAND
                                                                     value:[_constants->_butchartGardens gardenName]
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil
                                                                     error:&error];
    
    NSLog(@"Error from Bad Operator in Stipulation Creation: %@", error);
    XCTAssertNotNil(error);
    XCTAssertNil(s);
}

- (void)test_01e_creatingAStipulationWithValidLiteralBinaryOperatorShouldSucceed {
    NSError *error = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:[_constants->_butchartGardens columnNames][0]
                                                            binaryOperator:@"="
                                                                     value:[_constants->_butchartGardens gardenName]
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil
                                                                     error:&error];
    
    NSLog(@"Error from Bad Operator in Stipulation Creation: %@", error);
    XCTAssertNil(error);
    XCTAssertNotNil(s);
}

- (void)test_01f_creatingAStipulationWithValidReferencedBinaryOperatorShouldSucceed {
    NSError *error = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:[_constants->_butchartGardens columnNames][0]
                                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                                     value:[_constants->_butchartGardens gardenName]
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil
                                                                     error:&error];
    
    NSLog(@"Error from Bad Operator in Stipulation Creation: %@", error);
    XCTAssertNil(error);
    XCTAssertNotNil(s);
}

- (void)test_01g_creatingAStipulationWithNilAffinityShouldFail {
    NSError *error = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:[_constants->_butchartGardens columnNames][0]
                                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                                     value:[_constants->_butchartGardens gardenName]
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil
                                                                     error:&error];
    
    NSLog(@"Error from Bad Operator in Stipulation Creation: %@", error);
    XCTAssertNil(error);
    XCTAssertNotNil(s);
}



#pragma mark - Helper Methods

- (void)test_02_gettingValuesFromValidStipulationObjectShouldSucceed {
    NSError *error = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:[_constants->_butchartGardens columnNames][0]
                                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                                     value:[_constants->_butchartGardens gardenName]
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil
                                                                     error:&error];
    
    NSLog(@"Error from Bad Operator in Stipulation Creation: %@", error);
    XCTAssertNil(error);
    XCTAssertNotNil(s);
    
    NSArray *valuesForBinding = [LabQLiteStipulation valuesForBindingFromStipulations:@[s]];
    XCTAssertNotNil(valuesForBinding);
    NSInteger countOfValuesForBinding = [valuesForBinding count];
    XCTAssertTrue(countOfValuesForBinding == 1);
    NSString *v = [valuesForBinding firstObject];
    XCTAssertTrue([v compare: [_constants->_butchartGardens gardenName]] == NSOrderedSame);
}

- (void)test_03_gettingAffinitiesFromValidStipulationObjectShouldSucceed {
    NSError *error = nil;
    LabQLiteStipulation *s = [LabQLiteStipulation stipulationWithAttribute:[_constants->_butchartGardens columnNames][0]
                                                            binaryOperator:SQLite3BinaryOperatorEquals
                                                                     value:[_constants->_butchartGardens gardenName]
                                                                  affinity:SQLITE_AFFINITY_TYPE_TEXT
                                                  precedingLogicalOperator:nil
                                                                     error:&error];
    
    NSLog(@"Error from Bad Operator in Stipulation Creation: %@", error);
    XCTAssertNil(error);
    XCTAssertNotNil(s);
    
    NSArray *affinitiesForStipulation = [LabQLiteStipulation affinitiesForBindingFromStipulations:@[s]];
    XCTAssertNotNil(affinitiesForStipulation);
    NSInteger c = [affinitiesForStipulation count];
    XCTAssertTrue(c == 1);
    NSNumber *v = [affinitiesForStipulation firstObject];
    XCTAssertTrue([v compare: SQLITE_AFFINITY_TYPE_TEXT] == NSOrderedSame);
}



#pragma mark - Complex Stipulation Chains

- (void)test_04_complexStipulationChainInDataRetrievalShouldWorkWithValidStipulations {
    
    // Prepare set of complex data.
    
    NSUInteger numRows = 1000; // 1 million
    NSUInteger counter = 0;
    while (counter < numRows) {
        Garden *g = [Garden new];
        
//        NSString *gName = [NSString stringWithFormat:@"g-%lu", counter];
        NSString *gardenAddress = [NSString stringWithFormat:@"a-%lu", counter];
        NSString *gardenDatedded = [NSString stringWithFormat:@"1700-%lu", counter];
        
        g.gardenName = [NSString stringWithFormat:@"g-%lu", counter];
        g.address = gardenAddress;
        g.dateAdded = gardenDatedded;
        
        NSError *selfInsertionError = nil;
        [g insertSelf:&selfInsertionError];
        
        counter++;
    }
    
    // Ensure what we get back is 12 gardens.
    NSError *getAllGardensError = nil;
    NSArray *allTwelveGardens = [Garden allObjects:&getAllGardensError];
    
    NSUInteger numberOfRetrievedGardens = [allTwelveGardens count];
    NSLog(@"Number of Retrieved Gardens: %lu", numberOfRetrievedGardens);
    XCTAssertTrue(numberOfRetrievedGardens == 1000);
    
    
    // Create complex stipulation chain of ANDs, ORs and NOTs
    
    NSMutableArray *stipulations = [[NSMutableArray alloc] initWithCapacity:3];
    NSUInteger numStipulations = 3;
    counter = 0;
    while (counter < numStipulations) {
        
        NSString *attribute, *binOp, *val, *preOp;
        NSNumber *affinity = SQLITE_AFFINITY_TYPE_TEXT;
        NSError *error = nil;
        switch (counter) {
            case 0: {
                attribute=@"garden_name";
                binOp=SQLite3BinaryOperatorLike;
                val=@"\%99\%";
                preOp=nil;
                break;
            }
            case 1: {
                attribute=@"address";
                binOp=SQLite3BinaryOperatorEquals;
                val=@"a-199";
                preOp=SQLite3LogicalOperatorOR;
                break;
            }
            case 2: {
                attribute=@"date_added";
                binOp=SQLite3BinaryOperatorEquals;
                val=@"1700-922";
                preOp=SQLite3LogicalOperatorOR;
                break;
            }
        }
        
        LabQLiteStipulation *stipulation = [LabQLiteStipulation stipulationWithAttribute:attribute
                                                                          binaryOperator:binOp
                                                                                   value:val
                                                                                affinity:affinity
                                                                precedingLogicalOperator:preOp
                                                                                   error:&error];
        
        XCTAssertNotNil(stipulation);
        [stipulations addObject:stipulation];
        
        counter++;
    }
    
    NSError *stipulatedRetrievalError = nil;
    NSArray *stipulatedResults = [Garden objectsAtOffset:0
                                                   limit:1000
                                                orderdBy:nil
                                        withStipulations:stipulations
                                                   error:&stipulatedRetrievalError];
    
    NSUInteger numResults = [stipulatedResults count];

    NSLog(@"Error from Stipulated Results Retrieval: %@", stipulatedRetrievalError);
    NSLog(@"stipulatedResults: %@", stipulatedResults);
    NSLog(@"Number of Stipulated Results: %lu", numResults);
    
    for (Garden *r in stipulatedResults) {
        NSLog(@"Got garden: %@", r.gardenName);
    }
    
    XCTAssertNotNil(stipulatedResults);
    XCTAssertTrue(numResults == 20);
    XCTAssertNil(stipulatedRetrievalError);
 }

@end

