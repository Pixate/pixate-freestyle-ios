//
//  W3CSelectorTests.m
//  Pixate
//
//  Created by Kevin Lindsey on 11/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PixateFreestyle.h"
#import "PXStyleUtils.h"
#import "PXDOMParser.h"
#import "PXDOMElement.h"
#import "PXXPath.h"
#import "PXStylesheet.h"
#import <XCTest/XCTest.h>

#import "PXLog.h"
#import "PXLoggingUtils.h"

@interface W3CSelectorTests : XCTestCase
@end

//#define WRITE_TO_DISK

@implementation W3CSelectorTests

static NSString *tempFile;

+ (void)initialize
{
    if ([self class] == [W3CSelectorTests class])
    {
        NSDictionary* env = [[NSProcessInfo processInfo] environment];
        NSString *baseDirectory = [env objectForKey:@"PROJECT_DIRECTORY"];
        NSString *relativePath = @"Frameworks/Pixate/PixateTests/Resources/W3C/Selectors Level 3/results";

        if (!baseDirectory)
        {
            baseDirectory = @"/Users/kevin/Documents/Projects/Pixate/pixate-ios-framework/";
        }

        tempFile = [NSString pathWithComponents:@[ baseDirectory, relativePath ]];
    }
}

- (PXDOMElement *)loadXMLFromFilename:(NSString *)filename
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.pixate.pixate-freestyleTests"];
    NSString *fullPath = [bundle pathForResource:filename ofType:@"xml"];
    NSURL *url = [NSURL fileURLWithPath:fullPath];

    return [PXDOMParser loadFromURL:url];
}

- (void)assertStyleForFilename:(NSString *)filename
{
    [self assertStyleForFilename:filename withErrorCount:0];
}

- (void)assertStyleForFilename:(NSString *)filename withErrorCount:(NSUInteger)errorCount
{
    PXDOMElement *titleNode = nil;
    PXDOMElement *styleNode = nil;
    __block PXDOMElement *bodyNode = nil;

    PXDOMElement *document = [self loadXMLFromFilename:filename];
    PXXPath *xpath = [[PXXPath alloc] init];

    // find title node
    NSArray *titles = [xpath findNodesFromNode:document withPath:@"//title"];

    if (titles.count > 0)
    {
        titleNode = [titles objectAtIndex:0];
    }

    // find style node
    NSArray *styles = [xpath findNodesFromNode:document withPath:@"//style"];

    if (styles.count > 0)
    {
        styleNode = [styles objectAtIndex:0];
    }

    // find test body
    NSArray *divs = [xpath findNodesFromNode:document withPath:@"//div"];

    [divs enumerateObjectsUsingBlock:^(PXDOMElement *node, NSUInteger idx, BOOL *stop) {
        NSString *className = [node attributeValueForName:@"class" withNamespace:nil];

        if ([@"testText" isEqualToString:className])
        {
            bodyNode = node;
            *stop = YES;
        }
    }];

    // grab style text
    NSString *styleText = styleNode.innerXML;

    // create stylesheet
    PXStylesheet *stylesheet = [PixateFreestyle styleSheetFromSource:styleText withOrigin:PXStylesheetOriginUser];

    if (stylesheet.errors.count == errorCount)
    {
        //[Pixate applyStylesheets];

        // perform some sanity checks
        XCTAssertNotNil(styleText, @"style should not be nil");
        XCTAssertNotNil(bodyNode, @"body should not be nil");
        XCTAssertNotNil(stylesheet, @"stylesheet should not be nil");

        if (styleText && bodyNode && stylesheet)
        {
            // create a flattened list of all nodes in the body
            NSArray *nodes = [xpath findNodesFromNode:bodyNode withPath:@"//*"];

            // and style each element node
            for (id<PXDOMNode> node in nodes)
            {
                if ([node isKindOfClass:[PXDOMElement class]])
                {
                    [PXStyleUtils updateStyleForStyleable:node];
                }
            }

            NSString *resultText = [NSString stringWithFormat:@"<test>\n\t%@\n\t%@\n\t%@\n</test>", titleNode, styleNode, bodyNode];

#ifdef WRITE_TO_DISK
            [self writeText:resultText withName:filename overwrite:NO];
#else
            NSString *fileText = [self getTextForName:[NSString stringWithFormat:@"%@-result", filename]];

            XCTAssertTrue([resultText isEqualToString:fileText], @"\n%@\ndoes not equal\n%@", resultText, fileText);
#endif
        }
    }
    else
    {
        XCTFail(@"Encountered %d parse errors, but expected %d: %@", stylesheet.errors.count, errorCount, [stylesheet.errors componentsJoinedByString:@"\n"]);
    }
}

- (NSString *)localPathForName:(NSString *)name
{
    return [NSString stringWithFormat:@"%@/%@-result.xml", tempFile, name];
}

- (void)writeText:(NSString *)text withName:(NSString *)name overwrite:(BOOL)overwrite
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *outputPath = [self localPathForName:name];

    // only create file if it doesn't exist already
    if (overwrite || ![fileManager fileExistsAtPath:outputPath])
    {
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];

        [fileManager createFileAtPath:outputPath contents:data attributes:nil];
    }
}

- (NSString *)getTextForName:(NSString *)name
{
    NSString *path = [[NSBundle bundleWithIdentifier:@"com.pixate.pixate-freestyleTests"] pathForResource:name ofType:@"xml"];

    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
}

#pragma mark - Unit Tests

/**
 * Groups of selectors
 */
- (void)test1
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-1"];
}

