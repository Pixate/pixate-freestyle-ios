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
//  PXStylerContext.m
//  Pixate
//
//  Created by Kevin Lindsey on 11/15/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PXStylerContext.h"
#import "PXRectangle.h"
#import "PXShadow.h"
#import "PXShadowGroup.h"
#import "PXStroke.h"
#import "PXShapeView.h"
#import "PXSolidPaint.h"
#import "PXFontRegistry.h"
#import "PXImagePaint.h"
#import "PXPaintGroup.h"
#import "PixateFreestyle.h"
#import "PXCacheManager.h"
#import "PXDeclaration.h"
#import <CoreText/CoreText.h>

static NSString *DEFAULT_FONT_NAME = @"DEFAULT";
static NSString *DEFAULT_FONT = @"Helvetica";

@implementation PXStylerContext
{
    NSMutableDictionary *properties_;
}

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        _shape = [[PXRectangle alloc] init];

        _top = MAXFLOAT;
        _left = MAXFLOAT;
        _width = 0.0f;
        _height = 0.0f;

        _boxModel = [[PXBoxModel alloc] init];
        /*
        _borderRadius = nil;
        _strokeWidth = 0.0f;
        _strokeColor = nil;
         */

        _imageSize = CGSizeZero;
        _transform = CGAffineTransformIdentity;
        _opacity = 1.0f;

        _fontName = DEFAULT_FONT_NAME;
        _fontStyle = @"normal";
        _fontWeight = @"normal";
        _fontStretch = @"normal";
        _fontSize = 16.0f;
        
        _letterSpacing = [[PXDimension alloc] initWithNumber:0 withDimension:@"px"];
    }

    return self;
}

#pragma mark - Methods

- (id)propertyValueForName:(NSString *)name
{
    return [properties_ objectForKey:name];
}

- (void)setPropertyValue:(id)value forName:(NSString *)name
{
    if (value && name)
    {
        if (properties_ == nil)
        {
            properties_ = [[NSMutableDictionary alloc] init];
        }

        [properties_ setObject:value forKey:name];
    }
}

- (int)stateFromStateNameMap:(NSDictionary *)map
{
    return ((NSNumber *)[map objectForKey:self.activeStateName]).intValue;
}

#pragma mark - Getters

- (NSString *)fontName
{
    return [DEFAULT_FONT_NAME isEqualToString:_fontName] ? DEFAULT_FONT: _fontName;
}

- (id<PXPaint>)getCombinedPaints
{
    if (_fill != nil && _imageFill != nil)
    {
        PXPaintGroup *group = [[PXPaintGroup alloc] init];

        [group addPaint:_fill];
        [group addPaint:_imageFill];

        return group;
    }
    else
    {
        return (_imageFill) ? _imageFill : _fill;
    }
}

- (UIImage *)backgroundImageWithBounds:(CGRect) bounds
{
    _bounds = bounds;
    return [self backgroundImage];
}

