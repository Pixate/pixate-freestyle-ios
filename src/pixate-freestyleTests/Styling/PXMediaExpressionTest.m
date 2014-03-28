//
//  PXMediaExpressionTest.m
//  Pixate
//
//  Created by Giovanni Donelli on 8/23/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PXUtils.h"
#import "PXGestalt.h"
#import "PXStylesheetParser.h"
#import "PXStylesheet.h"


@interface PXMediaExpressionTest : XCTestCase

@end

@implementation PXMediaExpressionTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}


- (void) testGestantBasics
{
    PXVersionType v1   = PXVersionFromObject(@"1");
    XCTAssertTrue( PXVersionPrimary(v1)   == 1, @"v1.primary == 1"   );
    XCTAssertTrue( PXVersionSecondary(v1) == 0, @"v1.secondary == 0" );
    XCTAssertTrue( PXVersionTertiary(v1)  == 0, @"v1.tertiary == 0"  );
    
    PXVersionType v11  = PXVersionFromString(@"1.1");
    XCTAssertTrue( PXVersionPrimary(v11)   == 1, @"v1.primary == 1"   );
    XCTAssertTrue( PXVersionSecondary(v11) == 1, @"v1.secondary == 1" );
    XCTAssertTrue( PXVersionTertiary(v11)  == 0, @"v1.tertiary == 0"  );
    
    PXVersionType v999  = PXVersionFromString(@"99.99.99");
    XCTAssertTrue( PXVersionPrimary(v999)   == 99, @"v111.primary == 99"   );
    XCTAssertTrue( PXVersionSecondary(v999) == 99, @"v111.secondary == 99" );
    XCTAssertTrue( PXVersionTertiary(v999)  == 99, @"v111.tertiary == 99"  );
    
    XCTAssertTrue( PXVersionCompare(v999, v1) > 0, @"v999 > v1" );
    XCTAssertTrue( PXVersionCompare(v1, v999) < 0, @"v999 < v1" );
    
    XCTAssertTrue( PXVersionCompare(v1, PXVersionFromString(@"1.00") ) == 0, @"v1 == 1.00" );
}

- (void) testStringVersion
{
    PXVersionType v1   = PXVersionFromObject(@"\"1\"");
    XCTAssertTrue( PXVersionPrimary(v1)   == 1, @"v1.primary == 1"   );
    XCTAssertTrue( PXVersionSecondary(v1) == 0, @"v1.secondary == 0" );
    XCTAssertTrue( PXVersionTertiary(v1)  == 0, @"v1.tertiary == 0"  );

    PXVersionType v123   = PXVersionFromObject(@"'1.2.3'");
    XCTAssertTrue( PXVersionPrimary(v123)   == 1, @"v1.primary == 1 %@", NSStringFromPXVersion(v123)   );
    XCTAssertTrue( PXVersionSecondary(v123) == 2, @"v1.secondary == 2" );
    XCTAssertTrue( PXVersionTertiary(v123)  == 3, @"v1.tertiary == 3"  );
}

- (void) testVersionMatch
{
    PXVersionType v4   = PXVersionFromString(@"4");
    PXVersionType v41  = PXVersionFromString(@"4.1");
    PXVersionType v411 = PXVersionFromString(@"4.1.1");
    PXVersionType v42  = PXVersionFromString(@"4.2");
 
    XCTAssertTrue( PXVersionMatch(v4, v4),   @"4 base should match 4"   );
    XCTAssertTrue( PXVersionMatch(v4, v41),  @"4 base should match 41"  );
    XCTAssertTrue( PXVersionMatch(v4, v411), @"4 base should match 411" );
    XCTAssertTrue( PXVersionMatch(v4, v42),  @"4 base should match 42"  );

    XCTAssertTrue( PXVersionMatch(v41, v411),  @"41 base should match 411");
    
    XCTAssertFalse( PXVersionMatch(v41, v4),  @"41 base should not match 4"  );
    XCTAssertFalse( PXVersionMatch(v411, v4), @"411 base should not match 4"  );
    XCTAssertFalse( PXVersionMatch(v42, v4),  @"42 base should not match 4"  );

    
}

