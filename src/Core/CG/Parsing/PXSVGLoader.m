/*
 * Copyright 2012-present Pixate, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  PXSVGLoader.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/4/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXSVGLoader.h"
#import "PXTransformParser.h"
#import "PXValueParser.h"
#import "PXGraphics.h"
#import "NSScanner+PXFloat.h"
#import "PixateFreestyle.h"

@implementation PXSVGLoader
{
    PXShapeDocument *document;
    PXShapeGroup *result;
    NSMutableArray *stack;
    NSMutableDictionary *startHandlers, *endHandlers;
    PXGradient *currentGradient;
    NSMutableDictionary *gradients;
    NSDictionary *alignTypes;
#ifdef PXTEXT_SUPPORT
    PXText *currentTextElement;
#endif
}

static Class loaderClass;
static PXTransformParser *TRANSFORM_PARSER;
static PXValueParser *VALUE_PARSER;

#pragma mark - Static methods

+ (void)initialize
{
    if (TRANSFORM_PARSER == nil)
    {
        TRANSFORM_PARSER = [[PXTransformParser alloc] init];
    }
    if (VALUE_PARSER == nil)
    {
        VALUE_PARSER = [[PXValueParser alloc] init];
    }
}

+ (Class)loaderClass
{
    return loaderClass;
}

+ (void)setLoaderClass:(Class)class
{
    loaderClass = class;
}

#pragma mark - Static Methods

+ (PXShapeDocument *) loadFromURL:(NSURL *)URL
{
    NSData *data = [NSData dataWithContentsOfURL:URL];

    // create and init NSXMLParser object
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];
    
    // create and init our delegate
    Class loader = (loaderClass) ? loaderClass : [PXSVGLoader class];
    PXSVGLoader *parser = [[loader alloc] init];
    
    // save reference to URL for errors
    parser.URL = URL;
    
    // set delegate
    [nsXmlParser setDelegate:parser];
    
    // parsing...
    BOOL success = [nsXmlParser parse];
    
    // test the result
    if (!success)
    {
        //        [parser logErrorMessageWithFormat:@"Error parsing document: %@", URL];
    }
    
    PXShapeDocument *document = parser->document;
    document.shape = parser->result;
    
    return document;
}

+ (PXShapeDocument *) loadFromData:(NSData *)data
{
    // create and init NSXMLParser object
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];

    // create and init our delegate
    Class loader = (loaderClass) ? loaderClass : [PXSVGLoader class];
    PXSVGLoader *parser = [[loader alloc] init];

    // set delegate
    [nsXmlParser setDelegate:parser];

    // parsing...
    BOOL success = [nsXmlParser parse];

    // test the result
    if (!success)
    {
//        [parser logErrorMessageWithFormat:@"Error parsing document: %@", URL];
    }

    PXShapeDocument *document = parser->document;
    document.shape = parser->result;

    return document;
}

#pragma mark - Initializers

-(id)init
{
    self = [super init];

    if (self)
    {
        document = [[PXShapeDocument alloc] init];
        stack = [[NSMutableArray alloc] init];
        currentGradient = nil;
        gradients = [NSMutableDictionary dictionary];

        startHandlers = [[NSMutableDictionary alloc] init];
        [self addStartSelector:@selector(startSVGElement:) forElement:@"svg"];
        [self addStartSelector:@selector(startGElement:) forElement:@"g"];
        [self addStartSelector:@selector(startPathElement:) forElement:@"path"];
        [self addStartSelector:@selector(startRectElement:) forElement:@"rect"];
        [self addStartSelector:@selector(startLineElement:) forElement:@"line"];
        [self addStartSelector:@selector(startCircleElement:) forElement:@"circle"];
        [self addStartSelector:@selector(startEllipseElement:) forElement:@"ellipse"];
        [self addStartSelector:@selector(startLinearGradientElement:) forElement:@"linearGradient"];
        [self addStartSelector:@selector(startRadialGradientElement:) forElement:@"radialGradient"];
        [self addStartSelector:@selector(startStopElement:) forElement:@"stop"];
        [self addStartSelector:@selector(startPolygonElement:) forElement:@"polygon"];
        [self addStartSelector:@selector(startPolylineElement:) forElement:@"polyline"];
        [self addStartSelector:@selector(startTextElement:) forElement:@"text"];
        [self addStartSelector:@selector(startArcElement:) forElement:@"arc"];
        [self addStartSelector:@selector(startPieElement:) forElement:@"pie"];

        // these aren't actually implemented but they are so common, we add handlers to prevent warnings
        [self addStartSelector:@selector(ignoreElement:) forElement:@"desc"];
        [self addStartSelector:@selector(ignoreElement:) forElement:@"defs"];

        endHandlers = [[NSMutableDictionary alloc] init];
        [self addEndSelector:@selector(endSVGElement) forElement:@"svg"];
        [self addEndSelector:@selector(endGElement) forElement:@"g"];
        [self addEndSelector:@selector(endGradientElement) forElement:@"linearGradient"];
        [self addEndSelector:@selector(endGradientElement) forElement:@"radialGradient"];
        [self addEndSelector:@selector(endTextElement) forElement:@"text"];

        // view port alignment type map
        alignTypes = @{
            @"none"     : @(kAlignViewPortNone),
            @"xMinYMin" : @(kAlignViewPortXMinYMin),
            @"xMinYMid" : @(kAlignViewPortXMinYMid),
            @"xMinYMax" : @(kAlignViewPortXMinYMax),
            @"xMidYMin" : @(kAlignViewPortXMidYMin),
            @"xMidYMid" : @(kAlignViewPortXMidYMid),
            @"xMidYMax" : @(kAlignViewPortXMidYMax),
            @"xMaxYMin" : @(kAlignViewPortXMaxYMin),
            @"xMaxYMid" : @(kAlignViewPortXMaxYMid),
            @"xMaxYMax" : @(kAlignViewPortXMaxYMax)
        };
    }

    return self;
}

- (void)addEndSelector:(SEL)selector forElement:(NSString *)elementName
{
    [endHandlers setValue:[NSValue valueWithPointer:selector] forKey:elementName];
}

- (void)addStartSelector:(SEL)selector forElement:(NSString *)elementName
{
    [startHandlers setValue:[NSValue valueWithPointer:selector] forKey:elementName];
}

#pragma mark - Parsing Methods

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    NSValue *selectorPointer = [startHandlers valueForKey:elementName];

    if (selectorPointer)
    {
        SEL selector = [selectorPointer pointerValue];

        // merge style properties with attribute values. Style declarations override attributes
        NSString *style = [attributeDict objectForKey:@"style"];

        if (style)
        {
            NSMutableDictionary *newAttributeDict = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
            NSArray *declarations = [style componentsSeparatedByString:@";"];

            for (NSString *declaration in declarations)
            {
                NSArray *parts = [declaration componentsSeparatedByString:@":"];

                if (parts.count == 2)
                {
                    NSString *name = [[parts objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSString *value = [[parts objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                    [newAttributeDict setObject:value forKey:name];
                }
                // else warn?
            }

            attributeDict = newAttributeDict;
        }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:selector withObject:attributeDict];
#pragma clang diagnostic pop
    }
    else
    {
        [self logErrorMessageWithFormat:@"An error was encountered while loading '%@'\n  Unsupported element type: '%@'", self.URL, elementName];
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
#if DYNAMIC
    NSValue *selectorPointer = [endHandlers valueForKey:elementName];

    if (selectorPointer)
    {
        SEL selector = [selectorPointer pointerValue];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:selector];
#pragma clang diagnostic pop
    }
#else
    if ([@"svg" isEqualToString:elementName])
    {
        [self endSVGElement];
    }
    else if ([@"g" isEqualToString:elementName])
    {
        [self endGElement];
    }
    else if ([@"linearGradient" isEqualToString:elementName])
    {
        [self endGradientElement];
    }
    else if ([@"radialGradient" isEqualToString:elementName])
    {
        [self endGradientElement];
    }
    else if ([@"text" isEqualToString:elementName])
    {
        [self endTextElement];
    }
#endif
}

#pragma mark - Start Handlers

- (void)startSVGElement:(NSDictionary *)attributeDict
{
    PXShapeGroup *newGroup = [[PXShapeGroup alloc] init];

    // see if we have a viewBox
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    CGFloat width;
    CGFloat height;

    NSString *viewBox = [attributeDict objectForKey:@"viewBox"];
    NSArray *parts = [viewBox componentsSeparatedByString:@" "];

    // set viewport
    if (parts.count == 4)
    {
        x = [[parts objectAtIndex:0] floatValue];
        y = [[parts objectAtIndex:1] floatValue];
        width = [[parts objectAtIndex:2] floatValue];
        height = [[parts objectAtIndex:3] floatValue];

        // NOTE: we ignore any specified width/height on this branch because the view containing
        // this SVG will have it's own width and height. We probably shouldn't do that, but so
        // far, that is working OK
    }
    else
    {
        // default to specified width and height. X and Y will be zero in this case
        width = [self numberFromString:[attributeDict objectForKey:@"width"]];
        height = [self numberFromString:[attributeDict objectForKey:@"height"]];
    }

    newGroup.viewport = CGRectMake(x, y, width, height);

    // set viewport settings, if we have those
    [self applyViewport:attributeDict forGroup:newGroup];

    // create top-level group
    [stack addObject:newGroup];
}

- (void)startGElement:(NSDictionary *)attributeDict
{
    // create nested group
    PXShapeGroup *newGroup = [[PXShapeGroup alloc] init];

    // TODO: set all inherited properties
    newGroup.opacity = [self opacityFromString:[attributeDict objectForKey:@"opacity"]];

    // id
    NSString *ident = [attributeDict objectForKey:@"id"];

    if (ident)
    {
        [document addShape:newGroup forName:ident];
    }

    // transform
    newGroup.transform = [self transformFromString:[attributeDict objectForKey:@"transform"]];

    // set viewport settings, if we have those
    [self applyViewport:attributeDict forGroup:newGroup];

    // add group as child of active group
    [self addShape:newGroup];

    // push new group as active group
    [stack addObject:newGroup];
}

- (void)startPathElement:(NSDictionary *)attributeDict
{
    // add path to current group
    NSString *d = [attributeDict objectForKey:@"d"];

    if (d)
    {
        PXPath *path = [PXPath createPathFromPathData:d];

        [self applyStyles:attributeDict forShape:path];
        [self addShape:path];
    }
}

- (void)startRectElement:(NSDictionary *)attributeDict
{
    // add path to current group
    CGFloat x = [self numberFromString:[attributeDict objectForKey:@"x"]];
    CGFloat y = [self numberFromString:[attributeDict objectForKey:@"y"]];
    CGFloat width = [self numberFromString:[attributeDict objectForKey:@"width"]];
    CGFloat height = [self numberFromString:[attributeDict objectForKey:@"height"]];
    CGFloat rx = [self numberFromString:[attributeDict objectForKey:@"rx"]];
    CGFloat ry = [self numberFromString:[attributeDict objectForKey:@"ry"]];

    PXRectangle *rectangle = [[PXRectangle alloc] initWithRect:CGRectMake(x, y, width, height)];
    rectangle.cornerRadii = CGSizeMake(rx, ry);

    [self applyStyles:attributeDict forShape:rectangle];
    [self addShape:rectangle];
}

- (void)startLineElement:(NSDictionary *)attributeDict
{
    CGFloat x1 = [self numberFromString:[attributeDict objectForKey:@"x1"]];
    CGFloat y1 = [self numberFromString:[attributeDict objectForKey:@"y1"]];
    CGFloat x2 = [self numberFromString:[attributeDict objectForKey:@"x2"]];
    CGFloat y2 = [self numberFromString:[attributeDict objectForKey:@"y2"]];

    PXLine *line = [[PXLine alloc] initX1:x1 y1:y1 x2:x2 y2:y2];

    [self applyStyles:attributeDict forShape:line];
    [self addShape:line];
}

- (void)startCircleElement:(NSDictionary *)attributeDict
{
    CGFloat cx = [self numberFromString:[attributeDict objectForKey:@"cx"]];
    CGFloat cy = [self numberFromString:[attributeDict objectForKey:@"cy"]];
    CGFloat r = [self numberFromString:[attributeDict objectForKey:@"r"]];

    PXCircle *circle = [[PXCircle alloc] initCenter:CGPointMake(cx, cy) radius:r];

    [self applyStyles:attributeDict forShape:circle];
    [self addShape:circle];
}

- (void)startEllipseElement:(NSDictionary *)attributeDict
{
    CGFloat cx = [self numberFromString:[attributeDict objectForKey:@"cx"]];
    CGFloat cy = [self numberFromString:[attributeDict objectForKey:@"cy"]];
    CGFloat rx = [self numberFromString:[attributeDict objectForKey:@"rx"]];
    CGFloat ry = [self numberFromString:[attributeDict objectForKey:@"ry"]];

    PXEllipse *ellipse = [[PXEllipse alloc] initCenter:CGPointMake(cx, cy) radiusX:rx radiusY:ry];

    [self applyStyles:attributeDict forShape:ellipse];
    [self addShape:ellipse];
}

- (void)startLinearGradientElement:(NSDictionary *)attributeDict
{
    NSString *name = [attributeDict objectForKey:@"id"];

    if (name)
    {
        CGFloat x1 = [self numberFromString:[attributeDict objectForKey:@"x1"]];
        CGFloat y1 = [self numberFromString:[attributeDict objectForKey:@"y1"]];
        CGFloat x2 = [self numberFromString:[attributeDict objectForKey:@"x2"]];
        CGFloat y2 = [self numberFromString:[attributeDict objectForKey:@"y2"]];
        NSString *gradientUnits = [attributeDict objectForKey:@"gradientUnits"];
        CGAffineTransform transform = [self transformFromString:[attributeDict objectForKey:@"gradientTransform"]];

        PXLinearGradient *gradient = [[PXLinearGradient alloc] init];
        gradient.p1 = CGPointMake(x1, y1);
        gradient.p2 = CGPointMake(x2, y2);
        gradient.transform = transform;

        if ([@"userSpaceOnUse" isEqualToString:gradientUnits])
        {
            gradient.gradientUnits = PXGradientUnitsUserSpace;
        }
        else
        {
            // assume all non-valid values in addition to "objectBoundingBox" mean bounding box
            gradient.gradientUnits = PXGradientUnitsBoundingBox;
        }

        currentGradient = gradient;
        [gradients setValue:currentGradient forKey:name];
    }
    else
    {
        [self logErrorMessageWithFormat:@"Skipping unnamed linear gradient"];
    }
}

- (void)startRadialGradientElement:(NSDictionary *)attributeDict
{
    NSString *name = [attributeDict objectForKey:@"id"];

    if (name)
    {
        CGFloat cx = [self numberFromString:[attributeDict objectForKey:@"cx"]];
        CGFloat cy = [self numberFromString:[attributeDict objectForKey:@"cy"]];
        CGFloat radius = [self numberFromString:[attributeDict objectForKey:@"r"]];
        NSString *fxString = [attributeDict objectForKey:@"fx"];
        NSString *fyString = [attributeDict objectForKey:@"fy"];
        NSString *gradientUnits = [attributeDict objectForKey:@"gradientUnits"];
        CGAffineTransform transform = [self transformFromString:[attributeDict objectForKey:@"gradientTransform"]];

        PXRadialGradient *gradient = [[PXRadialGradient alloc] init];
        gradient.endCenter = CGPointMake(cx, cy);
        gradient.radius = radius;
        gradient.transform = transform;

        if ([@"userSpaceOnUse" isEqualToString:gradientUnits])
        {
            gradient.gradientUnits = PXGradientUnitsUserSpace;
        }
        else
        {
            // assume all non-valid values in addition to "objectBoundingBox" mean bounding box
            gradient.gradientUnits = PXGradientUnitsBoundingBox;
        }

        if (fxString && fyString)
        {
            gradient.startCenter = CGPointMake([self numberFromString:fxString], [self numberFromString:fyString]);
        }
        else
        {
            gradient.startCenter = gradient.endCenter;
        }

        currentGradient = gradient;
        [gradients setValue:currentGradient forKey:name];
    }
    else
    {
        [self logErrorMessageWithFormat:@"Skipping unnamed radial gradient"];
    }
}

- (void)startStopElement:(NSDictionary *)attributeDict
{
    if (currentGradient)
    {
        CGFloat offset = [self numberFromString:[attributeDict objectForKey:@"offset"]];
        NSString *stopColorString = [attributeDict objectForKey:@"stop-color"];

        if (stopColorString)
        {
            NSString *stopOpacityString = [attributeDict objectForKey:@"stop-opacity"];
            UIColor *stopColor = [VALUE_PARSER parseColor:[PXValueParser lexemesForSource:stopColorString]];

            if (stopOpacityString != nil && stopColor != nil)
            {
                stopColor = [stopColor colorWithAlphaComponent:[self numberFromString:stopOpacityString]];
            }

            [currentGradient addColor:stopColor withOffset:offset];
        }
        else
        {
            [self logErrorMessageWithFormat:@"Stop element is missing a stop-color"];
        }
    }
    else
    {
        [self logErrorMessageWithFormat:@"Skipping stop element since it is not contained within a gradient element"];
    }
}

- (void)startPolygonElement:(NSDictionary *)attributeDict
{
    PXPolygon *polygon = [self makePolygon:[attributeDict objectForKey:@"points"]];

    polygon.closed = YES;

    [self applyStyles:attributeDict forShape:polygon];
    [self addShape:polygon];
}

- (void)startPolylineElement:(NSDictionary *)attributeDict
{
    PXPolygon *polygon = [self makePolygon:[attributeDict objectForKey:@"points"]];

    polygon.closed = NO;

    [self applyStyles:attributeDict forShape:polygon];
    [self addShape:polygon];
}

- (void)startTextElement:(NSDictionary *)attributeDict
{
#ifdef PXTEXT_SUPPORT
    CGFloat x = [self numberFromString:[attributeDict objectForKey:@"x"]];
    CGFloat y = [self numberFromString:[attributeDict objectForKey:@"y"]];

    PXText *text = [[PXText alloc] init];

    text.origin = CGPointMake(x, y);

    [self applyStyles:attributeDict forShape:text];
    [self addShape:text];

    currentTextElement = text;
#endif
}

- (void)startArcElement:(NSDictionary *)attributeDict
{
    CGFloat cx = [self numberFromString:[attributeDict objectForKey:@"cx"]];
    CGFloat cy = [self numberFromString:[attributeDict objectForKey:@"cy"]];
    CGFloat r = [self numberFromString:[attributeDict objectForKey:@"r"]];
    CGFloat startAngle = [self numberFromString:[attributeDict objectForKey:@"start-angle"]];
    CGFloat endAngle = [self numberFromString:[attributeDict objectForKey:@"end-angle"]];

    PXArc *arc = [[PXArc alloc] init];
    arc.center = CGPointMake(cx, cy);
    arc.radius = r;
    arc.startingAngle = startAngle;
    arc.endingAngle = endAngle;

    [self applyStyles:attributeDict forShape:arc];
    [self addShape:arc];
}

- (void)startPieElement:(NSDictionary *)attributeDict
{
    CGFloat cx = [self numberFromString:[attributeDict objectForKey:@"cx"]];
    CGFloat cy = [self numberFromString:[attributeDict objectForKey:@"cy"]];
    CGFloat r = [self numberFromString:[attributeDict objectForKey:@"r"]];
    CGFloat startAngle = [self numberFromString:[attributeDict objectForKey:@"start-angle"]];
    CGFloat endAngle = [self numberFromString:[attributeDict objectForKey:@"end-angle"]];

    PXPie *pie = [[PXPie alloc] init];
    pie.center = CGPointMake(cx, cy);
    pie.radius = r;
    pie.startingAngle = startAngle;
    pie.endingAngle = endAngle;

    [self applyStyles:attributeDict forShape:pie];
    [self addShape:pie];
}

- (void)ignoreElement:(NSDictionary *)attributeDict
{
    // Do nothing. This is to prevent common warnings for elements we don't support yet
}

#pragma mark - End Handlers

- (void)endSVGElement
{
    result = [stack objectAtIndex:0];
    [stack removeObjectAtIndex:0];
}

- (void)endGElement
{
    [stack removeObject:[stack lastObject]];
}

- (void)endGradientElement
{
    currentGradient = nil;
}

- (void)endTextElement
{
#ifdef PXTEXT_SUPPORT
    // TODO: grab accumulated text and assigned to text element
    currentTextElement.text = @"Professional!";
    currentTextElement = nil;
#endif
}

#pragma mark - Supporting Methods

- (void) addShape:(PXShape *)shape
{
    PXShapeGroup *group = [stack lastObject];

    [group addShape:shape];
}

- (void)applyStyles:(NSDictionary *)attributeDict forShape:(PXShape *)shape
{
    NSString *strokeDashArray = [attributeDict objectForKey:@"stroke-dasharray"];
    NSString *fillColor = [attributeDict objectForKey:@"fill"];

    shape.opacity = [self opacityFromString:[attributeDict objectForKey:@"opacity"]];

    // fill
    if (!fillColor)
    {
        fillColor = @"#000000";
    }

    shape.fill = [self paintFromString:fillColor withOpacityString:[attributeDict objectForKey:@"fill-opacity"]];

    // stroke
    PXStroke *stroke = [[PXStroke alloc] init];

    NSString *strokeType = [attributeDict objectForKey:@"stroke-type"];

    if (strokeType)
    {
        if ([@"inner" isEqualToString:strokeType])
        {
            stroke.type = kStrokeTypeInner;
        }
        else if ([@"outer" isEqualToString:strokeType])
        {
            stroke.type = kStrokeTypeOuter;
        }
        // else use default
    }

    stroke.color = [self paintFromString:[attributeDict objectForKey:@"stroke"] withOpacityString:[attributeDict objectForKey:@"stroke-opacity"]];
    stroke.width = [self numberFromString:[attributeDict objectForKey:@"stroke-width"]];

    if (strokeDashArray)
    {
        NSMutableArray *dashes = [self numberArrayFromString:strokeDashArray];

        stroke.dashArray = [NSArray arrayWithArray:dashes];
    }

    stroke.dashOffset = [self numberFromString:[attributeDict objectForKey:@"stroke-dashoffset"]];
    stroke.lineCap = [self lineCapFromString:[attributeDict objectForKey:@"stroke-linecap"]];
    stroke.lineJoin = [self lineJoinFromString:[attributeDict objectForKey:@"stroke-linejoin"]];

    NSString *miterLimit = [attributeDict objectForKey:@"stroke-miterlimit"];
    stroke.miterLimit = (miterLimit) ? [self numberFromString:miterLimit] : 4.0;

    shape.stroke = stroke;

    // visibility
    NSString *visibility = [attributeDict objectForKey:@"visibility"];

    if (visibility)
    {
        shape.visible = [@"visible" isEqualToString:visibility];
    }

    // id
    NSString *ident = [attributeDict objectForKey:@"id"];

    if (ident)
    {
        [document addShape:shape forName:ident];
    }

    // transform
    shape.transform = [self transformFromString:[attributeDict objectForKey:@"transform"]];
}

- (void)applyViewport:(NSDictionary *)attributeDict forGroup:(PXShapeGroup *)group
{
    NSString *par = [attributeDict objectForKey:@"preserveAspectRatio"];

    if (par)
    {
        NSArray *parts = [par componentsSeparatedByString:@" "];
        NSUInteger partCount = [parts count];
        AlignViewPortType alignment = kAlignViewPortXMidYMid;
        CropType crop = kCropTypeMeet;

        if ( 1 <= partCount && partCount <= 2)
        {
            NSString *alignmentString = [parts objectAtIndex: 0];
            NSNumber *typeNumber = [alignTypes objectForKey:alignmentString];

            if (typeNumber)
            {
                alignment = [typeNumber intValue];
            }
            else
            {
                [self logErrorMessageWithFormat:@"Unrecognized aspect ratio crop setting: %@", alignmentString];
            }

            if (partCount == 2)
            {
                NSString *cropString = [parts objectAtIndex:1];

                if ([@"meet" isEqualToString:cropString])
                {
                    crop = kCropTypeMeet;
                }
                else if ([@"slice" isEqualToString:cropString])
                {
                    crop = kCropTypeSlice;
                }
                else
                {
                    [self logErrorMessageWithFormat:@"Unrecognized crop type: %@", cropString];
                }
            }
            else
            {
                [self logErrorMessageWithFormat:@"Unrecognized preserveAspectRatio value: %@", par];
            }
        }

        group.viewportAlignment = alignment;
        group.viewportCrop = crop;
    }
}

- (CGLineCap)lineCapFromString:(NSString *)attributeValue
{
    CGLineCap lineCap = kCGLineCapButt;

    if (attributeValue)
    {
        if ([attributeValue isEqualToString:@"butt"])
        {
            lineCap = kCGLineCapButt;
        }
        else if ([attributeValue isEqualToString:@"round"])
        {
            lineCap = kCGLineCapRound;
        }
        else if ([attributeValue isEqualToString:@"square"])
        {
            lineCap = kCGLineCapSquare;
        }
        else
        {
            [self logErrorMessageWithFormat:@"Unrecognized line cap: %@", attributeValue];
        }
    }

    return lineCap;
}

- (CGLineJoin)lineJoinFromString:(NSString *)attributeValue
{
    CGLineJoin lineJoin = kCGLineJoinMiter;

    if (attributeValue)
    {
        if ([attributeValue isEqualToString:@"miter"])
        {
            lineJoin = kCGLineJoinMiter;
        }
        else if ([attributeValue isEqualToString:@"round"])
        {
            lineJoin = kCGLineJoinRound;
        }
        else if ([attributeValue isEqualToString:@"bevel"])
        {
            lineJoin = kCGLineJoinBevel;
        }
        else
        {
            [self logErrorMessageWithFormat:@"Unrecognized line join: %@", attributeValue];
        }
    }

    return lineJoin;
}

- (CGFloat)opacityFromString:(NSString *)opacityValue
{
    return (opacityValue) ? [opacityValue floatValue] : 1.0;
}

- (PXPolygon *)makePolygon:(NSString *)pointString
{
    NSMutableArray *coords = [self numberArrayFromString:pointString];
    NSUInteger length = [coords count];

    if ((length % 2) == 1) length--;

    NSMutableArray *points = [NSMutableArray arrayWithCapacity:length / 2];

    for (int i = 0; i < length; i += 2)
    {
        CGFloat x = [[coords objectAtIndex:i] floatValue];
        CGFloat y = [[coords objectAtIndex:i + 1] floatValue];

        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }

    return [[PXPolygon alloc] initWithPoints:[NSArray arrayWithArray:points]];
}

- (id<PXPaint>)paintFromString:(NSString *)attributeValue withOpacityString:(NSString *)opacityValue
{
    id<PXPaint> paint = nil;

    if (attributeValue)
    {
        CGFloat alpha = [self opacityFromString:opacityValue];

        if ([attributeValue isEqualToString:@"none"])
        {
            paint = [[PXSolidPaint alloc] initWithColor:[UIColor clearColor]];
        }
        else if ([attributeValue hasPrefix:@"#"])
        {
            UIColor *color = [UIColor colorWithHexString:attributeValue withAlpha:alpha];

            paint = [[PXSolidPaint alloc] initWithColor:color];
        }
        else if ([attributeValue hasPrefix:@"url(#"])
        {
            NSUInteger startingIndex = 5;
            NSUInteger endingIndex = [attributeValue length] - 1;

            NSString *name = [attributeValue substringWithRange:NSMakeRange(startingIndex, endingIndex - startingIndex)];

            paint = [gradients objectForKey:name];
        }
        else
        {
            paint = [VALUE_PARSER parsePaint:[PXValueParser lexemesForSource:attributeValue]];

            /*
            UIColor *color = [UIColor colorFromName:attributeValue];

            if (color)
            {
                paint = [[PXSolidPaint alloc] initWithColor:color];
            }
            */
        }
    }

    return paint;
}