- (UIImage *)backgroundImage
{
    NSNumber *hashKey = [NSNumber numberWithUnsignedInteger:self.styleHash];
    UIImage *result = [PXCacheManager imageForKey:hashKey];

    if (result == nil)
    {
        // update bounds
        if (CGSizeEqualToSize(_imageSize, CGSizeZero) == NO)
        {
            _bounds = CGRectMake(0.0f, 0.0f, _imageSize.width, _imageSize.height);
        }
        else if (CGRectEqualToRect(_bounds, CGRectZero))
        {
            _bounds = self.styleable.bounds;

            if (CGSizeEqualToSize(_bounds.size, CGSizeZero) == YES)
            {
                // Set default size to 32,32 if its zero
                _bounds = CGRectMake(0.0f, 0.0f, 32.0f, 32.0f);
            }
        }

        // apply bounds
        // NOTE: this updates the bounds of the underlying geometry used to draw the background image. This does not resize
        // the styleable.
        if ([_shape conformsToProtocol:@protocol(PXBoundable)])
        {
            id<PXBoundable> boundable = (id<PXBoundable>)_shape;

            boundable.bounds = _bounds;
        }

        // apply fill
        _shape.fill = [self getCombinedPaints];

        // apply stroke, and possible modify geometry bounds
        if (_boxModel.hasBorder)
        {
            // NOTE: we're using top border since we set all borders the same right now
            CGFloat strokeWidth = _boxModel.borderTopWidth;
            id<PXPaint>strokeColor = _boxModel.borderTopPaint;
            PXStroke *stroke = [[PXStroke alloc] initWithStrokeWidth:strokeWidth];

            if (strokeColor)
            {
                stroke.color = strokeColor;
            }

            self.shape.stroke = stroke;

            // shrink bounds by half of the stroke width
            if ([_shape conformsToProtocol:@protocol(PXBoundable)])
            {
                id<PXBoundable> boundable = (id<PXBoundable>)_shape;

                boundable.bounds = CGRectInset(boundable.bounds, 0.5f * strokeWidth, 0.5f * strokeWidth);
            }
        }

        // set corner radius
        if ([self.shape isKindOfClass:[PXRectangle class]])
        {
            PXRectangle *rect = (PXRectangle *)self.shape;

            rect.radiusTopLeft = _boxModel.radiusTopLeft;
            rect.radiusTopRight = _boxModel.radiusTopRight;
            rect.radiusBottomRight = _boxModel.radiusBottomRight;
            rect.radiusBottomLeft = _boxModel.radiusBottomLeft;
        }

        // apply inner shadows
        if (_innerShadow.shadows.count > 0)
        {
            _shape.shadow = _innerShadow;
        }

        // generate image
        BOOL isOpaque = [self isOpaque];
        result = [_shape renderToImageWithBounds:_bounds withOpacity:isOpaque];

        if (_padding.hasOffset)
        {
            CGFloat x = _bounds.origin.x + _padding.left;
            CGFloat y = _bounds.origin.y + _padding.top;
            CGFloat width = _bounds.size.width - _padding.left - _padding.right;
            CGFloat height = _bounds.size.height - _padding.top - _padding.bottom;

            UIGraphicsBeginImageContextWithOptions(_bounds.size, isOpaque, 0.0);
            [result drawInRect:CGRectMake(x, y, width, height)];
            result = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }

        // apply insets, if we have any
        if (!UIEdgeInsetsEqualToEdgeInsets(_insets, UIEdgeInsetsZero))
        {
            result = [result resizableImageWithCapInsets:_insets];
        }

        if (PixateFreestyle.configuration.cacheImages)
        {
            // estimate cost as number of pixels times 4 bytes per pixel. This is probably lower than actual
            NSUInteger cost = result.size.width * result.size.height * 4;

            [PXCacheManager setImage:result forKey:hashKey cost:cost];
        }
    }

    return result;
}

- (BOOL)isOpaque
{
    // TODO: what about padding?

    return
        (_opacity == 1.0f)
    &&  _boxModel.isOpaque
    &&  (_fill != nil && _fill.isOpaque)
    &&  (_imageFill != nil && _imageFill.isOpaque);
}

- (UIFont *)font
{
    UIFont *result = nil;

    // TODO: allow for a list of font families
    if (self.fontName)
    {
        result = [PXFontRegistry fontWithFamily:self.fontName
                                          fontStretch:self.fontStretch
                                           fontWeight:self.fontWeight
                                            fontStyle:self.fontStyle
                                                 size:self.fontSize];

        // TODO: we need to determine the system font name and then try looking up that family with all of the above
        // settings. Since that font family is known to exist (assuming we looked it up correctly), then we will get
        // a closest match variant of that family
        if (!result)
        {
            result = [UIFont systemFontOfSize:self.fontSize];
        }
    }

    return result;
}

- (BOOL)isDefaultFont
{
    return [_fontName isEqualToString:DEFAULT_FONT_NAME];
}