- (void) testVersionCompare
{
    PXVersionType v60 = PXVersionFromObject(@"6.0");
    PXVersionType v61 = PXVersionFromObject(@"6.1");

    PXVersionType v600 = PXVersionFromObject(@"6.0.0");
    PXVersionType v601 = PXVersionFromObject(@"6.0.1");
    PXVersionType v611 = PXVersionFromObject(@"6.1.1");
    PXVersionType v612 = PXVersionFromObject(@"6.1.2");
    
    XCTAssertTrue( PXVersionCompare(v60, v61) < 0, @"6.0 < 6.1");
    XCTAssertTrue( PXVersionCompare(v61, v60) > 0, @"6.1 > 6.0");
    
    XCTAssertTrue( PXVersionCompare(v60, v600) == 0, @"6.0 == 6.0.0");
    XCTAssertTrue( PXVersionCompare(v60, v601) >= 0, @"6.0 == 6.0.1");
    
    XCTAssertTrue( PXVersionCompare(v601, v611) < 0, @"6.0.1 == 6.1.1");
    XCTAssertTrue( PXVersionCompare(v612, v611) > 0, @"6.1.2 == 6.1.1");
    
    XCTAssertTrue( PXVersionCompare(PXVersionFromObject(@"'6'"), PXVersionFromObject(@"6.0")) <= NSOrderedSame, @"6 == 6.0");
}

- (void) testVersionCompareAndrewBug
{
    //  "6.1" < "6" should return true because we intend 6 to as 6.x.x,
    // where x is anything really

    XCTAssertTrue( PXVersionCompare(PXVersionFromObject(@"'6.1'"), PXVersionFromObject(@"6")) <= NSOrderedSame, @"6.1 <= 6");
}

- (void) testSystemVersion
{
    PXVersionType sysVersion = PXVersionCurrentSystem();

    PXVersionType minVersion = PXVersionFromObject(@"1.0");
    PXVersionType maxVersion = PXVersionFromObject(@"10.0");
         
    XCTAssertTrue( PXVersionCompare(sysVersion, minVersion) > 0, @"System > 1" );

    XCTAssertTrue( PXVersionCompare(sysVersion, maxVersion) < 0, @"System < 10" );
}


- (NSString*) _systemMainVersion
{
    NSString* sysVersion = [[UIDevice currentDevice] systemVersion];
    NSArray* versionArray = [sysVersion componentsSeparatedByString:@"."];
    
    NSString* mainVersion = versionArray[0];
    
    return mainVersion;
}

- (void) testMinMaxMediaQuery
{
    NSString *emptySource = @"@media (max-device-os-version: '1') { #myButton { background-color: pink; } }";
    
    PXStylesheetParser* parser = [[PXStylesheetParser alloc] init];
    PXStylesheet* stylesheet   = [parser parse:emptySource withOrigin:PXStylesheetOriginApplication];
    XCTAssertTrue( [stylesheet.ruleSets count] == 0 , @"ruleSets count %lu", (unsigned long)[stylesheet.ruleSets count] );
    
    NSString *validSource = @"@media (max-device-os-version: '10') { #myButton { background-color: pink; } }";
    PXStylesheet* validStylesheet   = [parser parse:validSource withOrigin:PXStylesheetOriginApplication];
    XCTAssertTrue( [validStylesheet.ruleSets count] > 0 , @"ruleSets count %lu", (unsigned long)[validStylesheet.ruleSets count] );
    
    NSString *validSource2 = @"@media (min-device-os-version: '1') and (max-device-os-version: '10') { #myButton { background-color: pink; } }";
    PXStylesheet* validStylesheet2 = [parser parse:validSource2 withOrigin:PXStylesheetOriginApplication];
    XCTAssertTrue( [validStylesheet2.ruleSets count] > 0 , @"ruleSets count %lu", (unsigned long)[validStylesheet2.ruleSets count] );
    
    NSString *maxCurrentSource = [NSString stringWithFormat:@"@media (max-device-os-version: '%@') { #myButton { background-color: pink; } }", [[UIDevice currentDevice] systemVersion] ];
    PXStylesheet* maxCurrentStylesheet = [parser parse:maxCurrentSource withOrigin:PXStylesheetOriginApplication];
    XCTAssertTrue( [maxCurrentStylesheet.ruleSets count] > 0 , @"ruleSets count %lu", (unsigned long)[maxCurrentStylesheet.ruleSets count] );
}


