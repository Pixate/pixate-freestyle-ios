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
//  PXTransformParser.m
//  Pixate
//
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXTransformParser.h"
#import "PXTransformLexer.h"
#import "PXTransformTokenType.h"
#import "PXMath.h"
#import "PXDimension.h"

@implementation PXTransformParser
{
    PXTransformLexer *lexer;
}

#pragma mark - Statics

static NSIndexSet *TRANSFORM_KEYWORD_SET;
static NSIndexSet *ANGLE_SET;
static NSIndexSet *LENGTH_SET;
static NSIndexSet *PERCENTAGE_SET;

+ (void)initialize
{
    if (!TRANSFORM_KEYWORD_SET)
    {
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
        [set addIndex:PXTransformToken_TRANSLATE];
        [set addIndex:PXTransformToken_TRANSLATEX];
        [set addIndex:PXTransformToken_TRANSLATEY];
        [set addIndex:PXTransformToken_SCALE];
        [set addIndex:PXTransformToken_SCALEX];
        [set addIndex:PXTransformToken_SCALEY];
        [set addIndex:PXTransformToken_SKEW];
        [set addIndex:PXTransformToken_SKEWX];
        [set addIndex:PXTransformToken_SKEWY];
        [set addIndex:PXTransformToken_ROTATE];
        [set addIndex:PXTransformToken_MATRIX];
        TRANSFORM_KEYWORD_SET = set;
    }
    if (!ANGLE_SET)
    {
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
        [set addIndex:PXTransformToken_NUMBER];
        [set addIndex:PXTransformToken_ANGLE];
        ANGLE_SET = set;
    }
    if (!LENGTH_SET)
    {
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
        [set addIndex:PXTransformToken_NUMBER];
        [set addIndex:PXTransformToken_LENGTH];
        LENGTH_SET = set;
    }
    if (!PERCENTAGE_SET)
    {
        NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
        [set addIndex:PXTransformToken_NUMBER];
        [set addIndex:PXTransformToken_PERCENTAGE];
        PERCENTAGE_SET = set;
    }
}

#pragma mark - Initializers

- (id)init
{
    if (self = [super init])
    {
        self->lexer = [[PXTransformLexer alloc] init];
    }

    return self;
}

- (CGAffineTransform)parse:(NSString *)source
{
    CGAffineTransform result = CGAffineTransformIdentity;

    // clear errors
    [self clearErrors];

    // setup lexer and prime lexer stream
    lexer.source = source;
    [self advance];

    // TODO: move try/catch inside while loop after adding some error recovery
    @try
    {
        while (currentLexeme)
        {
            CGAffineTransform transform = [self parseTransform];

            result = CGAffineTransformConcat(transform, result);
        }
    }
    @catch(NSException *e)
    {
        [self addError:e.description];
    }

    return result;
}

- (CGAffineTransform) parseTransform
{
    CGAffineTransform result;

    // advance over keyword
    [self assertTypeInSet:TRANSFORM_KEYWORD_SET];
    PXStylesheetLexeme *transformType = currentLexeme;
    [self advance];

    // advance over '('
    [self assertTypeAndAdvance:PXTransformToken_LPAREN];

    switch (transformType.type)
    {
        case PXTransformToken_TRANSLATE:
            result = [self parseTranslate];
            break;

        case PXTransformToken_TRANSLATEX:
            result = [self parseTranslateX];
            break;

        case PXTransformToken_TRANSLATEY:
            result = [self parseTranslateY];
            break;

        case PXTransformToken_SCALE:
            result = [self parseScale];
            break;

        case PXTransformToken_SCALEX:
            result = [self parseScaleX];
            break;

        case PXTransformToken_SCALEY:
            result = [self parseScaleY];
            break;

        case PXTransformToken_SKEW:
            result = [self parseSkew];
            break;

        case PXTransformToken_SKEWX:
            result = [self parseSkewX];
            break;

        case PXTransformToken_SKEWY:
            result = [self parseSkewY];
            break;

        case PXTransformToken_ROTATE:
            result = [self parseRotate];
            break;

        case PXTransformToken_MATRIX:
            result = [self parseMatrix];
            break;

        default:
            result = CGAffineTransformIdentity;
            [self errorWithMessage:@"Unrecognized transform type"];
            break;

    }

    // advance over ')'
    [self advanceIfIsType:PXTransformToken_RPAREN];

    return result;
}

- (CGAffineTransform)parseMatrix
{
    CGFloat a = self.floatValue;
    CGFloat b = self.floatValue;
    CGFloat c = self.floatValue;
    CGFloat d = self.floatValue;
    CGFloat e = self.floatValue;
    CGFloat f = self.floatValue;

    return CGAffineTransformMake(a, b, c, d, e, f);
}

- (CGAffineTransform)parseRotate
{
    CGFloat angle = self.angleValue;

    if ([self isInTypeSet:LENGTH_SET])
    {
        CGFloat x = self.lengthValue;
        CGFloat y = self.lengthValue;

        CGAffineTransform result = CGAffineTransformMakeTranslation(x, y);
        result = CGAffineTransformRotate(result, angle);
        return CGAffineTransformTranslate(result, -x, -y);
    }
    else
    {
        return CGAffineTransformMakeRotation(angle);
    }
}

