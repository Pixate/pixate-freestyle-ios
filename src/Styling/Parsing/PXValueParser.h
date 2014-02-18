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
//  PXValueParser.h
//  Pixate
//
//  Created by Kevin Lindsey on 9/3/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXParserBase.h"
#import "PXPaint.h"
#import "PXShadowPaint.h"
#import "PXOffsets.h"
#import "PXBorderInfo.h"

/**
 *  PXValueParser is responsible for converting a list of lexemes into a concrete type. Since it is possible that the
 *  same sequence of tokens may represent different concrete values, it is up to the caller to designate which type is
 *  expected from the lexeme sequence.
 */
@interface PXValueParser : PXParserBase

@property (nonatomic, strong) NSString *filename;

/**
 *  Convert a source string into an array of lexemes.
 *
 *  @param source The source to convert
 */
+ (NSArray *)lexemesForSource:(NSString *)source;

/**
 *  Convert the lexeme array to a list of animation infos, each separated by a comma
 *
 *  @param lexemes An array of lexemes to convert
 */
- (NSArray *)parseAnimationInfos:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a list of transition infos, each separated by a comma
 *
 *  @param lexemes An array of lexemes to convert
 */
- (NSArray *)parseTransitionInfos:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a list of animation directions, each separated by a comma
 *
 *  @param lexemes An array of lexemes to convert
 */
- (NSArray *)parseAnimationDirectionList:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a list of animation file modes, each separated by a comma
 *
 *  @param lexemes An array of lexemes to convert
 */
- (NSArray *)parseAnimationFillModeList:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a list of animation play states, each separated by a comma
 *
 *  @param lexemes An array of lexemes to convert
 */
- (NSArray *)parseAnimationPlayStateList:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a list of animation timing functions, each separated by a comma
 *
 *  @param lexemes An array of lexemes to convert
 */
- (NSArray *)parseAnimationTimingFunctionList:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to border properties
 */
- (PXBorderInfo *)parseBorder:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a list of radii, each represented by a CGSize
 */
- (NSArray *)parseBorderRadiusList:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a border style
 */
- (PXBorderStyle)parseBorderStyle:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a list of border styles
 */
- (NSArray *)parseBorderStyleList:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a color
 *
 *  @param lexemes An array of lexemes to convert
 */
- (UIColor *)parseColor:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a float
 *
 *  @param lexemes An array of lexemes to convert
 */
- (CGFloat)parseFloat:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a list of floats, each separated by a comma
 *
 *  @param lexemes An array of lexemes to convert
 */
- (NSArray *)parseFloatList:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a list of names, each separated by a comma
 *
 *  @param lexeme An Array of lexemes to convert
 */
- (NSArray *)parseNameList:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a paint
 *
 *  @param lexemes An array of lexemes to convert
 */
- (id<PXPaint>)parsePaint:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a list of paints, one for each side.
 */
- (NSArray *)parsePaints:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a list of seconds, each separatebed by a comma
 *
 *  @param lexemes An array of lexemes to convert
 */
- (NSArray *)parseSecondsList:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a shadow
 *
 *  @param lexemes An array of lexemes to convert
 */
- (id<PXShadowPaint>)parseShadow:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a size
 *
 *  @param lexemes An array of lexemes to convert
 */
- (CGSize)parseSize:(NSArray *)lexemes;

/**
 *  Conver the lexeme array to seconds
 *
 *  @param lexemes An Array of lexemes to convert
 */
- (CGFloat)parseSeconds:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a URL
 *
 *  @param lexemes An array of lexemes to convert
 */
- (NSURL *)parseURL:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a UIEdgeInset
 *
 *  @param lexemes An array of lexemes to convert
 */
- (UIEdgeInsets)parseInsets:(NSArray *)lexemes;

/**
 *  Convert the lexeme array to a PXOffsets
 *
 *  @param lexemes An array of lexemes to convert
 */
- (PXOffsets *)parseOffsets:(NSArray *)lexemes;

@end