/**
 * Type element selectors
 */
- (void)test2
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-2"];
}

/**
 * Universal selector
 */
- (void)test3
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-3"];
}

/**
 * Universal selector (no namespaces)
 */
- (void)test3a
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-3a"];
}

/**
 * Omitted universal selector
 */
- (void)test4
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-4"];
}

/**
 * Attribute existence selector
 */
- (void)test5
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-5"];
}

/**
 * Attribute value selector
 */
- (void)test6
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-6"];
}

/**
 * Attribute multivalue selector
 */
- (void)test7
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-7"];
}

/**
 * Attribute multivalue selector
 */
- (void)test7b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-7b"];
}

/**
 * Attribute value selectors (hyphen-separated attributes)
 */
- (void)test8
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-8"];
}

/**
 * Substring matching attribute selector (beginning)
 */
- (void)test9
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-9"];
}

/**
 * Substring matching attribute selector (end)
 */
- (void)test10
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-10"];
}

/**
 * Substring matching attribute selector (contains)
 */
- (void)test11
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-11"];
}

/**
 * Class selectors
 */
- (void)test13
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-13"];
}

/**
 * More than one class selector
 */
- (void)test14
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-14"];
}

/**
 * More than one class selector
 */
- (void)test14b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-14b"];
}

/**
 * More than one class selector
 */
- (void)test14c
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-14c"];
}

/**
 * NEGATED More than one class selector
 */
- (void)test14d
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-14d"];
}

/**
 * NEGATED More than one class selector
 */
- (void)test14e
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-14e"];
}

/**
 * ID selectors
 */
- (void)test15
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-15"];
}

/**
 * Multiple ID selectors
 */
- (void)test15b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-15b"];
}

/**
 * Multiple IDs
 *
 * Treating as invalid. This test requires support for two or more of XHTML, xml:id, and DOM3 Core. It also uses
 * Javascript to alter nodes, which is required for the test to pass.
 */
/*
- (void)test15c
{
    [self assertStyleForFilename:@"css3-modsel-15c"];
    //XCTFail(@"xml:id not supported");
}
*/

/**
 * :link pseudo-class
 *
 *  Treating as invalid. We don't have a "link" concept
 */
/*
- (void)test16
{
    [self assertStyleForFilename:@"css3-modsel-16"];
    //XCTFail(@":link pseudo-class not implemented");
}
*/

/**
 * :visited pseudo-class
 *
 * Treating as invalid. We don't have a "visited" concept
 */
/*
- (void)test17
{
    [self assertStyleForFilename:@"css3-modsel-17"];
    //XCTFail(@":visited pseudo-class not implemented");
}
*/

/**
 * :hover pseudo-class
 *
 * Treating as invalid. We don't have a "hover" concept
 */
/*
- (void)test18
{
    [self assertStyleForFilename:@"css3-modsel-18"];
    //XCTFail(@":hover pseudo-class not implemented");
}
*/

/**
 * :hover pseudo-class on links
 *
 * Treating as invalid. We don't have a "hover" concept
 */
/*
- (void)test18a
{
    [self assertStyleForFilename:@"css3-modsel-18a"];
    //XCTFail(@":hover pseudo-class not implemented");
}
*/

/**
 * :hover pseudo-class
 *
 * Treating as invalid. We don't have a "hover" concept
 */
/*
- (void)test18b
{
    [self assertStyleForFilename:@"css3-modsel-18b"];
    //XCTFail(@":hover pseudo-class not implemented");
}
*/

/**
 * :hover pseudo-class on links
 *
 * Treating as invalid. We don't have a "hover" concept
 */
/*
- (void)test18c
{
    [self assertStyleForFilename:@"css3-modsel-18c"];
    //XCTFail(@":hover pseudo-class not implemented");
}
*/

/**
 * :active pseudo-class
 *
 * Treating as invalid. We don't have an "active" concept
 */
/*
- (void)test19
{
    [self assertStyleForFilename:@"css3-modsel-19"];
    //XCTFail(@":active pseudo-class not implemented");
}
*/

/**
 * :active pseudo-class on controls
 *
 * Treating as invalid. We don't have a "active" concept
 */
/*
- (void)test19b
{
    [self assertStyleForFilename:@"css3-modsel-19b"];
    //XCTFail(@":active pseudo-class not implemented");
}
*/

/**
 * :focus pseudo-class
 *
 * Treating as invalid. We don't have a "focus" concept
 */
/*
- (void)test20
{
    [self assertStyleForFilename:@"css3-modsel-20"];
    //XCTFail(@":focus pseudo-class not implemented");
}
*/

/**
 * :target pseudo-class
 *
 * Treating as invalid. We don't have a "target" concept
 */
/*
- (void)test21
{
    [self assertStyleForFilename:@"css3-modsel-21"];
    //XCTFail(@":target pseudo-class not implemented");
}
*/

/**
 * :target pseudo-class
 *
 * Treating as invalid. We don't have a "target" concept
 */
/*
- (void)test21b
{
    [self assertStyleForFilename:@"css3-modsel-21b"];
    //XCTFail(@":target pseudo-class not implemented");
}
*/

/**
 * :target pseudo-class
 *
 * Treating as invalid. We don't have a "target" concept
 */
/*
- (void)test21c
{
    [self assertStyleForFilename:@"css3-modsel-21c"];
    //XCTFail(@":target pseudo-class not implemented");
}
*/

/**
 * :lang() pseudo-class
 *
 * Treating as invalid. We don't have a "lang" concept
 */