- (void)setDefaultFont:(UIFont *)font
{
    self.fontName = font.familyName;
    self.fontSize = font.pointSize;
    
    CTFontRef ref = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    CTFontSymbolicTraits traits = CTFontGetSymbolicTraits(ref);
    
    BOOL isBold = ((traits & kCTFontBoldTrait) == kCTFontBoldTrait);
    self.fontWeight = isBold ? @"bold" : @"normal";
    
    BOOL isItalic = ((traits & kCTFontItalicTrait) == kCTFontItalicTrait);
    self.fontStyle = isItalic ? @"italic" : @"normal";
}

- (void)applyOuterShadowToLayer:(CALayer *)layer
{
    if (_outerShadow.shadows.count > 0)
    {
        PXShadow *shadow = [[_outerShadow shadows] objectAtIndex:0];

        layer.shadowColor = shadow.color.CGColor;
        layer.shadowOpacity = 1.0f;
        layer.shadowOffset = CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset);
        layer.shadowRadius = shadow.blurDistance;
        layer.masksToBounds = NO;
    }
    else
    {
        layer.shadowColor = [UIColor clearColor].CGColor;
        layer.shadowOpacity = 0.0f;
        layer.shadowOffset = CGSizeZero;
        layer.shadowRadius = 0.0f;
    }
}

#pragma mark - Setters

- (void)setShadow:(id<PXShadowPaint>)shadow
{
    _shadow = shadow;

    if (_shadow)
    {
        _innerShadow = [[PXShadowGroup alloc] init];
        _outerShadow = [[PXShadowGroup alloc] init];

        if ([_shadow isKindOfClass:[PXShadow class]])
        {
            PXShadow *shadow = _shadow;

            if (shadow.inset)
            {
                [_innerShadow addShadowPaint:shadow];
            }
            else
            {
                [_outerShadow addShadowPaint:shadow];
            }
        }
        else if ([_shadow isKindOfClass:[PXShadowGroup class]])
        {
            PXShadowGroup *shadowGroup = _shadow;

            for (id<PXShadowPaint> shadowPaint in shadowGroup.shadows)
            {
                if ([shadowPaint isKindOfClass:[PXShadow class]])
                {
                    PXShadow *shadow = shadowPaint;

                    if (shadow.inset)
                    {
                        [_innerShadow addShadowPaint:shadow];
                    }
                    else
                    {
                        [_outerShadow addShadowPaint:shadow];
                    }
                }
                // TODO: handle nested groups, but these won't occur from our parser
            }
        }
    }
    else
    {
        _innerShadow = _outerShadow = nil;
    }
}

- (BOOL)usesColorOnly
{
    BOOL result = NO;

    // self.color is non-nil if we have a fill that is a solid paint, only
    if (self.color)
    {
        BOOL isRectangle = (!_shape || ([_shape class] == [PXRectangle class]));

        result =
                isRectangle
            &&  (_innerShadow.count == 0)
            && (_boxModel.hasCornerRadius == NO)
            && _boxModel.hasBorder == NO
            && _imageFill == nil;
    }

    return result;
}

- (UIColor *)color
{
    if ([_fill isKindOfClass:[PXSolidPaint class]])
    {
        return ((PXSolidPaint *)_fill).color;
    }
    else
    {
        return nil;
    }
}

- (BOOL)usesImage
{
    BOOL isRectangle = (!_shape || ([_shape class] == [PXRectangle class]));

    return (
            _imageFill != nil               // we have an image reference, which requires rendering
        || (_fill && self.color == nil)     // only non-solid fills require rendering
        || (_innerShadow.count > 0)         // we render inner shadows
        || !isRectangle                     // non-rectangular shapes require rendering
        || _boxModel.hasCornerRadius        // if we got here, we're a rectangle, but rounding requires rendering
        || _boxModel.hasBorder              // borders require rendering
    );
}

