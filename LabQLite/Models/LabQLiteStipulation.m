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

#import "LabQLiteStipulation.h"


@implementation LabQLiteStipulation


NSString *const LabQLiteStipulationErrorDomain = @"LabQLiteStipulationErrorDomain";

NSString *const LabQLiteStipulationErrorMessageNoBinaryOperator = @"No binary operator found in this stipulation.";
NSString *const LabQLiteStipulationErrorMessageInvalidBinaryOperator = @"Invalid binary operator supplied.";

+ (LabQLiteStipulation *)stipulationWithAttribute:(NSString *)attribute
                                   binaryOperator:(SQLite3BinaryOperator *)binaryOperator
                                            value:(id)value
                                         affinity:(NSNumber *)affinityTypeOfValue
                         precedingLogicalOperator:(SQLite3LogicalOperator *)precedingLogicalOperator
                                            error:(NSError **)error {
    
    LabQLiteStipulation *newStipulation = [[LabQLiteStipulation alloc] init];
    newStipulation.attribute = attribute;
    newStipulation.binaryOperator = binaryOperator;
    
    // Check to make sure binary operator is not nil
    if (newStipulation.binaryOperator == nil) {
        NSError *err = [[NSError alloc] initWithDomain:LabQLiteStipulationErrorDomain
                                                  code:LabQLiteStipulationErrorNoBinaryOperator
                                              userInfo:@{@"errorMessage" : LabQLiteStipulationErrorMessageNoBinaryOperator}];
        if (error) {
            *error = err;
        }
        return nil;
    }
    
    BOOL isValidOperator = [LabQLiteValidationController isValidSQLiteBinaryOperator:newStipulation.binaryOperator];
    if (!isValidOperator) {
        NSString *details = [NSString stringWithFormat:@"Operator: %@", newStipulation.binaryOperator];
        NSError *err = [[NSError alloc] initWithDomain:LabQLiteStipulationErrorDomain
                                                  code:LabQLiteStipulationErrorNoBinaryOperator
                                              userInfo:@{@"errorMessage" : LabQLiteStipulationErrorMessageInvalidBinaryOperator,
                                                         @"errorDetails" : details}];
        if (error) {
            *error = err;
        }
        return nil;
    }
    
    // Because a value can be an:
    //    NSDate,
    //    NSString,
    //    NSData,
    //    or NSNumber,
    // we have to extract the value appropriately
    // and make it into a string form for SQLite
    // processing purposes.
    
    
    NSString *stringValue;
    
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *v = (NSNumber *)value;
        stringValue = [v stringValue];
    }
    else if ([value isKindOfClass:[NSString class]]) {
        NSString *v = (NSString *)value;
        stringValue = v;
    }
    else if ([value isKindOfClass:[NSData class]]) {
        NSData *v = (NSData *)value;
        stringValue = [[NSString alloc] initWithData:v encoding:NSUTF8StringEncoding];
    }
    else if ([value isKindOfClass:[NSDate class]]) {
        NSDate *v = (NSDate *)value;
        NSDateFormatter *defaultFormatter = [[NSDateFormatter alloc] init];
        [defaultFormatter setDateFormat:@"yyyy-MM-DD HH:mm:ss ZZZZ"];
        stringValue = [defaultFormatter stringFromDate:v];
    }
    else {
        // ERROR: Default value is NULL.
        stringValue = @"NULL";
    }
    
    
    newStipulation.value = stringValue;
    
    
    newStipulation.affinity = affinityTypeOfValue;
    newStipulation.precedingLogicalOperator = precedingLogicalOperator;
    return newStipulation;
}

+ (NSArray *)valuesForBindingFromStipulations:(NSArray *)arrayOfStipulations {
    NSMutableArray *values = [NSMutableArray new];
    for (LabQLiteStipulation *s in arrayOfStipulations) {
        [values addObject:s.value];
    }
    NSArray *valuesImmutable = [NSArray arrayWithArray:values];
    return valuesImmutable;
}

+ (NSArray *)affinitiesForBindingFromStipulations:(NSArray *)arrayOfStipulations {
    NSMutableArray *affinities = [NSMutableArray new];
    for (LabQLiteStipulation *s in arrayOfStipulations) {
        [affinities addObject:s.affinity];
    }
    NSArray *affinitiesImmutable = [NSArray arrayWithArray:affinities];
    return affinitiesImmutable;
}


@end