/*
- (void)test22
{
    [self assertStyleForFilename:@"css3-modsel-22"];
    //XCTFail(@":lang() pseudo-class not implemented");
}
*/

/**
 * :enabled pseudo-class
 *
 * Treating as invalid. We don't have an "enabled" concept
 */
/*
- (void)test23
{
    [self assertStyleForFilename:@"css3-modsel-23"];
    //XCTFail(@":enabled pseudo-class not implemented");
}
*/

/**
 * :disabled pseudo-class
 *
 * Treating as invalid. We don't have a "disabled" concept
 */
/*
- (void)test24
{
    [self assertStyleForFilename:@"css3-modsel-24"];
    //XCTFail(@":disabled pseudo-class not implemented");
}
*/

/**
 * :checked pseudo-class
 *
 * Treating as invalid. We don't have a "checked" concept
 */
/*
- (void)test25
{
    [self assertStyleForFilename:@"css3-modsel-25"];
    //XCTFail(@":checked pseudo-class not implemented");
}
*/

/**
 * :root pseudo-class
 */
- (void)test27
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-27"];
}

/**
 * Impossible rules (:root:first-child, etc)
 */

- (void)test27a
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-27a"];
}

/**
 * Impossible rules (* html, * :root)
 */
- (void)test27b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-27b"];
}

/**
 * :nth-child() pseudo-class
 */
- (void)test28
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-28"];
}

/**
 * :nth-child() pseudo-class
 */
- (void)test28b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-28b"];
}

/**
 * :nth-last-child() pseudo-class
 */
- (void)test29
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-29"];
}

/**
 * :nth-last-child() pseudo-class
 */
- (void)test29b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-29b"];
}

/**
 * :nth-of-type() pseudo-class
 */
- (void)test30
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-30"];
}

/**
 * :nth-last-of-type() pseudo-class
 *
 * not supported
 */
- (void)test31
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-31"];
}

/**
 * :first-child pseudo-class
 */
- (void)test32
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-32"];
}

/**
 * :last-child pseudo-class
 */
- (void)test33
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-33"];
}

/**
 * :first-of-type pseudo-class
 */
- (void)test34
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-34"];
}

/**
 * :last-of-type pseudo-class
 */
- (void)test35
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-35"];
}

/**
 * :only-child pseudo-class
 */
- (void)test36
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-36"];
}

/**
 * :only-of-type pseudo-class
 */
- (void)test37
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-37"];
}

/**
 * ::first-line pseudo-element
 *
 * not supported
 */
/*
- (void)test38
{
    [self assertStyleForFilename:@"css3-modsel-38"];
    //XCTFail(@"::first-line pseudo-element not implemented");
}
*/

/**
 * ::first-letter pseudo-element
 *
 * not supported
 */
/*
- (void)test39
{
    [self assertStyleForFilename:@"css3-modsel-39"];
    //XCTFail(@"::first-letter pseudo-element not implemented");
}
*/

/**
 * ::first-letter pseudo-element with ::before pseudo-element
 *
 * not supported
 */
/*
- (void)test39a
{
    [self assertStyleForFilename:@"css3-modsel-39a"];
    //XCTFail(@"::first-letter pseudo-element not implemented");
}
*/

/**
 * ::first-letter pseudo-element
 *
 * not supported
 */
/*
- (void)test39b
{
    [self assertStyleForFilename:@"css3-modsel-39b"];
    //XCTFail(@"::first-letter pseudo-element not implemented");
}
*/

/**
 * ::first-letter pseudo-element with ::before pseudo-element
 *
 * not supported
 */
/*
- (void)test39c
{
    [self assertStyleForFilename:@"css3-modsel-39c"];
    //XCTFail(@"::first-letter pseudo-element not implemented");
}
*/

/**
 * ::before pseudo-element
 *
 * not supported
 */
/*
- (void)test41
{
    [self assertStyleForFilename:@"css3-modsel-41"];
    //XCTFail(@"::before pseudo-element not implemented");
}
*/

/**
 * :before pseudo-element
 *
 * not supported
 */
/*
- (void)test41a
{
    [self assertStyleForFilename:@"css3-modsel-41a"];
    //XCTFail(@"::before pseudo-element not implemented");
}
*/

/**
 * ::after pseudo-element
 *
 * not supported
 */
/*
- (void)test42
{
    [self assertStyleForFilename:@"css3-modsel-42"];
    //XCTFail(@"::after pseudo-element not implemented");
}
*/

/**
 * :after pseudo-element
 *
 * not supported
 */
/*
- (void)test42a
{
    [self assertStyleForFilename:@"css3-modsel-42a"];
    //XCTFail(@"::after pseudo-element not implemented");
}
*/

/**
 * Descendant combinator
 */
- (void)test43
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-43"];
}

/**
 * Descendant combinator
 */
- (void)test43b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-43b"];
}

/**
 * Child combinator
 */
- (void)test44
{
    // verfied
    [self assertStyleForFilename:@"css3-modsel-44"];
}

/**
 * Child combinator
 */
- (void)test44b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-44b"];
}

/**
 * Child combinator and classes
 */
- (void)test44c
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-44c"];
}

/**
 * Child combinatior and IDs
 */
- (void)test44d
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-44d"];
}

/**
 * Direct adjacent combinator
 */
- (void)test45
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-45"];
}

/**
 * Direct adjacent combinator
 */
- (void)test45b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-45b"];
}

/**
 * Direct adjacent combinator and classes
 */
- (void)test45c
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-45c"];
}

