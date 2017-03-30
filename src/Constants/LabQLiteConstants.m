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

NSString * const SQLite3LogicalOperatorAND   = @"AND";
NSString * const SQLite3LogicalOperatorOR    = @"OR";
NSString * const SQLite3LogicalOperatorNOT   = @"NOT";


NSString * const SQLite3BinaryOperatorEquals     = @"=";
NSString * const SQLite3BinaryOperatorNotEquals  = @"!=";
NSString * const SQLite3BinaryOperatorLike       = @"LIKE";



NSString * const SQLITE3_LOW_LEVEL_ERROR_DOMAIN = @"SQLITE3_LOW_LEVEL_ERROR_DOMAIN";
/**
 @discussion Codes can be found in the low level src in sqlite3.h.
 The following is merely a way to objective-c-afy these codes so
 that they have an error domain and an appropriate error message NSString.
 
 More specific messages will be printed to the console
 by sqlite3.c print calls.
 */

//  corresponding NSString * const message       the message as NSString literal                                         corresponding code
//  -------------------------------     -----------------------------------------------                         ---------------------
NSString * const SQLITE_0_NO_ERROR             = @"No error.";                                                   //  corresponds to code  0
NSString * const SQLITE_1_ERROR_Message        = @"SQL error or missing database.";                              //  corresponds to code  1
NSString * const SQLITE_2_INTERNAL_Message     = @"Internal logic error in SQLite.";                             //  corresponds to code  2
NSString * const SQLITE_3_PERM_Message         = @"Access permission to database denied.";                       //  corresponds to code  3
NSString * const SQLITE_4_ABORT_Message        = @"Callback routine requested an abort.";                        //  corresponds to code  4
NSString * const SQLITE_5_BUSY_Message         = @"The database file is locked.";                                //  corresponds to code  5
NSString * const SQLITE_6_LOCKED_Message       = @"A table in the database is locked.";                          //  corresponds to code  6
NSString * const SQLITE_7_NOMEM_Message        = @"A malloc() failed.";                                          //  corresponds to code  7
NSString * const SQLITE_8_READONLY_Message     = @"Attempt to write a readonly database.";                       //  corresponds to code  8
NSString * const SQLITE_9_INTERRUPT_Message    = @"Operation terminated by sqlite3_interrupt().";                //  corresponds to code  9
NSString * const SQLITE_10_IOERR_Message       = @"Some kind of disk I/O error occurred.";                       //  corresponds to code 10
NSString * const SQLITE_11_CORRUPT_Message     = @"The database disk image is malformed.";                       //  corresponds to code 11
NSString * const SQLITE_12_NOTFOUND_Message    = @"Unknown opcode in sqlite3_file_control().";                   //  corresponds to code 12
NSString * const SQLITE_13_FULL_Message        = @"Insertion failed because database is full.";                  //  corresponds to code 13
NSString * const SQLITE_14_CANTOPEN_Message    = @"Unable to open the database file.";                           //  corresponds to code 14
NSString * const SQLITE_15_PROTOCOL_Message    = @"Database lock protocol error.";                               //  corresponds to code 15
NSString * const SQLITE_16_EMPTY_Message       = @"Database is empty.";                                          //  corresponds to code 16
NSString * const SQLITE_17_SCHEMA_Message      = @"The database schema changed.";                                //  corresponds to code 17
NSString * const SQLITE_18_TOOBIG_Message      = @"String or BLOB exceeds size limit.";                          //  corresponds to code 18
NSString * const SQLITE_19_CONSTRAINT_Message  = @"Abort due to constraint violation.";                          //  corresponds to code 19
NSString * const SQLITE_20_MISMATCH_Message    = @"Data type mismatch.";                                         //  corresponds to code 20
NSString * const SQLITE_21_MISUSE_Message      = @"Library used incorrectly.";                                   //  corresponds to code 21
NSString * const SQLITE_22_NOLFS_Message       = @"Uses OS features not supported on host.";                     //  corresponds to code 22
NSString * const SQLITE_23_AUTH_Message        = @"Authorization denied.";                                       //  corresponds to code 23
NSString * const SQLITE_24_FORMAT_Message      = @"Auxiliary database format error.";                            //  corresponds to code 24
NSString * const SQLITE_25_RANGE_Message       = @"2nd parameter to sqlite3_bind out of range.";                 //  corresponds to code 25
NSString * const SQLITE_26_NOTADB_Message      = @"File opened that is not a database file.";                    //  corresponds to code 26

// Processing Messages
NSString * const SQLITE_27_ROW_Message         = @"qlite3_step() has another row ready.";                        //  corresponds to code 27
NSString * const SQLITE_28_DONE_Message        = @"sqlite3_step() has finished executing.";                      //  corresponds to code 28


@implementation LabQLiteConstants : NSObject

+ (NSArray *)SQLITE_LOW_LVL_MSGS_ARRAY {
    return @[
      SQLITE_0_NO_ERROR,
      SQLITE_1_ERROR_Message,
      SQLITE_2_INTERNAL_Message,
      SQLITE_3_PERM_Message,
      SQLITE_4_ABORT_Message,
      SQLITE_5_BUSY_Message,
      SQLITE_6_LOCKED_Message,
      SQLITE_7_NOMEM_Message,
      SQLITE_8_READONLY_Message,
      SQLITE_9_INTERRUPT_Message,
      SQLITE_10_IOERR_Message,
      SQLITE_11_CORRUPT_Message,
      SQLITE_12_NOTFOUND_Message,
      SQLITE_13_FULL_Message,
      SQLITE_14_CANTOPEN_Message,
      SQLITE_15_PROTOCOL_Message,
      SQLITE_16_EMPTY_Message,
      SQLITE_17_SCHEMA_Message,
      SQLITE_18_TOOBIG_Message,
      SQLITE_19_CONSTRAINT_Message,
      SQLITE_20_MISMATCH_Message,
      SQLITE_21_MISUSE_Message,
      SQLITE_22_NOLFS_Message,
      SQLITE_23_AUTH_Message,
      SQLITE_24_FORMAT_Message,
      SQLITE_25_RANGE_Message,
      SQLITE_26_NOTADB_Message,
      SQLITE_27_ROW_Message,
      SQLITE_28_DONE_Message
    ];
}
@end

NSString * const kOpennedDatabaseSuccessfully = @"Database openned.";
NSString * const kClosedDatabaseSuccessfully = @"Database closed.";
NSString * const kFailedToOpenDatabase = @"SQLite3Wrapper could not open database.";
NSString * const kFailedToCloseDatabase = @"SQLite3Wrapper could not close database.";
NSString * const kConstraintFailed = @"constraint failed";


int const LABQLITE_WRAPPER_SELECT_LIMIT_NONE = -1;