- (CGAffineTransform)parseScale
{
    CGFloat sx = self.floatValue;
    CGFloat sy = ([self isType:PXTransformToken_NUMBER]) ? self.floatValue : sx;

    return CGAffineTransformMakeScale(sx, sy);
}

- (CGAffineTransform)parseScaleX
{
    CGFloat sx = self.floatValue;

    return CGAffineTransformMakeScale(sx, 1.0f);
}

- (CGAffineTransform)parseScaleY
{
    CGFloat sy = self.floatValue;

    return CGAffineTransformMakeScale(1.0f, sy);
}

- (CGAffineTransform)parseSkew
{
    CGFloat sx = TAN(self.angleValue);
    CGFloat sy = ([self isInTypeSet:ANGLE_SET]) ? TAN(self.angleValue) : 0.0f;

    return CGAffineTransformMake(1.0f, sy, sx, 1.0f, 0.0f, 0.0f);
}

- (CGAffineTransform)parseSkewX
{
    CGFloat sx = TAN(self.angleValue);

    return CGAffineTransformMake(1.0f, 0.0f, sx, 1.0f, 0.0f, 0.0f);
}

- (CGAffineTransform)parseSkewY
{
    CGFloat sy = TAN(self.angleValue);

    return CGAffineTransformMake(1.0f, sy, 0.0f, 1.0f, 0.0f, 0.0f);
}

- (CGAffineTransform)parseTranslate
{
    CGFloat tx = self.lengthValue;
    CGFloat ty = ([self isInTypeSet:LENGTH_SET]) ? self.lengthValue : 0.0f;

    return CGAffineTransformMakeTranslation(tx, ty);
}

- (CGAffineTransform)parseTranslateX
{
    CGFloat tx = self.lengthValue;

    return CGAffineTransformMakeTranslation(tx, 0.0f);
}

- (CGAffineTransform)parseTranslateY
{
    CGFloat ty = self.lengthValue;

    return CGAffineTransformMakeTranslation(0.0f, ty);
}

#pragma mark - Helper Methods

- (PXStylesheetLexeme *)advance
{
    return currentLexeme = [lexer nextLexeme];
}

- (NSString *)lexemeNameFromType:(int)type
{
    PXStylesheetLexeme *lexeme = [[PXStylesheetLexeme alloc] initWithType:type text:nil];

    return lexeme.name;
}

- (CGFloat)angleValue
{
    CGFloat result = 0.0f;

    if ([self isInTypeSet:ANGLE_SET])
    {
        switch (currentLexeme.type)
        {
            case PXTransformToken_NUMBER:
            {
                NSNumber *number = currentLexeme.value;

                result = DEGREES_TO_RADIANS(number.floatValue);
                break;
            }

            case PXTransformToken_ANGLE:
            {
                PXDimension *angle = currentLexeme.value;

                result = angle.radians.number;
                break;
            }

            default:
            {
                NSString *message = [NSString stringWithFormat:@"Unrecognized token type in LENGTH_SET: %@", currentLexeme];
                [self errorWithMessage:message];
                break;
            }
        }

        [self advance];
        [self advanceIfIsType:PXTransformToken_COMMA];
    }

    return result;
}

- (CGFloat)floatValue
{
    CGFloat result = 0.0f;

    if ([self isType:PXTransformToken_NUMBER])
    {
        NSNumber *number = currentLexeme.value;

        result = number.floatValue;

        [self advance];
        [self advanceIfIsType:PXTransformToken_COMMA];
    }
    else
    {
        [self errorWithMessage:@"Expected a NUMBER token"];
    }

    return result;
}

- (CGFloat)lengthValue
{
    CGFloat result = 0.0f;

    if ([self isInTypeSet:LENGTH_SET])
    {
        switch (currentLexeme.type)
        {
            case PXTransformToken_NUMBER:
            {
                NSNumber *number = currentLexeme.value;

                result = number.floatValue;
                break;
            }

            case PXTransformToken_LENGTH:
            {
                PXDimension *length = currentLexeme.value;

                result = length.points.number;
                break;
            }

            default:
            {
                NSString *message = [NSString stringWithFormat:@"Unrecognized token type in LENGTH_SET: %@", currentLexeme];
                [self errorWithMessage:message];
                break;
            }
        }

        [self advance];
        [self advanceIfIsType:PXTransformToken_COMMA];
    }
    else
    {
        [self errorWithMessage:@"Expected a LENGTH or NUMBER token"];
    }

    return result;
}

- (CGFloat)percentageValue
{
    CGFloat result = 0.0f;

    if ([self isInTypeSet:PERCENTAGE_SET])
    {
        switch (currentLexeme.type)
        {
            case PXTransformToken_PERCENTAGE:
            {
                PXDimension *percentage = currentLexeme.value;

                result = percentage.number / 100.0f;
                break;
            }

            case PXTransformToken_NUMBER:
            {
                NSNumber *number = currentLexeme.value;

                result = number.floatValue;
                break;
            }

            default:
            {
                NSString *message = [NSString stringWithFormat:@"Unrecognized token type in PERCENTAGE_SET: %@", currentLexeme];
                [self errorWithMessage:message];
                break;
            }
        }

        [self advance];
        [self advanceIfIsType:PXTransformToken_COMMA];
    }
    else
    {
        [self errorWithMessage:@"Expected a PERCENTAGE or NUMBER token"];
    }

    return result;
}

@end