+ (NSString *)transformString:(NSString *)value usingAttribute:(NSString *)attribute
{
    NSString *result = value ? value : @"";
    if(attribute)
    {
        if ([@"uppercase" isEqualToString:attribute])
        {
            result = [value uppercaseString];
        }
        else if ([@"lowercase" isEqualToString:attribute])
        {
            result = [value lowercaseString];
        }
        else if ([@"capitalize" isEqualToString:attribute])
        {
            result = [value capitalizedString];
        }
    }
    return result;
}

+ (NSNumber *)kernPointsFrom:(PXDimension *)dimension usingFont:(UIFont *)font
{
    NSNumber *result = @0.0;
    if(dimension)
    {
        if(dimension.type == kDimensionTypeEms)
        {
            result = @(font.pointSize * dimension.number);
        }
        else if(dimension.type == kDimensionTypePercentage)
        {
            result = @(font.pointSize * dimension.number / 100.0);
        }
        else // points
        {
            result = @(dimension.points.number);
        }
    }
    return result;
}

+ (void)addDecoration:(NSString *)decoration toAttributes:(NSMutableDictionary *)attributes
{
    if(decoration)
    {
        if ([@"underline" isEqualToString:decoration])
        {
            [attributes setObject:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
        }
        else if ([@"overline" isEqualToString:decoration])
        {
            // not supported by NSAttributedString
        }
        else if ([@"line-through" isEqualToString:decoration])
        {
            [attributes setObject:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) forKey:NSStrikethroughStyleAttributeName];
        }
        else if ([@"letterpress" isEqualToString:decoration])
        {
            [attributes setObject:NSTextEffectLetterpressStyle forKey:NSTextEffectAttributeName];
        }
    }
}

- (NSDictionary *) mergeTextAttributes:(NSDictionary *)originalAttributes
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:originalAttributes];
    [attributes setObject:self.font forKey:NSFontAttributeName];

    NSNumber *kern = [PXStylerContext kernPointsFrom:self.letterSpacing usingFont:self.font];
    [attributes setObject:kern forKey:NSKernAttributeName];
    
    if([self propertyValueForName:@"color"] )
    {
        [attributes setObject:(UIColor *)[self propertyValueForName:@"color"]  forKey:NSForegroundColorAttributeName];
    }
    
    [PXStylerContext addDecoration:self.textDecoration toAttributes:attributes];
    if(self.text)
    {
        self.transformedText = [PXStylerContext transformString:self.text usingAttribute:self.textTransform];
    }
    return attributes.copy;
}

- (NSMutableDictionary *) attributedTextAttributes:(UIView *)view withDefaultText:(NSString *)defaultText andColor:(UIColor *)defaultColor
{
    UIFont *font;
    if([self isDefaultFont] && view && [view respondsToSelector:@selector(font)] && [view performSelector:@selector(font)])
    {
        font = (UIFont *)[view performSelector:@selector(font)];
        [self setDefaultFont:font];
    }
    else
    {
        font = self.font;
    }
    
    NSNumber *kern = [PXStylerContext kernPointsFrom:self.letterSpacing usingFont:font];
    id color = [self propertyValueForName:@"color"] ? (UIColor *)[self propertyValueForName:@"color"] : defaultColor;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       font, NSFontAttributeName,
                                       color, NSForegroundColorAttributeName,
                                       kern, NSKernAttributeName,
                                       nil];
    
    [PXStylerContext addDecoration:self.textDecoration toAttributes:attributes];
    
    NSString *text = self.text ? self.text : defaultText;
    
    if(text) // convert to uppercase etc
    {
        text = [PXStylerContext transformString:text usingAttribute:self.textTransform];
        self.transformedText = text;
    }
    
    return attributes;
}

#pragma mark - Override

- (void)dealloc
{
    properties_ = nil;
    _innerShadow = nil;
    _outerShadow = nil;
    _activeStateName = nil;
    _shape = nil;
}

@end