/**
 * Indirect adjacent combinator
 */
- (void)test46
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-46"];
}

/**
 * Indirect adjacent combinator
 */
- (void)test46b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-46b"];
}

/**
 * NEGATED type element selector
 */
- (void)test47
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-47"];
}

/**
 * NEGATED universal selector
 */
- (void)test48
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-48"];
}

/**
 * NEGATED omitted universal selector is forbidden
 */
- (void)test49
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-49"];
}

/**
 * NEGATED attribute existence selector
 */
- (void)test50
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-50"];
}

/**
 * NEGATED attribute value selector
 */
- (void)test51
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-51"];
}

/**
 * NEGATED attribute space-separated value selector
 */
- (void)test52
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-52"];
}

/**
 * NEGATED attribute dash-separated value selector
 */
- (void)test53
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-53"];
}

/**
 * NEGATED substring matching attribute selector on beginning
 */
- (void)test54
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-54"];
}

/**
 * NEGATED substring matching attribute selector on end
 */
- (void)test55
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-55"];
}

/**
 * NEGATED substring matching attribute selector on middle
 */
- (void)test56
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-56"];
}

/**
 * NEGATED Attribute existence selector with declared namespace
 */
- (void)test57
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-57"];
}

/**
 * NEGATED Attribute existence selector with declared namespace
 */
- (void)test57b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-57b"];
}

/**
 * NEGATED class selector
 */
- (void)test59
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-59"];
}

/**
 * NEGATED ID selector
 */
- (void)test60
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-60"];
}

/**
 * NEGATED :link pseudo-class
 */
- (void)test61
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-61"];
}

/**
 * NEGATED :visited pseudo-class
 */
- (void)test62
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-62"];
}

/**
 * NEGATED :hover pseudo-class
 */
/*
- (void)test63
{
    [self assertStyleForFilename:@"css3-modsel-63"];
    //XCTFail(@":hover pseudo-class not implemented");
}
*/

/**
 * NEGATED :active pseudo-class
 */
- (void)test64
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-64"];
}

/**
 * NEGATED :focus pseudo-class
 */
/*
- (void)test65
{
    [self assertStyleForFilename:@"css3-modsel-65"];
    //XCTFail(@":focus pseudo-class not implemented");
}
*/

/**
 * NEGATED :target pseudo-class
 */
- (void)test66
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-66"];
}

/**
 * NEGATED :target pseudo-class
 */
- (void)test66b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-66b"];
}

/**
 * NEGATED :lang() pseudo-class
 */
/*
- (void)test67
{
    [self assertStyleForFilename:@"css3-modsel-67"];
    //XCTFail(@":lang() pseudo-class not implemented");
}
*/

/**
 * NEGATED :enabled pseudo-class
 */
- (void)test68
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-68"];
}

/**
 * NEGATED :disabled pseudo-class
 */
- (void)test69
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-69"];
}

/**
 * NEGATED :checked pseudo-class
 */
- (void)test70
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-70"];
}

/**
 * NEGATED :root pseudo-class
 */
- (void)test72
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-72"];
}

/**
 * NEGATED :root pseudo-class
 */
- (void)test72b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-72b"];
}

/**
 * NEGATED :nth-child() pseudo-class
 */
- (void)test73
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-73"];
}

/**
 * NEGATED :nth-child() pseudo-class
 */
- (void)test73b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-73b"];
}

/**
 * NEGATED :nth-last-child() pseudo-class
 */
- (void)test74
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-74"];
}

/**
 * NEGATED :nth-last-child() pseudo-class
 */
- (void)test74b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-74b"];
}

/**
 * NEGATED :nth-of-type() pseudo-class
 */
- (void)test75
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-75"];
}

/**
 * NEGATED :nth-of-type() pseudo-class
 */
- (void)test75b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-75b"];
}

/**
 * NEGATED :nth-last-of-type() pseudo-class
 */
- (void)test76
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-76"];
}

/**
 * NEGATED :nth-last-of-type() pseudo-class
 */
- (void)test76b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-76b"];
}

/**
 * NEGATED :first-child pseudo-class
 */
- (void)test77
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-77"];
}

/**
 * NEGATED :first-child pseudo-class
 */
- (void)test77b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-77b"];
}

/**
 * NEGATED :last-child pseudo-class
 */
- (void)test78
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-78"];
}

/**
 * NEGATED :last-child pseudo-class
 */
- (void)test78b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-78b"];
}

/**
 * NEGATED :first-of-type pseudo-class
 */
- (void)test79
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-79"];
}

/**
 * NEGATED :last-of-type pseudo-class
 */
- (void)test80
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-80"];
}

/**
 * NEGATED :only-child pseudo-class
 */
- (void)test81
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-81"];
}

/**
 * NEGATED :only-child pseudo-class
 */
- (void)test81b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-81b"];
}

/**
 * NEGATED :only-of-type pseudo-class
 */
- (void)test82
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-82"];
}

/**
 * NEGATED :only-of-type pseudo-class
 */
- (void)test82b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-82b"];
}

/**
 * Negation pseudo-class cannot be an argument of itself
 */
- (void)test83
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-83" withErrorCount:1];
}

/**
 * Nondeterministic matching of descendant and child combinators
 */
- (void)test86
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-86"];
}

/**
 * Nondeterministic matching of direct and indirect adjacent combinators
 */
- (void)test87
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-87"];
}

/**
 * Nondeterministic matching of direct and indirect adjacent combinators
 */
- (void)test87b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-87b"];
}