- (void) testOSMediaQuery_StringVersion
{
    NSString* mainVersion = [self _systemMainVersion];
    
    NSString *validSource = [NSString stringWithFormat:@"@media (device-os-version: '%@') { #myButton { background-color: pink; } }", mainVersion ];
    
    PXStylesheetParser* parser = [[PXStylesheetParser alloc] init];
    PXStylesheet* validStylesheet = [parser parse:validSource withOrigin:PXStylesheetOriginApplication];
    XCTAssertTrue( [validStylesheet.ruleSets count] > 0 , @"ruleSets count %lu", (unsigned long)[validStylesheet.ruleSets count] );
    
    NSString *emptySource = @"@media (device-os-version: '1') { #myButton { background-color: pink; } }";
    
    PXStylesheet* emptyStylesheet   = [parser parse:emptySource withOrigin:PXStylesheetOriginApplication];
    XCTAssertTrue( [emptyStylesheet.ruleSets count] == 0 , @"ruleSets count %lu", (unsigned long)[emptyStylesheet.ruleSets count] );
}

- (void) testOSMediaQuery_NumberVersion
{
    NSString* sysVersion = [[UIDevice currentDevice] systemVersion];
    NSArray* versionArray = [sysVersion componentsSeparatedByString:@"."];
    
    NSString* mainVersion = versionArray[0];
    
    NSString *validSource = [NSString stringWithFormat:@"@media (device-os-version: %@) { #myButton { background-color: pink; } }", mainVersion ];
    
    PXStylesheetParser* parser = [[PXStylesheetParser alloc] init];
    PXStylesheet* validStylesheet = [parser parse:validSource withOrigin:PXStylesheetOriginApplication];
    XCTAssertTrue( [validStylesheet.ruleSets count] > 0 , @"ruleSets count %lu", (unsigned long)[validStylesheet.ruleSets count] );
    
    NSString *emptySource = @"@media (device-os-version: 1) { #myButton { background-color: pink; } }";
    
    PXStylesheet* emptyStylesheet   = [parser parse:emptySource withOrigin:PXStylesheetOriginApplication];
    XCTAssertTrue( [emptyStylesheet.ruleSets count] == 0 , @"ruleSets count %lu", (unsigned long)[emptyStylesheet.ruleSets count] );
}


#pragma mark -

- (void) testScreenRatioBasic
{
    PXScreenRatioType ratio43 = PXScreenRatioFromString(@"'4/3'");
    PXScreenRatioType ratio12 = PXScreenRatioFromObject(@" 1 / 2 ");
    
    XCTAssertTrue( ((ratio43 - 1.333) > 0) && ((ratio43 - 1.333) < 0.01), @"ratio43 == 1.333" );
    
    XCTAssertTrue(ratio12 == 0.5, @"ratio12 == 0.5" );
        
    PXScreenRatioType ratio11 = PXScreenRatioFromString(@"1/1");
    
    XCTAssertTrue( PXScreenRatioCompare(ratio11, ratio12) > 0, @"1/1 > 1/2" );
    XCTAssertTrue( PXScreenRatioCompare(ratio12, ratio11) < 0, @"1/2 < 1/1" );
    
    PXScreenRatioType ratio16_9 = PXScreenRatioFromString(@"16/9");

    XCTAssertTrue( PXScreenRatioCompare(ratio16_9, ratio11) == NSOrderedDescending, @"16/9 > 1/1" );
    
    PXScreenRatioType sysRatio = PXScreenRatioCurrentSystem();
    
    XCTAssertTrue( PXScreenRatioCompare(ratio43, ratio11) >= NSOrderedSame, @"system (ex:4/3) > 1/1" );
    
    XCTAssertTrue( PXScreenRatioCompare(sysRatio, ratio11) <= NSOrderedSame, @"system (ex:3/4) < 1/1" );
    
    PXScreenRatioType ratio1_10 = PXScreenRatioFromString(@"1/10");

    XCTAssertTrue( PXScreenRatioCompare(sysRatio, ratio1_10) >= NSOrderedSame, @"system (ex:3/4) < 1/1" );

    // 16/9 > 1/1 > 1/2
}

