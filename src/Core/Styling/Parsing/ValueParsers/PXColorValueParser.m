//
//  PXColorValueParser.m
//  pixate-freestyle
//
//  Created by Paul Colton on 3/29/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXColorValueParser.h"
#import "PXStylesheetLexeme.h"
#import "PXStylesheetTokenType.h"
#import "PXLinearGradient.h"
#import "PXRadialGradient.h"
#import "PXSolidPaint.h"
#import "PXPaintGroup.h"
#import "PXDimension.h"
#import "UIColor+PXColors.h"
#import "PXShadow.h"
#import "PXShadowGroup.h"
#import "PixateFreestyle.h"
#import "PXAnimationInfo.h"
#import "PXValue.h"
#import "PXImagePaint.h"

@implementation PXColorValueParser

static NSIndexSet *COLOR_SET;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
        [set addIndex:PXSS_RGB];
        [set addIndex:PXSS_RGBA];
        [set addIndex:PXSS_HSB];
        [set addIndex:PXSS_HSBA];
        [set addIndex:PXSS_HSL];
        [set addIndex:PXSS_HSLA];
        [set addIndex:PXSS_HASH];
        [set addIndex:PXSS_IDENTIFIER];
        COLOR_SET = [set copy];
    });
}

- (BOOL)canParse
{
    return [self isInTypeSet:COLOR_SET];
}

- (id)parse
{
    UIColor *result = nil;
    
    // read a value from [0,255] or a percentage and return in range [0,1]
    CGFloat (^readByteOrPercent)(CGFloat) = ^CGFloat(CGFloat divisor) {
        CGFloat result = 0.0f;
        
        if ([self isType:PXSS_NUMBER])
        {
            NSNumber *number = (NSNumber *)self.currentLexeme.value;
            
            result = [number floatValue] / divisor;
            
            [self advance];
        }
        else if ([self isType:PXSS_PERCENTAGE])
        {
            CGFloat percent = ((PXDimension *)self.currentLexeme.value).number;
            
            result = percent / 100.0f;
            
            [self advance];
        }
        
        [self advanceIfIsType:PXSS_COMMA];
        
        return result;
    };
    
    // read a value from [0,360] or an angle and return in range [0,1]
    CGFloat (^readAngle)() = ^CGFloat() {
        CGFloat result = 0.0f;
        
        if ([self isType:PXSS_NUMBER])
        {
            NSNumber *number = (NSNumber *)self.currentLexeme.value;
            
            result = [number floatValue] / 360.0f;
            
            [self advance];
        }
        else if ([self isType:PXSS_ANGLE])
        {
            PXDimension *degrees = ((PXDimension *)self.currentLexeme.value).degrees;
            
            result = degrees.number / 360.0f;
            
            [self advance];
        }
        
        [self advanceIfIsType:PXSS_COMMA];
        
        return result;
    };
    
    switch (self.currentLexeme.type)
    {
        case PXSS_RGB:
            [self advance];
            result = [UIColor colorWithRed:readByteOrPercent(255.0f)
                                     green:readByteOrPercent(255.0f)
                                      blue:readByteOrPercent(255.0f)
                                     alpha:1.0f];
            [self assertTypeAndAdvance:PXSS_RPAREN];
            break;
            
        case PXSS_RGBA:
        {
            CGFloat r, g, b, a;
            
            [self advance];
            
            if ([self isType:PXSS_HASH])
            {
                UIColor *c = [UIColor colorWithHexString:self.currentLexeme.value];
                
                [c getRed:&r green:&g blue:&b alpha:&a];
                [self advance];
                [self advanceIfIsType:PXSS_COMMA];
            }
            else if ([self isType:PXSS_IDENTIFIER])
            {
                UIColor *c = [UIColor colorFromName:self.currentLexeme.value];
                
                [c getRed:&r green:&g blue:&b alpha:&a];
                [self advance];
                [self advanceIfIsType:PXSS_COMMA];
            }
            else
            {
                r = readByteOrPercent(255.0f);
                g = readByteOrPercent(255.0f);
                b = readByteOrPercent(255.0f);
            }
            
            a = readByteOrPercent(1.0f);
            result = [UIColor colorWithRed:r green:g blue:b alpha:a];
            
            [self assertTypeAndAdvance:PXSS_RPAREN];
            break;
        }
            
        case PXSS_HSL:
            [self advance];
            result = [UIColor colorWithHue:readAngle()
                                saturation:readByteOrPercent(255.0f)
                                 lightness:readByteOrPercent(255.0f)
                                     alpha:1.0f];
            [self assertTypeAndAdvance:PXSS_RPAREN];
            break;
            
        case PXSS_HSLA:
            [self advance];
            result = [UIColor colorWithHue:readAngle()
                                saturation:readByteOrPercent(255.0f)
                                 lightness:readByteOrPercent(255.0f)
                                     alpha:readByteOrPercent(1.0f)];
            [self assertTypeAndAdvance:PXSS_RPAREN];
            break;
            
        case PXSS_HSB:
            [self advance];
            result = [UIColor colorWithHue:readAngle()
                                saturation:readByteOrPercent(255.0f)
                                brightness:readByteOrPercent(255.0f)
                                     alpha:1.0f];
            [self assertTypeAndAdvance:PXSS_RPAREN];
            break;
            
        case PXSS_HSBA:
            [self advance];
            result = [UIColor colorWithHue:readAngle()
                                saturation:readByteOrPercent(255.0f)
                                brightness:readByteOrPercent(255.0f)
                                     alpha:readByteOrPercent(1.0f)];
            [self assertTypeAndAdvance:PXSS_RPAREN];
            break;
            
        case PXSS_HASH:
            result = [UIColor colorWithHexString:self.currentLexeme.value];
            [self advance];
            break;
            
        case PXSS_IDENTIFIER:
            result = [UIColor colorFromName:self.currentLexeme.value];
            [self advance];
            break;
            
        default:
            [self errorWithMessage:@"Expected RGB, RGBA, HSB, HSBA, HSL, HSLA, COLOR (hex color), or IDENTIFIER (named color)"];
    }
    
    return result;
}


@end