/**
 * Nondeterministic matching of descendant and direct adjacent combinators
 */
- (void)test88
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-88"];
}

/**
 * Nondeterministic matching of descendant and direct adjacent combinators
 */
- (void)test88b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-88b"];
}

/**
 * Simple combination of descendant and child combinators
 */
- (void)test89
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-89"];
}

/**
 * Simple combination of direct and indirect adjacent combinators
 */
- (void)test90
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-90"];
}

/**
 * Simple combination of direct and indirect adjacent combinators
 */
- (void)test90b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-90b"];
}

/**
 * Type element selector with declared namespace
 */
- (void)test91
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-91"];
}

/**
 * Type element selector with universal namespace
 */
- (void)test92
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-92"];
}

/**
 * Type element selector without declared namespace
 */
- (void)test93
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-93"];
}

/**
 * Universal selector with declared namespace
 */
- (void)test94
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-94"];
}

/**
 * Universal selector with declared namespace
 */
- (void)test94b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-94b"];
}

/**
 * Universal selector with universal namespace
 */
- (void)test95
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-95"];
}

/**
 * Universal selector without declared namespace
 */
- (void)test96
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-96"];
}

/**
 * Universal selector without declared namespace
 */
- (void)test96b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-96b"];
}

/**
 * Attribute existence selector with declared namespace
 */
- (void)test97
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-97"];
}

/**
 * Attribute existence selector with declared namespace
 */
- (void)test97b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-97b"];
}

/**
 * Attribute value selector with declared namespace
 */
- (void)test98
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-98"];
}

/**
 * Attribute value selector with declared namespace
 */
- (void)test98b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-98b"];
}

/**
 * Attribute space-separated value selector with declared namespace
 */
- (void)test99
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-99"];
}

/**
 * Attribute space-separated value selector with declared namespace
 */
- (void)test99b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-99b"];
}

/**
 * Attribute dash-separated value selector with declared namespace
 */
- (void)test100
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-100"];
}

/**
 * Attribute dash-separated value selector with declared namespace
 */
- (void)test100b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-100b"];
}

/**
 * Substring matching attribute value selector on beginning with declared namespace
 */
- (void)test101
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-101"];
}

/**
 * Substring matching attribute value selector on beginning with declared namespace
 */
- (void)test101b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-101b"];
}

/**
 * Substring matching attribute value selector on end with declared namespace
 */
- (void)test102
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-102"];
}

/**
 * Substring matching attribute value selector on end with declared namespace
 */
- (void)test102b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-102b"];
}

/**
 * Substring matching attribute value selector on middle with declared namespace
 */
- (void)test103
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-103"];
}

/**
 * Substring matching attribute value selector on middle with declared namespace
 */
- (void)test103b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-103b"];
}

/**
 * Attribute existence selector with universal namespace
 */
- (void)test104
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-104"];
}

/**
 * Attribute existence selector with universal namespace
 */
- (void)test104b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-104b"];
}

/**
 * Attribute value selector with universal namespace
 */
- (void)test105
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-105"];
}

/**
 * Attribute value selector with universal namespace
 */
- (void)test105b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-105b"];
}

/**
 * Attribute space-separated value selector with universal namespace
 */
- (void)test106
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-106"];
}

/**
 * Attribute space-separated value selector with universal namespace
 */
- (void)test106b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-106b"];
}

/**
 * Attribute dash-separated value selector with universal namespace
 */
- (void)test107
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-107"];
}

/**
 * Attribute dash-separated value selector with universal namespace
 */
- (void)test107b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-107b"];
}

/**
 * Substring matching attribute selector on beginning with universal namespace
 */
- (void)test108
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-108"];
}

/**
 * Substring matching attribute selector on beginning with universal namespace
 */
- (void)test108b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-108b"];
}

/**
 * Substring matching attribute selector on end with universal namespace
 */
- (void)test109
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-109"];
}

/**
 * Substring matching attribute selector on end with universal namespace
 */
- (void)test109b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-109b"];
}

/**
 * Substring matching attribute selector on middle with universal namespace
 */
- (void)test110
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-110"];
}

/**
 * Substring matching attribute selector on middle with universal namespace
 */
- (void)test110b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-110b"];
}

/**
 * Attribute existence selector without declared namespace
 */
- (void)test111
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-111"];
}

/**
 * Attribute existence selector without declared namespace
 */
- (void)test111b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-111b"];
}

/**
 * Attribute value selector without declared namespace
 */

- (void)test112
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-112"];
}

/**
 * Attribute value selector without declared namespace
 */
- (void)test112b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-112b"];
}

/**
 * Attribute space-separated value selector without declared namespace
 */
- (void)test113
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-113"];
}

/**
 * Attribute space-separated value selector without declared namespace
 */
- (void)test113b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-113b"];
}

/**
 * Attribute dash-separated value selector without declared namespace
 */
- (void)test114
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-114"];
}

/**
 * Attribute dash-separated value selector without declared namespace
 */
- (void)test114b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-114b"];
}

/**
 * Substring matching attribute selector on beginning without declared namespace
 */
- (void)test115
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-115"];
}

/**
 * Substring matching attribute selector on beginning without declared namespace
 */
- (void)test115b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-115b"];
}

/**
 * Substring matching attribute selector on end without declared namespace
 */
- (void)test116
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-116"];
}

/**
 * Substring matching attribute selector on end without declared namespace
 */
- (void)test116b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-116b"];
}

/**
 * Substring matching attribute selector on middle without declared namespace
 */
- (void)test117
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-117"];
}

