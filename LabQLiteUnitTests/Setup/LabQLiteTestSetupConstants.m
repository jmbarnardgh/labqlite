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

#import "LabQLiteTestSetupConstants.h"

@implementation LabQLiteTestSetupConstants

- (instancetype)init {
    self = [super init];
    if (self) {
        
        // Setup values
        _bundle = [NSBundle bundleForClass:[self class]];
        
        _goodBundleDatabaseFileName = @"garden.db";
        _goodBundleDatabaseFilePath = [_bundle resourcePath];
        
        _corruptDatabaseFileName = @"corrupt.db";
        
        _goodWriteFilePath  = @"MyAwesomeDatabase/";
        _goodWriteFileName  = @"db.sqlite";
        
        
        // Database setup
        NSError *crudTestsDatabaseControllerError;
        _commonTestDatabase = [[LabQLiteDatabaseController alloc] initWithFile:_goodBundleDatabaseFileName
                                                                    sourcePath:_goodBundleDatabaseFilePath
                                                   toBeCopiedToAndUsedFromPath:_goodWriteFilePath
                                                                 writeFileName:@"commonTestDatabase"
                                         assumingNSDocumentDirectoryAsRootPath:YES
                                                                     overwrite:YES
                                                                         error:&crudTestsDatabaseControllerError];
        
        NSString *sharedDatabaseFullPath = [NSString stringWithFormat:@"%@/%@", _goodBundleDatabaseFilePath, _goodBundleDatabaseFileName];
        NSError *sharedDatabaseError;
        [LabQLiteDatabaseController activateSharedControllerWithDatabasePath:sharedDatabaseFullPath error:&sharedDatabaseError];

        // Data setup
        _goodDateString = @"2015-11-11";
        
        _butchartGardens = [Garden new];
        [_butchartGardens setGardenName:@"Butchart Gardens"];
        [_butchartGardens setAddress:@"Brentwood Bay, British Columbia, Canada"];
        [_butchartGardens setDateAdded:_goodDateString];
        
        _topiaryGardens = [Garden new];
        [_topiaryGardens setGardenName:@"Levens Hall and Gardens"];
        [_topiaryGardens setAddress:@"Cumbria (northern England)"];
        [_topiaryGardens setDateAdded:_goodDateString];
        
        _yuyuanGarden = [Garden new];
        [_yuyuanGarden setGardenName:@"Yuyuan Garden"];
        [_yuyuanGarden setAddress:@"China"];
        
        _minneapolisSculptureGarden = [Garden new];
        [_minneapolisSculptureGarden setGardenName:@"Minneapolis Sculpture Garden"];
        [_minneapolisSculptureGarden setAddress:@"Minnesota, US"];
        
        _keukenhofGardens = [Garden new];
        [_keukenhofGardens setGardenName:@"Keukenhof Gardens"];
        [_keukenhofGardens setAddress:@"The Netherlands"];
        
        _singleDatumArray = @[_butchartGardens];
        _multiDataArray = @[_butchartGardens,
                            _topiaryGardens,
                            _yuyuanGarden,
                            _minneapolisSculptureGarden,
                            _keukenhofGardens];
    }
    return self;
}


@end

