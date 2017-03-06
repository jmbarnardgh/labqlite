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

@interface LabQLiteConstants : NSObject

+ (NSArray *)SQLITE_LOW_LVL_MSGS_ARRAY;

@end

typedef NSString SQLite3LogicalOperator;
extern NSString * const SQLite3LogicalOperatorAND;   
extern NSString * const SQLite3LogicalOperatorOR;    
extern NSString * const SQLite3LogicalOperatorNOT;

typedef NSString SQLite3BinaryOperator;
extern NSString * const SQLite3BinaryOperatorEquals;     
extern NSString * const SQLite3BinaryOperatorNotEquals;  
extern NSString * const SQLite3BinaryOperatorLike;       



extern NSString * const SQLITE3_LOW_LEVEL_ERROR_DOMAIN;
/**
 @discussion Codes can be found in the low level src in sqlite3.h.
 The following is merely a way to objective-c-afy these codes so
 that they have an error domain and an appropriate error message NSString.
 
 More specific messages will be printed to the console
 by sqlite3.c print calls.
 */

//  corresponding extern NSString * const message     corresponding code
//  -------------------------------                   ---------------------
extern NSString * const SQLITE_0_NO_ERROR;             //  corresponds to code  0
extern NSString * const SQLITE_1_ERROR_Message;        //  corresponds to code  1
extern NSString * const SQLITE_2_INTERNAL_Message;     //  corresponds to code  2
extern NSString * const SQLITE_3_PERM_Message;        //  corresponds to code  3
extern NSString * const SQLITE_4_ABORT_Message;        //  corresponds to code  4
extern NSString * const SQLITE_5_BUSY_Message;         //  corresponds to code  5
extern NSString * const SQLITE_6_LOCKED_Message;       //  corresponds to code  6
extern NSString * const SQLITE_7_NOMEM_Message;        //  corresponds to code  7
extern NSString * const SQLITE_8_READONLY_Message;     //  corresponds to code  8
extern NSString * const SQLITE_9_INTERRUPT_Message;    //  corresponds to code  9
extern NSString * const SQLITE_10_IOERR_Message;       //  corresponds to code 10
extern NSString * const SQLITE_11_CORRUPT_Message;     //  corresponds to code 11
extern NSString * const SQLITE_12_NOTFOUND_Message;    //  corresponds to code 12
extern NSString * const SQLITE_13_FULL_Message;        //  corresponds to code 13
extern NSString * const SQLITE_14_CANTOPEN_Message;    //  corresponds to code 14
extern NSString * const SQLITE_15_PROTOCOL_Message;    //  corresponds to code 15
extern NSString * const SQLITE_16_EMPTY_Message;       //  corresponds to code 16
extern NSString * const SQLITE_17_SCHEMA_Message;      //  corresponds to code 17
extern NSString * const SQLITE_18_TOOBIG_Message;      //  corresponds to code 18
extern NSString * const SQLITE_19_CONSTRAINT_Message;  //  corresponds to code 19
extern NSString * const SQLITE_20_MISMATCH_Message;    //  corresponds to code 20
extern NSString * const SQLITE_21_MISUSE_Message;      //  corresponds to code 21
extern NSString * const SQLITE_22_NOLFS_Message;       //  corresponds to code 22
extern NSString * const SQLITE_23_AUTH_Message;        //  corresponds to code 23
extern NSString * const SQLITE_24_FORMAT_Message;      //  corresponds to code 24
extern NSString * const SQLITE_25_RANGE_Message;       //  corresponds to code 25
extern NSString * const SQLITE_26_NOTADB_Message;      //  corresponds to code 26

// Processing Messages
extern NSString * const SQLITE_27_ROW_Message;         //  corresponds to code 27
extern NSString * const SQLITE_28_DONE_Message;        //  corresponds to code 28

extern NSString * const SQLITE_LOW_LVL_MSGS_ARRAY;

extern NSString * const kOpennedDatabaseSuccessfully;
extern NSString * const kClosedDatabaseSuccessfully;
extern NSString * const kFailedToOpenDatabase;
extern NSString * const kFailedToCloseDatabase;
extern NSString * const kConstraintFailed;


extern int const LABQLITE_WRAPPER_SELECT_LIMIT_NONE;