/**
 * Substring matching attribute selector on middle without declared namespace
 */
- (void)test117b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-117b"];
}

/**
 * NEGATED type element selector with declared namespace
 */
- (void)test118
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-118"];
}

/**
 * NEGATED type element selector with universal namespace
 */
- (void)test119
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-119"];
}

/**
 * NEGATED type element selector without declared namespace
 */
- (void)test120
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-120"];
}

/**
 * NEGATED universal selector with declared namespace
 */
- (void)test121
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-121"];
}

/**
 * NEGATED universal selector with universal namespace
 */
- (void)test122
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-122"];
}

/**
 * NEGATED universal selector with declared namespace
 */
- (void)test123
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-123"];
}

/**
 * NEGATED universal selector with declared namespace
 */
- (void)test123b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-123b"];
}

/**
 * NEGATED Attribute value selector with declared namespace
 */
- (void)test124
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-124"];
}

/**
 * NEGATED Attribute value selector with declared namespace
 */
- (void)test124b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-124b"];
}

/**
 * NEGATED Attribute space-separated value selector with declared namespace
 */
- (void)test125
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-125"];
}

/**
 * NEGATED Attribute space-separated value selector with declared namespace
 */
- (void)test125b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-125b"];
}

/**
 * NEGATED Attribute dash-separated value selector with declared namespace
 */
- (void)test126
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-126"];
}

/**
 * NEGATED Attribute dash-separated value selector with declared namespace
 */
- (void)test126b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-126b"];
}

/**
 * NEGATED Substring matching attribute value selector on beginning with declared namespace
 */
- (void)test127
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-127"];
}

/**
 * NEGATED Substring matching attribute value selector on beginning with declared namespace
 */
- (void)test127b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-127b"];
}

/**
 * NEGATED Substring matching attribute value selector on end with declared namespace
 */
- (void)test128
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-128"];
}

/**
 * NEGATED Substring matching attribute value selector on end with declared namespace
 */
- (void)test128b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-128b"];
}

/**
 * NEGATED Substring matching attribute value selector on middle with declared namespace
 */
- (void)test129
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-129"];
}

/**
 * NEGATED Substring matching attribute value selector on middle with declared namespace
 */
- (void)test129b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-129b"];
}

/**
 * NEGATED Attribute existence selector with universal namespace
 */
- (void)test130
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-130"];
}

/**
 * NEGATED Attribute existence selector with universal namespace
 */
- (void)test130b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-130b"];
}

/**
 * NEGATED Attribute value selector with universal namespace
 */
- (void)test131
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-131"];
}

/**
 * NEGATED Attribute value selector with universal namespace
 */
- (void)test131b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-131b"];
}

/**
 * NEGATED Attribute space-separated value selector with universal namespace
 */
- (void)test132
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-132"];
}

/**
 * NEGATED Attribute space-separated value selector with universal namespace
 */
- (void)test132b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-132b"];
}

/**
 * NEGATED Attribute dash-separated value selector with universal namespace
 */
- (void)test133
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-133"];
}

/**
 * NEGATED Attribute dash-separated value selector with universal namespace
 */
- (void)test133b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-133b"];
}

/**
 * NEGATED Substring matching attribute selector on beginning with universal namespace
 */
- (void)test134
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-134"];
}

/**
 * NEGATED Substring matching attribute selector on beginning with universal namespace
 */
- (void)test134b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-134b"];
}

/**
 * NEGATED Substring matching attribute selector on end with universal namespace
 */
- (void)test135
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-135"];
}

/**
 * NEGATED Substring matching attribute selector on end with universal namespace
 */
- (void)test135b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-135b"];
}

/**
 * NEGATED Substring matching attribute selector on middle with universal namespace
 */
- (void)test136
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-136"];
}

/**
 * NEGATED Substring matching attribute selector on middle with universal namespace
 */
- (void)test136b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-136b"];
}

/**
 * NEGATED Attribute existence selector without declared namespace
 */
- (void)test137
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-137"];
}

/**
 * NEGATED Attribute existence selector without declared namespace
 */
- (void)test137b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-137b"];
}

/**
 * NEGATED Attribute value selector without declared namespace
 */
- (void)test138
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-138"];
}

/**
 * NEGATED Attribute value selector without declared namespace
 */
- (void)test138b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-138b"];
}

/**
 * NEGATED Attribute space-separated value selector without declared namespace
 */
- (void)test139
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-139"];
}

/**
 * NEGATED Attribute space-separated value selector without declared namespace
 */
- (void)test139b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-139b"];
}

/**
 * NEGATED Attribute dash-separated value selector without declared namespace
 */
- (void)test140
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-140"];
}

/**
 * NEGATED Attribute dash-separated value selector without declared namespace
 */
- (void)test140b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-140b"];
}

/**
 * NEGATED Substring matching attribute selector on beginning without declared namespace
 */
- (void)test141
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-141"];
}

/**
 * NEGATED Substring matching attribute selector on beginning without declared namespace
 */
- (void)test141b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-141b"];
}

/**
 * NEGATED Substring matching attribute selector on end without declared namespace
 */
- (void)test142
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-142"];
}

/**
 * NEGATED Substring matching attribute selector on end without declared namespace
 */
- (void)test142b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-142b"];
}

/**
 * NEGATED Substring matching attribute selector on middle without declared namespace
 */
- (void)test143
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-143"];
}

/**
 * NEGATED Substring matching attribute selector on middle without declared namespace
 */
- (void)test143b
{
    //
    [self assertStyleForFilename:@"css3-modsel-143b"];
}