- (void) testScreenRatioMovieComparison
{
    // The most common movie format since the 1960s.
    // https://developer.mozilla.org/en-US/docs/Web/CSS/ratio
    
    PXScreenRatioType ratio185_100 = PXScreenRatioFromString(@"'185/100'");
    PXScreenRatioType ratio91_50   = PXScreenRatioFromString(@"'91/50'");

    NSComparisonResult compare = PXScreenRatioCompare(ratio185_100, ratio91_50);
    
    XCTAssertTrue(compare == NSOrderedSame, @" '185/100' == '91/50' " );
}


- (void) testOSMediaQuery_ScreenRatio
{    
    CGRect screenBounds =[[UIScreen mainScreen] bounds];
    
    NSString *validSource = [NSString stringWithFormat:@"@media (device-aspect-ratio: %d/%d) { #myButton { background-color: pink; } }", 
                             (int)screenBounds.size.width, 
                             (int)screenBounds.size.height];
    
    PXStylesheetParser* parser = [[PXStylesheetParser alloc] init];
    PXStylesheet* validStylesheet = [parser parse:validSource withOrigin:PXStylesheetOriginApplication];
    XCTAssertTrue( [validStylesheet.ruleSets count] > 0 , @"ruleSets count %lu", (unsigned long)[validStylesheet.ruleSets count] );

    
    NSString *minSourceTrue = [NSString stringWithFormat:@"@media (min-device-aspect-ratio: 1/10)  { #myButton { background-color: pink; } }" ];
    PXStylesheet* minStylesheetTrue = [parser parse:minSourceTrue withOrigin:PXStylesheetOriginApplication];
    XCTAssertTrue( [minStylesheetTrue.ruleSets count] > 0 , @"ruleSets count %lu", (unsigned long)[minStylesheetTrue.ruleSets count] );
    
    NSString *maxSourceFalse = [NSString stringWithFormat:@"@media (max-device-aspect-ratio: 1/10)  { #myButton { background-color: pink; } }" ];
    PXStylesheet* maxStylesheetFalse = [parser parse:maxSourceFalse withOrigin:PXStylesheetOriginApplication];
    XCTAssertFalse( [maxStylesheetFalse.ruleSets count] > 0 , @"ruleSets count %lu", (unsigned long)[maxStylesheetFalse.ruleSets count] );
    
    
    NSString *minSourceFalse = [NSString stringWithFormat:@"@media (min-device-aspect-ratio: 1/1)  { #myButton { background-color: pink; } }" ];
    PXStylesheet* minStylesheetFalse = [parser parse:minSourceFalse withOrigin:PXStylesheetOriginApplication];
    XCTAssertFalse( [minStylesheetFalse.ruleSets count] > 0 , @"ruleSets count %lu", (unsigned long)[maxStylesheetFalse.ruleSets count] );
    
    
    NSString *maxSourceTrue = [NSString stringWithFormat:@"@media (max-device-aspect-ratio: 1/1)  { #myButton { background-color: pink; } }" ];
    PXStylesheet* maxStylesheetTrue = [parser parse:maxSourceTrue withOrigin:PXStylesheetOriginApplication];
    XCTAssertTrue( [maxStylesheetTrue.ruleSets count] > 0 , @"ruleSets count %lu", (unsigned long)[maxStylesheetTrue.ruleSets count] );

    
    NSString *maxMinSource = [NSString stringWithFormat:@"@media (min-device-aspect-ratio: 1/10) and (max-device-aspect-ratio: 1/1) { #myButton { background-color: pink; } }" ];
    PXStylesheet* maxMinStylesheet = [parser parse:maxMinSource withOrigin:PXStylesheetOriginApplication];
    XCTAssertTrue( [maxMinStylesheet.ruleSets count] > 0 , @"ruleSets count %lu", (unsigned long)[maxMinStylesheet.ruleSets count] );
}


@end
