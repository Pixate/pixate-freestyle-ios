//
//  PXDOMParser.m
//  Pixate
//
//  Created by Kevin Lindsey on 11/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXDOMParser.h"
#import "PXDOMText.h"

@implementation PXDOMParser
{
    PXDOMElement *document_;
    PXDOMElement *currentElement_;
    NSString *currentNamespace_;
    NSMutableDictionary *prefixToURI_;
}

#pragma mark - Static Methods

+ (PXDOMElement *)loadFromURL:(NSURL *)URL
{
    PXDOMParser *parser = [[PXDOMParser alloc] init];
    NSData *data = [NSData dataWithContentsOfURL:URL];

    // create and init NSXMLParser object
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];
    //nsXmlParser.shouldProcessNamespaces = YES;
    //nsXmlParser.shouldReportNamespacePrefixes = YES;

    // set delegate
    [nsXmlParser setDelegate:parser];

    // parsing...
    BOOL success = [nsXmlParser parse];

    // test the result
    if (!success)
    {
        NSLog(@"Error parsing document: %@", URL);
    }

    return parser->document_;
}

#pragma mark - Helper Methods

- (void)setNamespaceURI:(NSString *)uri forPrefix:(NSString *)prefix
{
    if (prefixToURI_ == nil)
    {
        prefixToURI_ = [[NSMutableDictionary alloc] init];
    }

    [prefixToURI_ setObject:uri forKey:prefix];
}

#pragma mark - Namespace parsing

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
    [self setNamespaceURI:namespaceURI forPrefix:prefix];
}

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
    // do nothing, although we should treat each prefix as a stack and remove the last pushed URI for this prefix
}

#pragma mark - Document Parsing

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    document_ = [[PXDOMElement alloc] initWithName:@"#document"];
    currentElement_ = document_;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    // perform any necessary cleanup
    currentElement_ = nil;
}

#pragma mark - Element Parsing

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    // create element
    PXDOMElement *element = [[PXDOMElement alloc] initWithName:elementName];

    // add attributes
    for (NSString *key in attributeDict)
    {
        [element setAttributeValue:[attributeDict objectForKey:key] forName:key];
    }

    // make child of current element
    [currentElement_ addChild:element];

    // make current element
    currentElement_ = element;
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    currentElement_ = currentElement_.parent;
}

#pragma mark - Character and Comment Parsing

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    PXDOMText *text = [[PXDOMText alloc] initWithText:string];

    [currentElement_ addChild:text];
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
    // ignore?
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    // TODO: tag as CDATA
    NSString *data = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];

    if (data.length > 0)
    {
        PXDOMText *text = [[PXDOMText alloc] initWithText:data];

        [currentElement_ addChild:text];
    }
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
    // ignore?
}

// TODO: parserErrorOccurred
// TODO: validationErrorOccurred
// TODO: foundProcessingInstructionWithTarget

@end