/**
 * NEGATED :enabled:disabled pseudo-classes
 */
/*
- (void)test144
{
    [self assertStyleForFilename:@"css3-modsel-144"];
    //XCTFail(@":enabled pseudo-class not implemented");
    //XCTFail(@":disabled pseudo-class not implemented");
}
*/

/**
 * :nth-of-type() pseudo-class with hidden elements
 */
- (void)test145a
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-145a"];
}

/**
 * :nth-of-type() pseudo-class with hidden elements
 */
- (void)test145b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-145b"];
}

/**
 * :nth-child() pseudo-class with hidden elements
 */
- (void)test146a
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-146a"];
}

/**
 * :nth-child() pseudo-class with hidden elements
 */
- (void)test146b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-146b"];
}

/**
 * :nth-last-of-type() pseudo-class with collapsed elements
 */
- (void)test147a
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-147a"];
}

/**
 * :nth-last-of-type() pseudo-class with collapsed elements
 */
- (void)test147b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-147b"];
}

/**
 * :empty pseudo-class and text
 */
- (void)test148
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-148"];
}

/**
 * :empty pseudo-class and empty elements
 */
- (void)test149
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-149"];
}

/**
 * :empty pseudo-class and empty elements
 */
- (void)test149b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-149b"];
}

/**
 * :empty pseudo-class and XML/SGML constructs
 */
- (void)test150
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-150"];
}

/**
 * :empty pseudo-class and whitespace
 */
- (void)test151
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-151"];
}

/**
 * :empty pseudo-class and elements
 */
- (void)test152
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-152"];
}

/**
 * :empty pseudo-class and CDATA
 */
- (void)test153
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-153"];
}

/**
 * Syntax and parsing
 */
- (void)test154
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-154" withErrorCount:1];
}

/**
 * Syntax and parsing
 */
- (void)test155
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-155" withErrorCount:1];
}

/**
 * Syntax and parsing
 */
- (void)test155a
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-155a" withErrorCount:1];
}

/**
 * Syntax and parsing
 */
- (void)test155b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-155b"];
}

/**
 * Syntax and parsing
 */
- (void)test155c
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-155c"];
}

/**
 * Syntax and parsing
 */
- (void)test155d
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-155d"];
}

/**
 * Syntax and parsing
 */
- (void)test156
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-156" withErrorCount:1];
}

/**
 * Syntax and parsing
 */
- (void)test156b
{
    [self assertStyleForFilename:@"css3-modsel-156b" withErrorCount:1];
}

/**
 * Syntax and parsing
 */
- (void)test156c
{
    [self assertStyleForFilename:@"css3-modsel-156c" withErrorCount:1];
}

/**
 * Syntax and parsing
 */
- (void)test157
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-157" withErrorCount:1];
}

/**
 * Syntax and parsing
 */
- (void)test158
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-158" withErrorCount:1];
}

/**
 * Syntax and parsing of new pseudo-elements
 */
/*
- (void)test159
{
    [self assertStyleForFilename:@"css3-modsel-159"];
    //XCTFail(@"::selection pseudo-element not implemented");
}
*/

/**
 * Syntax and parsing of unknown pseudo-classes
 */
- (void)test160
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-160"];
}

/**
 * Syntax and parsing of unknown pseudo-classes and pseudo-elements
 */
- (void)test161
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-161"];
}

/**
 * :first-letter with ::first-letter
 */
/*
- (void)test166
{
    [self assertStyleForFilename:@"css3-modsel-166"];
    //XCTFail(@"::first-letter pseudo-element not implemented");
}
*/

/**
 * :first-letter with ::first-letter
 */
/*
- (void)test166a
{
    [self assertStyleForFilename:@"css3-modsel-166a"];
    //XCTFail(@"::first-letter pseudo-element not implemented");
}
*/

/**
 * :first-line with ::first-line
 */
/*
- (void)test167
{
    [self assertStyleForFilename:@"css3-modsel-167"];
    //XCTFail(@"::first-letter pseudo-element not implemented");
}
*/

/**
 * :first-line with ::first-line
 */
/*
- (void)test167a
{
    [self assertStyleForFilename:@"css3-modsel-167a"];
    //XCTFail(@"::first-letter pseudo-element not implemented");
}
*/

/**
 * :before with ::before
 */
/*
- (void)test168
{
    [self assertStyleForFilename:@"css3-modsel-168"];
    //XCTFail(@"::before pseudo-element not implemented");
}
*/

/**
 * :before with ::before
 */
/*
- (void)test168a
{
    [self assertStyleForFilename:@"css3-modsel-168a"];
    //XCTFail(@"::before pseudo-element not implemented");
}
*/

/**
 * :after with ::after
 */
/*
- (void)test169
{
    [self assertStyleForFilename:@"css3-modsel-169"];
    //XCTFail(@"::after pseudo-element not implemented");
}
*/

/**
 * :after with ::after
 */
/*
- (void)test169a
{
    [self assertStyleForFilename:@"css3-modsel-169a"];
    //XCTFail(@"::after pseudo-element not implemented");
}
*/

/**
 * Long chains of selectors
 */
- (void)test170
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-170"];
}

/**
 * Long chains of selectors
 */
- (void)test170a
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-170a"];
}

/**
 * Long chains of selectors
 */
- (void)test170b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-170b"];
}

/**
 * Long chains of selectors
 */
- (void)test170c
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-170c"];
}

/**
 * Long chains of selectors
 */
- (void)test170d
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-170d"];
}

