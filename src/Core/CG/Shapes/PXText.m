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
//  PXText.m
//  Pixate
//
//  Created by Kevin Lindsey on 7/2/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "PXText.h"

@implementation PXText

@synthesize origin = _origin;
@synthesize text = _text;
@synthesize fontName = _fontName;
@synthesize fontSize = _fontSize;

#pragma mark - Static Initializers

+ (id)textWithString:(NSString *)text
{
    return [[PXText alloc] initWithString:text];
}

#pragma mark - Initializers

- (id)initWithString:(NSString *)aText
{
    if (self = [super init])
    {
        self->_text = aText;
    }

    return self;
}

#pragma mark - Overrides

- (CGPathRef)newPath
{
    CGMutablePathRef path = CGPathCreateMutable();

    if (self.text.length > 0 && self.fontName)
    {
        // Create path from text
        // See: http://www.codeproject.com/KB/iPhone/Glyph.aspx
        // License: The Code Project Open License (CPOL) 1.02 http://www.codeproject.com/info/cpol10.aspx

        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef) self.fontName, self.fontSize, NULL);
        font = CTFontCreateCopyWithSymbolicTraits(font, 0.0, NULL, kCTFontBoldTrait, kCTFontBoldTrait);
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               (__bridge id)font, kCTFontAttributeName,
                               nil];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.text
                                                                         attributes:attrs];
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
        CFArrayRef runArray = CTLineGetGlyphRuns(line);

        // for each RUN
        for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
        {
            // Get FONT for this run
            CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
            CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);

            // for each GLYPH in run
            for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
            {
                // get Glyph & Glyph-data
                CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
                CGGlyph glyph;
                CGPoint position;
                CTRunGetGlyphs(run, thisGlyphRange, &glyph);
                CTRunGetPositions(run, thisGlyphRange, &position);

                // Get PATH of outline
                {
                    CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                    CGAffineTransform t = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
                    t = CGAffineTransformTranslate(t, position.x, position.y);
                    CGPathAddPath(path, &t, letter);
                    CGPathRelease(letter);
                }
            }
        }
    }

    CGPathRef resultPath = CGPathCreateCopy(path);
    CGPathRelease(path);

    return resultPath;
}

- (void)render:(CGContextRef)context
{
    CGContextSaveGState(context);

    CGContextTranslateCTM(context, self.origin.x, self.origin.y + self.fontSize);

    [super render:context];

    CGContextRestoreGState(context);
}

- (void)dealloc
{
    self->_text = nil;
    self->_fontName = nil;
}

@end