- (CGFloat)numberFromString:(NSString *)attributeValue
{
    CGFloat number = 0.0;

    if (attributeValue)
    {
        if ([attributeValue hasSuffix:@"px"])
        {
            number = [[attributeValue substringToIndex:attributeValue.length - 2] floatValue];
        }
        else if ([attributeValue hasSuffix:@"%"])
        {
            number = [[attributeValue substringToIndex:attributeValue.length - 1] floatValue] / 100.0;
        }
        else
        {
            number = [attributeValue floatValue];
        }
    }

    return number;
}

- (NSMutableArray *)numberArrayFromString:(NSString *)attributeValue
{
    NSMutableArray *numbers = [NSMutableArray array];
    NSScanner *scanner = [NSScanner scannerWithString:attributeValue];
    NSCharacterSet *skipSet = [NSCharacterSet characterSetWithCharactersInString:@" \r\n,"];
    CGFloat value;
    [scanner setCharactersToBeSkipped:skipSet];

    while (1)
    {
        if ([scanner scanCGFloat:&value])
        {
            [numbers addObject:[NSNumber numberWithFloat:value]];
        }
        else
        {
            break;
        }
    }

    return numbers;
}

- (CGAffineTransform)transformFromString:(NSString *)attributeValue
{
    CGAffineTransform transform = CGAffineTransformIdentity;

    if (attributeValue)
    {
        transform = [TRANSFORM_PARSER parse:attributeValue];
    }

    return transform;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // ignore text for now
}

- (void)logErrorMessageWithFormat:(NSString *)format, ...
{
	va_list args;

	if (format)
	{
		va_start(args, format);

		NSString *message = [[NSString alloc] initWithFormat:format arguments:args];

        [PixateFreestyle.configuration sendParseMessage:message];

        va_end(args);
	}
}

@end