/**
 * Classes: XHTML global class attribute
 */
/*
- (void)test171
{
    [self assertStyleForFilename:@"css3-modsel-171"];
    //XCTFail(@"xhtml:class attribute not supported");
}
*/

/**
 * Namespaced attribute selectors
 */
- (void)test172a
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-172a"];
}

/**
 * Namespaced attribute selectors
 */
- (void)test172b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-172b"];
}

/**
 * Namespaced attribute selectors
 */
- (void)test173a
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-173a"];
}

/**
 * Namespaced attribute selectors
 */
- (void)test173b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-173b"];
}

/**
 * Attribute selectors with multiple attributes
 */
/*
- (void)test174a
{
    [self assertStyleForFilename:@"css3-modsel-174a"];
    //XCTFail(@"DOMElement doesn't support same named attributes");
}
*/

/**
 * NEGATED Attribute selectors with multiple attributes
 */
/*
- (void)test174b
{
    [self assertStyleForFilename:@"css3-modsel-174b"];
    //XCTFail(@"DOMElement doesn't support same named attributes");
}
*/

/**
 * Parsing: Numbers in classes
 */
- (void)test175a
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-175a" withErrorCount:1];
}

/**
 * Parsing: Numbers in classes
 */
- (void)test175b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-175b" withErrorCount:1];
}

/**
 * Parsing: Numbers in classes
 */
/*
- (void)test175c
{
    [self assertStyleForFilename:@"css3-modsel-175c"];
    //XCTFail(@"unimplemented escape sequence?");
}
*/

/**
 * Combinations: classes and IDs
 */
- (void)test176
{
    [self assertStyleForFilename:@"css3-modsel-176"];
}

/**
 * Parsing : vs ::
 */
/*
- (void)test177a
{
    [self assertStyleForFilename:@"css3-modsel-177a"];
    //XCTFail(@"::selection pseudo-element not implemented");
}
*/

/**
 * Parsing : vs ::
 */
/*
- (void)test177b
{
    [self assertStyleForFilename:@"css3-modsel-177b"];
    //XCTFail(@"::first-child pseudo-element not implemented");
}
*/

/**
 * Parsing: :not and pseudo-elements
 */
/*
- (void)test178
{
    [self assertStyleForFilename:@"css3-modsel-178"];
    //XCTFail(@"::after pseudo-element not implemented");
    //XCTFail(@"::first-line pseudo-element not implemented");
}
*/

/**
 * ::first-line on inlines
 */
/*
- (void)test179
{
    [self assertStyleForFilename:@"css3-modsel-179"];
    //XCTFail(@"::first-line pseudo-element not implemented");
}
*/

/**
 * ::first-line after <br>
 */
/*
- (void)test179a
{
    [self assertStyleForFilename:@"css3-modsel-179a"];
    //XCTFail(@"::first-line pseudo-element not implemented");
}
*/

/**
 * ::first-letter after <br>
 */
/*
- (void)test180a
{
    [self assertStyleForFilename:@"css3-modsel-180a"];
    //XCTFail(@"::first-letter pseudo-element not implemented");
}
*/

/**
 * Case sensitivity
 */
/*
- (void)test181
{
    [self assertStyleForFilename:@"css3-modsel-181"];
    //XCTFail(@"case-sensitivity failure with classes?");
}
*/

/**
 * Namespaces and \: in selectors
 */
/*
- (void)test182
{
    [self assertStyleForFilename:@"css3-modsel-182"];
    //XCTFail(@"possible parse failure with foo\:bar matching '<foo:bar...>");
}
*/

/**
 * Syntax and parsing of class selectors
 */
/*
- (void)test183
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-183" withErrorCount:3];
    //XCTFail(@"possible parse failure");
}
*/

/**
 * Ends-with attribute selector with empty value
 */
- (void)test184a
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-184a"];
}

/**
 * Starts-with attribute selector with empty value
 */
- (void)test184b
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-184b"];
}

/**
 * Contains attribute selector with empty value
 */
- (void)test184c
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-184c"];
}

/**
 * NEGATED ends-with attribute selector with empty value
 */
- (void)test184d
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-184d"];
}

/**
 * NEGATED starts-with attribute selector with empty value
 */
- (void)test184e
{
    // verified
    [self assertStyleForFilename:@"css3-modsel-184e"];
}

/**
 * NEGATED contains attribute selector with empty value
 */
- (void)test184f
{
    [self assertStyleForFilename:@"css3-modsel-184f"];
}

/**
 * NEGATED Dynamic handling of :empty
 */
/*
- (void)testD1
{
    [self assertStyleForFilename:@"css3-modsel-d1"];
    //XCTFail(@"uses javascript");
}
*/

/**
 * Dynamic handling of :empty
 */
/*
- (void)testD1b
{
    [self assertStyleForFilename:@"css3-modsel-d1b"];
    //XCTFail(@"uses javascript");
}
*/

/**
 * Dynamic handling of combinators
 */
/*
- (void)testD2
{
    [self assertStyleForFilename:@"css3-modsel-d2"];
    //XCTFail(@"uses javascript");
}
*/

/**
 * Dynamic handling of attribute selectors
 */
/*
- (void)testD3
{
    [self assertStyleForFilename:@"css3-modsel-d3"];
    //XCTFail(@"uses javascript");
}
*/

/**
 * Dynamic updating of :first-child and :last-child
 */
/*
- (void)testD4
{
    [self assertStyleForFilename:@"css3-modsel-d4"];
    //XCTFail(@"uses javascript");
}
*/

@end
