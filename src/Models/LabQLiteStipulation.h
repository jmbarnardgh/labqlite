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

#import "LabQLiteConstants.h"
#import "LabQLiteValidationController.h"

/**
 @abstract LabQLiteStipulation error domain. Ascribed
 to NSErrors which arise due to problems with the
 functions, properties or, otherwise, operations of
 the LabQLiteStipulation class.
 
 @see LabQLiteStipulation
 */
FOUNDATION_EXPORT NSString *const LabQLiteStipulationErrorDomain;

typedef enum {
    LabQLiteStipulationErrorNoBinaryOperator = 0,
    LabQLiteStipulationErrorInvalidBinaryOperator
} LabQLiteStipulationError;

FOUNDATION_EXPORT NSString *const LabQLiteStipulationErrorMessageNoBinaryOperator;
FOUNDATION_EXPORT NSString *const LabQLiteStipulationErrorMessageInvalidBinaryOperator;


#pragma mark - LabQLiteStipulation Class

/**
 Similar to an NSPredicate, an LabQLiteStipulation
 is a condition; the difference is that an LabQLiteStipulation
 is not as robust as an NSPredicate (e.g. it does
 not afford you the ability to specify a regex).
 LabQLiteStipulations are simple conditionals which
 are rolled up into a neat and tidy object. The
 unpackaging of said conditional is handled by an
 LabQLiteDatabaseController object, which converts
 the object's property values into a SQL WHERE
 conditional sub-statement. Example:
 
    self.binaryOperator = SQLite3BinaryOperatorEquals;
    self.attribute = @"name";
    self.value = @"John";
 
 This would translate into the WHERE conditional:
 
    "name"="John"
 
 A stipulation may also have a preceding logical
 operator (e.g. AND, OR, NOT). For methods where
 lists of stipulation objects are processed, the
 first stipulation's 'precendingLogicalOperator'
 is ignored.
 */
@interface LabQLiteStipulation : NSObject

/**
 @abstract The preceding logical operator for
 this stipulation
 
 @see LabQLiteConstants.h
 */
@property (nonatomic) NSString *precedingLogicalOperator;

/**
 @abstract If nil, then not negated; otherwise,
 negated.
 
 @see LabQLiteConstants.h
 */
@property (nonatomic) NSString *precedingNegationOperator;

/**
 @abstract The binary operator between the
 SQL attribute and the value
 
 @see LabQLiteConstants.h
 */
@property (nonatomic) NSString *binaryOperator;

/**
 @abstract The attribute whose value will be
 stipulated
 */
@property (nonatomic) NSString *attribute;

/**
 @abstract The value of the attribute being
 stipulated
 */
@property (nonatomic) NSString *value;

/**
 @abstract The SQLite attribute affinity
 type (e.g. TEXT, INTEGER, etc.)
 */
@property (nonatomic) NSNumber *affinity;



#pragma mark - Initialization

/**
 @abstract Initializes and returns a new stipulation
 object with the provided attribute (SQL column name),
 binary operator (=, !=, etc.), value (column value),
 affinityType (the affinity type for the SQL column
 type) and preceding logical operator (AND, OR or NOT).
 
 @param attribute the SQL column name of the stipulation
 
 @param binaryOperator the binary operator for the stipulation
 
 @param value the value of the SQL column
 
 @param affinityTypeOfValue the affinity type for the SQL
 column to be stipulated
 
 @param precedingLogicalOperator a preceding logical
 operator (e.g. AND, OR or NOT)
 */
+ (LabQLiteStipulation *)stipulationWithAttribute:(NSString *)attribute
                                   binaryOperator:(SQLite3BinaryOperator *)binaryOperator
                                            value:(id)value
                                         affinity:(NSNumber *)affinityTypeOfValue
                         precedingLogicalOperator:(SQLite3LogicalOperator *)precedingLogicalOperator
                                            error:(NSError **)error;

/**
 @abstract Given an array of objects with type LabQLiteStipulation,
 this method simply extracts and returns the values of each stipulation
 
 @param arrayOfStipulations the array of LabQLiteStipulations from which
 values will be extracted
 
 @return an array of values extracted from the provided arrayOfStipulations
 */
+ (NSArray *)valuesForBindingFromStipulations:(NSArray *)arrayOfStipulations;

/**
 @abstract Given an array of objects with type LabQLiteStipulation,
 this method simply extracts and returns the affinity types of each stipulation's
 attribute (that is, SQLite3 column type affinity)
 
 @param arrayOfStipulations the array of LabQLiteStipulations from which
 values will be extracted
 
 @return an array of values extracted from the provided arrayOfStipulations
 */
+ (NSArray *)affinitiesForBindingFromStipulations:(NSArray *)arrayOfStipulations;


@end

