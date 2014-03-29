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
//  PXStylesheetParser.m
//  Pixate
//
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXStylesheetParser.h"
#import "PXStylesheetLexeme.h"
#import "PXStylesheetTokenType.h"
#import "PXDeclaration.h"
#import "PXIdSelector.h"
#import "PXClassSelector.h"
#import "PXNotPseudoClass.h"
#import "PXPseudoClassSelector.h"
#import "PXAttributeSelectorOperator.h"
#import "PXAttributeSelector.h"
#import "NSMutableArray+StackAdditions.h"
#import "PXCombinator.h"
#import "PXAdjacentSiblingCombinator.h"
#import "PXChildCombinator.h"
#import "PXDescendantCombinator.h"
#import "PXSiblingCombinator.h"
#import "PXPseudoClassPredicate.h"
#import "PXPseudoClassFunction.h"
#import "PXFileUtils.h"
#import "PXNamedMediaExpression.h"
#import "PXMediaExpressionGroup.h"
#import "PixateFreestyle.h"
#import "PXKeyframeBlock.h"
#import "PXFontRegistry.h"

void css_lexer_set_source(NSString *source);
PXStylesheetLexeme *css_lexer_get_lexeme();
void css_lexer_delete_buffer();

@implementation PXStylesheetParser
{
    PXStylesheet *currentStyleSheet_;
    PXTypeSelector *currentSelector_;
    NSMutableArray *activeImports_;
    NSString *source_;
}

#ifdef PX_LOGGING
static int ddLogLevel = LOG_LEVEL_WARN;

+ (int)ddLogLevel
{
    return ddLogLevel;
}

+ (void)ddSetLogLevel:(int)logLevel
{
    ddLogLevel = logLevel;
}
#endif

#pragma mark - Statics

static NSIndexSet *SELECTOR_SEQUENCE_SET;
static NSIndexSet *SELECTOR_OPERATOR_SET;
static NSIndexSet *SELECTOR_SET;
static NSIndexSet *TYPE_SELECTOR_SET;
static NSIndexSet *SELECTOR_EXPRESSION_SET;
static NSIndexSet *TYPE_NAME_SET;
static NSIndexSet *ATTRIBUTE_OPERATOR_SET;
static NSIndexSet *DECLARATION_DELIMITER_SET;
static NSIndexSet *KEYFRAME_SELECTOR_SET;
static NSIndexSet *NAMESPACE_SET;
static NSIndexSet *IMPORT_SET;
static NSIndexSet *QUERY_VALUE_SET;
static NSIndexSet *ARCHAIC_PSEUDO_ELEMENTS_SET;

+ (void)initialize
{
    if (!TYPE_NAME_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:PXSS_IDENTIFIER];
        [set addIndex:PXSS_STAR];
        TYPE_NAME_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!TYPE_SELECTOR_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndexes:TYPE_NAME_SET];
        [set addIndex:PXSS_PIPE]; // namespace operator
        TYPE_SELECTOR_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!SELECTOR_EXPRESSION_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:PXSS_ID];
        [set addIndex:PXSS_CLASS];
        [set addIndex:PXSS_LBRACKET];
        [set addIndex:PXSS_COLON];
        [set addIndex:PXSS_NOT_PSEUDO_CLASS];
        [set addIndex:PXSS_LINK_PSEUDO_CLASS];
        [set addIndex:PXSS_VISITED_PSEUDO_CLASS];
        [set addIndex:PXSS_HOVER_PSEUDO_CLASS];
        [set addIndex:PXSS_ACTIVE_PSEUDO_CLASS];
        [set addIndex:PXSS_FOCUS_PSEUDO_CLASS];
        [set addIndex:PXSS_TARGET_PSEUDO_CLASS];
        [set addIndex:PXSS_LANG_PSEUDO_CLASS];
        [set addIndex:PXSS_ENABLED_PSEUDO_CLASS];
        [set addIndex:PXSS_CHECKED_PSEUDO_CLASS];
        [set addIndex:PXSS_INDETERMINATE_PSEUDO_CLASS];
        [set addIndex:PXSS_ROOT_PSEUDO_CLASS];
        [set addIndex:PXSS_NTH_CHILD_PSEUDO_CLASS];
        [set addIndex:PXSS_NTH_LAST_CHILD_PSEUDO_CLASS];
        [set addIndex:PXSS_NTH_OF_TYPE_PSEUDO_CLASS];
        [set addIndex:PXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS];
        [set addIndex:PXSS_FIRST_CHILD_PSEUDO_CLASS];
        [set addIndex:PXSS_LAST_CHILD_PSEUDO_CLASS];
        [set addIndex:PXSS_FIRST_OF_TYPE_PSEUDO_CLASS];
        [set addIndex:PXSS_LAST_OF_TYPE_PSEUDO_CLASS];
        [set addIndex:PXSS_ONLY_CHILD_PSEUDO_CLASS];
        [set addIndex:PXSS_ONLY_OF_TYPE_PSEUDO_CLASS];
        [set addIndex:PXSS_EMPTY_PSEUDO_CLASS];
        SELECTOR_EXPRESSION_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!SELECTOR_OPERATOR_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:PXSS_PLUS];
        [set addIndex:PXSS_GREATER_THAN];
        [set addIndex:PXSS_TILDE];
        SELECTOR_OPERATOR_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!SELECTOR_SEQUENCE_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndexes:TYPE_SELECTOR_SET];
        [set addIndexes:SELECTOR_EXPRESSION_SET];
        [set addIndexes:SELECTOR_OPERATOR_SET];
        SELECTOR_SEQUENCE_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!SELECTOR_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndexes:TYPE_SELECTOR_SET];
        [set addIndexes:SELECTOR_EXPRESSION_SET];
        SELECTOR_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!ATTRIBUTE_OPERATOR_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:PXSS_STARTS_WITH];
        [set addIndex:PXSS_ENDS_WITH];
        [set addIndex:PXSS_CONTAINS];
        [set addIndex:PXSS_EQUAL];
        [set addIndex:PXSS_LIST_CONTAINS];
        [set addIndex:PXSS_EQUALS_WITH_HYPHEN];
        ATTRIBUTE_OPERATOR_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!DECLARATION_DELIMITER_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:PXSS_SEMICOLON];
        [set addIndex:PXSS_RCURLY];
        DECLARATION_DELIMITER_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!KEYFRAME_SELECTOR_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:PXSS_IDENTIFIER];
        [set addIndex:PXSS_PERCENTAGE];
        KEYFRAME_SELECTOR_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!NAMESPACE_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:PXSS_STRING];
        [set addIndex:PXSS_URL];
        NAMESPACE_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!IMPORT_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:PXSS_STRING];
        [set addIndex:PXSS_URL];
        IMPORT_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!QUERY_VALUE_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:PXSS_IDENTIFIER];
        [set addIndex:PXSS_NUMBER];
        [set addIndex:PXSS_LENGTH];
        [set addIndex:PXSS_STRING];
        QUERY_VALUE_SET = set;
    }

    if (!ARCHAIC_PSEUDO_ELEMENTS_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:PXSS_FIRST_LINE_PSEUDO_ELEMENT];
        [set addIndex:PXSS_FIRST_LETTER_PSEUDO_ELEMENT];
        [set addIndex:PXSS_BEFORE_PSEUDO_ELEMENT];
        [set addIndex:PXSS_AFTER_PSEUDO_ELEMENT];
        ARCHAIC_PSEUDO_ELEMENTS_SET = set;
    }
}

#pragma mark - Methods

// level 0

- (PXStylesheet *)parse:(NSString *)source withOrigin:(PXStylesheetOrigin)origin filename:(NSString *)name
{
    // add the source file name to prevent @imports from importing it as well
    [self addImportName:name];

    // parse
    PXStylesheet *result = [self parse:source withOrigin:origin];

    // associate file path on resulting stylesheet
    result.filePath = name;

    return result;
}

- (PXStylesheet *)parse:(NSString *)source withOrigin:(PXStylesheetOrigin)origin
{
    // clear errors
    [self clearErrors];

    // create stylesheet
    currentStyleSheet_ = [[PXStylesheet alloc] initWithOrigin:origin];

    // setup lexer and prime it
    source_ = source;
    css_lexer_set_source((source != nil) ? source : @"");
    [self advance];

    @try
    {
        while (currentLexeme && currentLexeme.type != PXSS_EOF)
        {
            id<PXLexeme> startingLexeme = currentLexeme;

            switch (currentLexeme.type)
            {
                case PXSS_IMPORT:
                    [self parseImport];
                    break;

                case PXSS_NAMESPACE:
                    [self parseNamespace];
                    break;

                case PXSS_KEYFRAMES:
                    [self parseKeyframes];
                    break;

                case PXSS_MEDIA:
                    [self parseMedia];
                    break;

                case PXSS_FONT_FACE:
                    [self parseFontFace];
                    break;

                default:
                    // TODO: check for valid tokens to error out sooner?
                    [self parseRuleSet];
                    break;
            }

            if (currentLexeme == startingLexeme)
            {
                [self errorWithMessage:@"The stylesheet parser has stalled at %@. Exiting to prevent an infinite loop"];
            }
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }
    @finally
    {
        source_ = nil;
        css_lexer_delete_buffer();
    }

    // clear out any import refs
    activeImports_ = nil;

    return currentStyleSheet_;
}

- (PXStylesheet *)parseInlineCSS:(NSString *)css
{
    // clear errors
    [self clearErrors];

    // create stylesheet
    self->currentStyleSheet_ = [[PXStylesheet alloc] initWithOrigin:PXStylesheetOriginInline];

    // setup lexer and prime it
    source_ = css;
    css_lexer_set_source((css != nil) ? css : @"");
//    [lexer_ increaseNesting];
    [self advance];

    @try
    {
        // build placeholder rule set
        PXRuleSet *ruleSet = [[PXRuleSet alloc] init];

        // parse declarations
        NSArray *declarations = [self parseDeclarations];

        // add declarations to rule set
        for (PXDeclaration *declaration in declarations)
        {
            [ruleSet addDeclaration:declaration];
        }

        // save rule set
        [currentStyleSheet_ addRuleSet:ruleSet];
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }
    @finally
    {
        source_ = nil;
        css_lexer_delete_buffer();
    }

    return self->currentStyleSheet_;
}

- (id<PXSelector>)parseSelectorString:(NSString *)source
{
    id<PXSelector> result = nil;

    // clear errors
    [self clearErrors];

    // setup lexer and prime it
    source_ = source;
    css_lexer_set_source((source != nil) ? source : @"");
    [self advance];

    @try
    {
        result = [self parseSelector];
    }
    @catch (NSException *e) {
        [self addError:e.description];
    }
    @finally
    {
        source_ = nil;
        css_lexer_delete_buffer();
    }

    return result;
}

// level 1

- (void)parseFontFace
{
    [self assertTypeAndAdvance:PXSS_FONT_FACE];

    // process declaration block
    if ([self isType:PXSS_LCURLY])
    {
        NSArray *declarations = [self parseDeclarationBlock];

        // TODO: we probably shouldn't load font right here
        for (PXDeclaration *declaration in declarations)
        {
            if ([@"src" isEqualToString:declaration.name])
            {
                [PXFontRegistry loadFontFromURL:declaration.URLValue];
            }
        }
    }
}

- (void)parseImport
{
    [self assertTypeAndAdvance:PXSS_IMPORT];
    [self assertTypeInSet:IMPORT_SET];

    NSLog(@"@import temporarily disabled");
    [self advanceIfIsType:PXSS_SEMICOLON];

//    NSString *path = nil;
//
//    switch (currentLexeme.type)
//    {
//        case PXSS_STRING:
//        {
//            NSString *string = currentLexeme.value;
//
//            if (string.length > 2)
//            {
//                path = [string substringWithRange:NSMakeRange(1, string.length - 2)];
//            }
//
//            break;
//        }
//
//        case PXSS_URL:
//            path = currentLexeme.value;
//            break;
//    }
//
//    if (path)
//    {
//        // advance over @import argument
//        [self advance];
//
//        // calculate resource name and file extension
//        NSString *pathMinusExtension = [path stringByDeletingPathExtension];
//        NSString *extension = [[path pathExtension] lowercaseString];
//        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:pathMinusExtension ofType:extension];
//
//        if (![activeImports_ containsObject:bundlePath])
//        {
//            // we need to go ahead and process the trailing semicolon so we have the corrent lexeme in case we push it
//            // below
//            [self advance];
//
//            [self addImportName:bundlePath];
//
//            NSString *source = [PXFileUtils sourceFromResource:pathMinusExtension ofType:extension];
//
//            if (source.length > 0)
//            {
//                [lexer_ pushLexeme:currentLexeme];
//                [lexer_ pushSource:source];
//                [self advance];
//            }
//        }
//        else
//        {
//            NSString *message
//                = [NSString stringWithFormat:@"@import cycle detected trying to import '%@':\n%@ ->\n%@", path, [activeImports_ componentsJoinedByString:@" ->\n"], bundlePath];
//
//            [self addError:message];
//
//            // NOTE: we do this here so we'll still have the current file on the active imports stack. This handles the
//            // case of a file ending with an @import statement, causing advance to pop it from the active imports stack
//            [self advance];
//        }
//    }
}

- (void)parseMedia
{
    [self assertTypeAndAdvance:PXSS_MEDIA];

    // TODO: support media types, NOT, and ONLY. Skipping for now
    while ([self isType:PXSS_IDENTIFIER])
    {
        [self advance];
    }

    // 'and' may appear here
    [self advanceIfIsType:PXSS_AND];

    // parse optional expressions
    if ([self isType:PXSS_LPAREN])
    {
        [self parseMediaExpressions];
    }

    // parse body
    if ([self isType:PXSS_LCURLY])
    {
        @try
        {
            [self advance];

            while (currentLexeme && ![self isType:PXSS_RCURLY])
            {
                [self parseRuleSet];
            }

            [self advanceIfIsType:PXSS_RCURLY withWarning:@"Expected @media body closing curly brace"];
        }
        @finally
        {
            // reset active media query to none
            currentStyleSheet_.activeMediaQuery = nil;
        }
    }
}

- (void)parseRuleSet
{
    NSArray *selectors;

    // parse selectors
    @try
    {
        selectors = [self parseSelectorGroup];
    }
    @catch (NSException *e)
    {
        // emit error
        [self addError:e.description];

        // use flag to indicate we have no selectors
        selectors = @[ [NSNull null] ];

        // advance to '{'
        [self advanceToType:PXSS_LCURLY];
    }

    // here for error recovery
    if (![self isType:PXSS_LCURLY])
    {
        [self addError:@"Expected a left curly brace to begin a declaration block"];

        // advance to '{'
        [self advanceToType:PXSS_LCURLY];
    }

    // parse declaration block
    if ([self isType:PXSS_LCURLY])
    {
        NSArray *declarations = [self parseDeclarationBlock];

        for (id selector in selectors)
        {
            // build rule set
            PXRuleSet *ruleSet = [[PXRuleSet alloc] init];

            // add selector
            if (selector != [NSNull null])
            {
                [ruleSet addSelector:selector];
            }

            for (PXDeclaration *declaration in declarations)
            {
                [ruleSet addDeclaration:declaration];
            }

            // save rule set
            [currentStyleSheet_ addRuleSet:ruleSet];
        }
    }
}

- (void)parseKeyframes
{
    // advance over '@keyframes'
    [self assertTypeAndAdvance:PXSS_KEYFRAMES];

    // grab keyframe name
    [self assertType:PXSS_IDENTIFIER];
    PXKeyframe *keyframe = [[PXKeyframe alloc] initWithName:currentLexeme.value];
    [self advance];

    // advance over '{'
    [self assertTypeAndAdvance:PXSS_LCURLY];

    // process each block
    while ([self isInTypeSet:KEYFRAME_SELECTOR_SET])
    {
        // grab all offsets
        NSMutableArray *offsets = [[NSMutableArray alloc] init];

        [offsets addObject:@([self parseOffset])];

        while ([self isType:PXSS_COMMA])
        {
            // advance over ','
            [self advance];

            [offsets addObject:@([self parseOffset])];
        }

        // grab declarations
        NSArray *declarations = [self parseDeclarationBlock];

        // create blocks, one for each offset, using the same declarations for each
        for (NSNumber *number in offsets)
        {
            CGFloat offset = [number floatValue];

            // create keyframe block
            PXKeyframeBlock *block = [[PXKeyframeBlock alloc] initWithOffset:offset];

            // add declarations to it
            for (PXDeclaration *declaration in declarations)
            {
                [block addDeclaration:declaration];
            }

            [keyframe addKeyframeBlock:block];
        }
    }

    // add keyframe to current stylesheet
    [currentStyleSheet_ addKeyframe:keyframe];

    // advance over '}'
    [self assertTypeAndAdvance:PXSS_RCURLY];
}

- (CGFloat)parseOffset
{
    CGFloat offset = 0.0f;

    [self assertTypeInSet:KEYFRAME_SELECTOR_SET];

    switch (currentLexeme.type)
    {
        case PXSS_IDENTIFIER:
            // NOTE: we only check for 'to' since 'from' and unrecognized values will use the default value of 0.0f
            if ([@"to" isEqualToString:currentLexeme.value])
            {
                offset = 1.0f;
            }
            [self advance];
            break;

        case PXSS_PERCENTAGE:
        {
            PXDimension *percentage = currentLexeme.value;
            offset = percentage.number / 100.0f;
            offset = MIN(1.0f, offset);
            offset = MAX(0.0f, offset);
            [self advance];
            break;
        }

        default:
        {
            NSString *message = [NSString stringWithFormat:@"Unrecognized keyframe selector type: %@", currentLexeme];
            [self errorWithMessage:message];
            break;
        }
    }

    return offset;
}

- (void)parseNamespace
{
    [self assertTypeAndAdvance:PXSS_NAMESPACE];

    NSString *identifier = nil;
    NSString *uri;

    if ([self isType:PXSS_IDENTIFIER])
    {
        identifier = currentLexeme.value;
        [self advance];
    }

    [self assertTypeInSet:NAMESPACE_SET];

    // grab value
    uri = currentLexeme.value;

    // trim string
    if ([self isType:PXSS_STRING])
    {
        uri = [uri substringWithRange:NSMakeRange(1, uri.length - 2)];
    }

    [self advance];

    // set namespace on stylesheet
    [currentStyleSheet_ setURI:uri forNamespacePrefix:identifier];

    [self assertTypeAndAdvance:PXSS_SEMICOLON];
}

// level 2

- (NSArray *)parseSelectorGroup
{
    NSMutableArray *selectors = [[NSMutableArray alloc] init];

    id<PXSelector> selectorSequence = [self parseSelectorSequence];

    if (selectorSequence)
    {
        [selectors addObject:selectorSequence];
    }

    while (currentLexeme.type == PXSS_COMMA)
    {
        // advance over ','
        [self advance];

        // grab next selector
        [selectors addObject:[self parseSelectorSequence]];
    }

    if (selectors.count == 0)
    {
        [self errorWithMessage:@"Expected a Selector or Pseudo-element"];
    }

    return selectors;
}

- (NSArray *)parseDeclarationBlock
{
    [self assertTypeAndAdvance:PXSS_LCURLY];

    NSArray *declarations = [self parseDeclarations];

    [self assertTypeAndAdvance:PXSS_RCURLY];

    return declarations;
}

- (void)parseMediaExpressions
{
    @try
    {
        // create container for zero-or-more expressions
        NSMutableArray *expressions = [NSMutableArray array];

        // add at least one expression
        [expressions addObject:[self parseMediaExpression]];

        // and any others
        while ([self isType:PXSS_AND])
        {
            [self advance];

            [expressions addObject:[self parseMediaExpression]];
        }

        // create expression group or use single entry
        if (expressions.count == 1)
        {
            currentStyleSheet_.activeMediaQuery = [expressions objectAtIndex:0];
        }
        else
        {
            PXMediaExpressionGroup *group = [[PXMediaExpressionGroup alloc] init];

            for (id<PXMediaExpression> expression in expressions)
            {
                [group addExpression: expression];
            }

            currentStyleSheet_.activeMediaQuery = group;
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
        // TODO: error recovery
    }
}

// level 3

- (id<PXSelector>)parseSelectorSequence
{
    id<PXSelector> root = [self parseSelector];

    while ([self isInTypeSet:SELECTOR_SEQUENCE_SET])
    {
        PXStylesheetLexeme *operator = nil;

        if ([self isInTypeSet:SELECTOR_OPERATOR_SET])
        {
            operator = currentLexeme;
            [self advance];
        }

        id<PXSelector> rhs = [self parseSelector];

        if (operator)
        {
            switch (operator.type)
            {
                case PXSS_PLUS:
                    root = [[PXAdjacentSiblingCombinator alloc] initWithLHS:root RHS:rhs];
                    break;

                case PXSS_GREATER_THAN:
                    root = [[PXChildCombinator alloc] initWithLHS:root RHS:rhs];
                    break;

                case PXSS_TILDE:
                    root = [[PXSiblingCombinator alloc] initWithLHS:root RHS:rhs];
                    break;

                default:
                    [self errorWithMessage:@"Unsupported selector operator (combinator)"];
            }
        }
        else
        {
            root = [[PXDescendantCombinator alloc] initWithLHS:root RHS:rhs];
        }
    }

    NSString *pseudoElement = nil;

    // grab possible pseudo-element in new and old formats
    if ([self isType:PXSS_DOUBLE_COLON])
    {
        [self advance];

        [self assertType:PXSS_IDENTIFIER];
        pseudoElement = currentLexeme.value;
        [self advance];
    }
    else if ([self isInTypeSet:ARCHAIC_PSEUDO_ELEMENTS_SET])
    {
        NSString *stringValue = currentLexeme.value;

        pseudoElement = [stringValue substringFromIndex:1];

        [self advance];
    }

    if (pseudoElement.length > 0)
    {
        if (root == nil)
        {
            PXTypeSelector *selector = [[PXTypeSelector alloc] init];

            selector.pseudoElement = pseudoElement;

            root = selector;
        }
        else
        {
            if ([root isKindOfClass:[PXTypeSelector class]])
            {
                PXTypeSelector *selector = root;

                selector.pseudoElement = pseudoElement;
            }
            else if ([root isKindOfClass:[PXCombinatorBase class]])
            {
                PXCombinatorBase *combinator = (PXCombinatorBase *)root;
                PXTypeSelector *selector = combinator.rhs;

                selector.pseudoElement = pseudoElement;
            }
        }
    }

    return root;
}

- (NSArray *)parseDeclarations
{
    NSMutableArray *declarations = [NSMutableArray array];

    // parse properties
    while (currentLexeme && currentLexeme.type != PXSS_RCURLY)
    {
        @try
        {
            PXDeclaration *declaration = [self parseDeclaration];

            [declarations addObject:declaration];
        }
        @catch (NSException *e)
        {
            [self addError:e.description];

            // TODO: parseDeclaration could do error recovery. If not, this should probably do the same recovery
            while (currentLexeme && ![self isInTypeSet:DECLARATION_DELIMITER_SET])
            {
                [self advance];
            }

            [self advanceIfIsType:PXSS_SEMICOLON];
        }
    }

    return declarations;
}

- (id<PXMediaExpression>)parseMediaExpression
{
    [self assertTypeAndAdvance:PXSS_LPAREN];

    // grab name
    [self assertType:PXSS_IDENTIFIER];
    NSString *name = [currentLexeme.value lowercaseString];
    [self advance];

    id value = nil;

    // parse optional value
    if ([self isType:PXSS_COLON])
    {
        // advance over ':'
        [self assertTypeAndAdvance:PXSS_COLON];

        // grab value
        [self assertTypeInSet:QUERY_VALUE_SET];
        value = currentLexeme.value;
        [self advance];

        // make string values lowercase to avoid doing it later
        if ([value isKindOfClass:[NSString class]])
        {
            value = [value lowercaseString];
        }
        // check for possible ratio syntax
        else if ([value isKindOfClass:[NSNumber class]] && [self isType:PXSS_SLASH]) {
            
            NSNumber *numerator = (NSNumber *) value;
            
            // advance over '/'
            [self advance];

            // grab denominator
            [self assertType:PXSS_NUMBER];
            NSNumber *denom = currentLexeme.value;
            [self advance];

            if ([numerator floatValue] == 0.0)
            {
                // do nothing, leave result as 0.0
            }
            else if ([denom floatValue] == 0.0)
            {
                value = [NSNumber numberWithDouble:NAN];
            }
            else
            {
                value = [NSNumber numberWithFloat:([numerator floatValue] / [denom floatValue])];
            }
        }
    }

    [self advanceIfIsType:PXSS_RPAREN withWarning:@"Expected closing parenthesis in media query"];

    // create query expression and activate it in current stylesheet
    return [[PXNamedMediaExpression alloc] initWithName:name value:value];
}

// level 4

- (id<PXSelector>)parseSelector
{
    PXTypeSelector *result = nil;

    if ([self isInTypeSet:SELECTOR_SET])
    {
        if ([self isInTypeSet:TYPE_SELECTOR_SET])
        {
            result = [self parseTypeSelector];
        }
        else
        {
            // match any element
            result = [[PXTypeSelector alloc] init];

            // clear whitespace flag, so first expression will not fail in this case
            [currentLexeme clearFlag:PXLexemeFlagFollowsWhitespace];
        }

        if ([self isInTypeSet:SELECTOR_EXPRESSION_SET])
        {
            for (id<PXSelector> expression in [self parseSelectorExpressions])
            {
                [result addAttributeExpression:expression];
            }
        }
    }
    // else, fail silently in case a pseudo-element follows

    return result;
}

- (PXDeclaration *)parseDeclaration
{
    // process property name
    [self assertType:PXSS_IDENTIFIER];
    PXDeclaration *declaration = [[PXDeclaration alloc] initWithName:currentLexeme.value];
    [self advance];

    // colon
    [self assertTypeAndAdvance:PXSS_COLON];

    // collect values
    NSMutableArray *lexemes = [NSMutableArray array];

    while (currentLexeme && ![self isInTypeSet:DECLARATION_DELIMITER_SET])
    {
        if (currentLexeme.type == PXSS_COLON && ((PXStylesheetLexeme *)[lexemes lastObject]).type == PXSS_IDENTIFIER)
        {
            // assume we've moved into a new declaration, so push last lexeme back into the lexeme stream
            //PXStylesheetLexeme *propertyName = [lexemes pop];

            // this pushes the colon back to the lexer and makes the property name the current lexeme
            //[self pushLexeme:propertyName];

            // signal end of this declaration
            break;
        }
        else
        {
            [lexemes addObject:currentLexeme];
            [self advance];
        }
    }

    // let semicolons be optional
    [self advanceIfIsType:PXSS_SEMICOLON];

    // grab original source, for error messages and hashing
    NSString *source;

    if (lexemes.count > 0)
    {
        PXStylesheetLexeme *firstLexeme = [lexemes objectAtIndex:0];
        PXStylesheetLexeme *lastLexeme = [lexemes lastObject];
        NSUInteger start = firstLexeme.range.location;
        NSUInteger end = lastLexeme.range.location + lastLexeme.range.length;
        NSUInteger length = end - start;
        NSRange sourceRange = NSMakeRange(start, length);

        source = [source_ substringWithRange:sourceRange];
    }
    else
    {
        source = @"";
    }

    // check for !important
    PXStylesheetLexeme *lastLexeme = [lexemes lastObject];

    if (lastLexeme.type == PXSS_IMPORTANT)
    {
        // drop !important and tag declaration as important
        [lexemes removeLastObject];
        declaration.important = YES;
    }

    // associate lexemes with declaration
    [declaration setSource:source filename:[self currentFilename] lexemes:lexemes];

    return declaration;
}

// level 5

- (PXTypeSelector *)parseTypeSelector
{
    PXTypeSelector *result = nil;

    if ([self isInTypeSet:TYPE_SELECTOR_SET])
    {
        NSString *namespace = nil;
        NSString *name = nil;

        // namespace or type
        if ([self isInTypeSet:TYPE_NAME_SET])
        {
            // assume we have a name only
            name = currentLexeme.value;
            [self advance];
        }

        // if pipe, then we had a namespace, now process type
        if ([self isType:PXSS_PIPE])
        {
            namespace = name;

            // advance over '|'
            [self advance];

            if ([self isInTypeSet:TYPE_NAME_SET])
            {
                // set name
                name = currentLexeme.value;
                [self advance];
            }
            else
            {
                [self errorWithMessage:@"Expected IDENTIFIER or STAR"];
            }
        }
        else
        {
            namespace = @"*";
        }

        // find namespace URI from namespace prefix

        NSString *namespaceURI = nil;

        if (namespace)
        {
            if ([namespace isEqualToString:@"*"])
            {
                namespaceURI = namespace;
            }
            else
            {
                namespaceURI = [currentStyleSheet_ namespaceForPrefix:namespace];
            }
        }

        result = [[PXTypeSelector alloc] initWithNamespaceURI:namespaceURI typeName:name];
    }
    else
    {
        [self errorWithMessage:@"Expected IDENTIFIER, STAR, or PIPE"];
    }

    return result;
}

- (NSArray *)parseSelectorExpressions
{
    NSMutableArray *expressions = [NSMutableArray array];

    while (![currentLexeme flagIsSet:PXLexemeFlagFollowsWhitespace] && [self isInTypeSet:SELECTOR_EXPRESSION_SET])
    {
        switch (currentLexeme.type)
        {
            case PXSS_ID:
            {
                NSString *name = [(NSString *) currentLexeme.value substringFromIndex:1];
                [expressions addObject:[[PXIdSelector alloc] initWithIdValue:name]];
                [self advance];
                break;
            }

            case PXSS_CLASS:
            {
                NSString *name = [(NSString *) currentLexeme.value substringFromIndex:1];
                [expressions addObject:[[PXClassSelector alloc] initWithClassName:name]];
                [self advance];
                break;
            }

            case PXSS_LBRACKET:
                [expressions addObject:[self parseAttributeSelector]];
                break;

            case PXSS_COLON:
                [expressions addObject:[self parsePseudoClass]];
                break;

            case PXSS_NOT_PSEUDO_CLASS:
                [expressions addObject:[self parseNotSelector]];
                break;

            case PXSS_ROOT_PSEUDO_CLASS:
                [expressions addObject:[[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateRoot]];
                [self advance];
                break;

            case PXSS_FIRST_CHILD_PSEUDO_CLASS:
                [expressions addObject:[[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateFirstChild]];
                [self advance];
                break;

            case PXSS_LAST_CHILD_PSEUDO_CLASS:
                [expressions addObject:[[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateLastChild]];
                [self advance];
                break;

            case PXSS_FIRST_OF_TYPE_PSEUDO_CLASS:
                [expressions addObject:[[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateFirstOfType]];
                [self advance];
                break;

            case PXSS_LAST_OF_TYPE_PSEUDO_CLASS:
                [expressions addObject:[[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateLastOfType]];
                [self advance];
                break;

            case PXSS_ONLY_CHILD_PSEUDO_CLASS:
                [expressions addObject:[[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateOnlyChild]];
                [self advance];
                break;

            case PXSS_ONLY_OF_TYPE_PSEUDO_CLASS:
                [expressions addObject:[[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateOnlyOfType]];
                [self advance];
                break;

            case PXSS_EMPTY_PSEUDO_CLASS:
                [expressions addObject:[[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateEmpty]];
                [self advance];
                break;

            case PXSS_NTH_CHILD_PSEUDO_CLASS:
            case PXSS_NTH_LAST_CHILD_PSEUDO_CLASS:
            case PXSS_NTH_OF_TYPE_PSEUDO_CLASS:
            case PXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS:
                [expressions addObject:[self parsePseudoClassFunction]];
                [self assertTypeAndAdvance:PXSS_RPAREN];
                break;

            // TODO: implement
            case PXSS_LINK_PSEUDO_CLASS:
            case PXSS_VISITED_PSEUDO_CLASS:
            case PXSS_HOVER_PSEUDO_CLASS:
            case PXSS_ACTIVE_PSEUDO_CLASS:
            case PXSS_FOCUS_PSEUDO_CLASS:
            case PXSS_TARGET_PSEUDO_CLASS:
            case PXSS_ENABLED_PSEUDO_CLASS:
            case PXSS_CHECKED_PSEUDO_CLASS:
            case PXSS_INDETERMINATE_PSEUDO_CLASS:
                [expressions addObject:[[PXPseudoClassSelector alloc] initWithClassName:currentLexeme.value]];
                [self advance];
                break;

            // TODO: implement
            case PXSS_LANG_PSEUDO_CLASS:
                [expressions addObject:[[PXPseudoClassSelector alloc] initWithClassName:currentLexeme.value]];
                [self advanceToType:PXSS_RPAREN];
                [self advance];
                break;

            default:
                break;
        }
    }

    if (expressions.count == 0 && ![currentLexeme flagIsSet:PXLexemeFlagFollowsWhitespace])
    {
        [self errorWithMessage:@"Expected ID, CLASS, LBRACKET, or PseudoClass"];
    }

    return expressions;
}

// level 6

- (PXPseudoClassFunction *)parsePseudoClassFunction
{
    // initialize to something to remove analyzer warnings, but the switch below has to cover all cases to prevent a
    // bug here
    PXPseudoClassFunctionType type = PXPseudoClassFunctionNthChild;

    switch (currentLexeme.type)
    {
        case PXSS_NTH_CHILD_PSEUDO_CLASS:
            type = PXPseudoClassFunctionNthChild;
            break;

        case PXSS_NTH_LAST_CHILD_PSEUDO_CLASS:
            type = PXPseudoClassFunctionNthLastChild;
            break;

        case PXSS_NTH_OF_TYPE_PSEUDO_CLASS:
            type = PXPseudoClassFunctionNthOfType;
            break;

        case PXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS:
            type = PXPseudoClassFunctionNthLastOfType;
            break;
    }

    // advance over function name and left paren
    [self advance];

    NSInteger modulus = 0;
    NSInteger remainder = 0;

    // parse modulus
    if ([self isType:PXSS_NTH])
    {
        NSString *numberString = currentLexeme.value;
        NSUInteger length = numberString.length;

        // extract modulus
        if (length == 1)
        {
            // we have 'n'
            modulus = 1;
        }
        else if (length == 2 && [numberString hasPrefix:@"-"])
        {
            // we have '-n'
            modulus = -1;
        }
        else if (length == 2 && [numberString hasPrefix:@"+"])
        {
            // we have '+n'
            modulus = 1;
        }
        else
        {
            // a number precedes 'n'
            modulus = [[numberString substringWithRange:NSMakeRange(0, numberString.length - 1)] intValue];
        }

        [self advance];

        if ([self isType:PXSS_PLUS])
        {
            [self advance];

            // grab remainder
            [self assertType:PXSS_NUMBER];
            NSNumber *remainderNumber = currentLexeme.value;
            remainder = [remainderNumber intValue];
            [self advance];
        }
        else if ([self isType:PXSS_NUMBER])
        {
            NSString *numberString = [source_ substringWithRange:currentLexeme.range];

            if ([numberString hasPrefix:@"-"] || [numberString hasPrefix:@"+"])
            {
                NSNumber *remainderNumber = currentLexeme.value;
                remainder = [remainderNumber intValue];
                [self advance];
            }
            else
            {
                [self errorWithMessage:@"Expected NUMBER with leading '-' or '+'"];
            }
        }
    }
    else if ([self isType:PXSS_IDENTIFIER])
    {
        NSString *stringValue = currentLexeme.value;

        if ([@"odd" isEqualToString:stringValue])
        {
            modulus = 2;
            remainder = 1;
        }
        else if ([@"even" isEqualToString:stringValue])
        {
            modulus = 2;
        }
        else
        {
            [self errorWithMessage:[NSString stringWithFormat:@"Unrecognized identifier '%@'. Expected 'odd' or 'even'", stringValue]];
        }

        [self advance];
    }
    else if ([self isType:PXSS_NUMBER])
    {
        modulus = 1;
        NSNumber *remainderNumber = currentLexeme.value;
        remainder = [remainderNumber intValue];

        [self advance];
    }
    else
    {
        [self errorWithMessage:@"Expected NTH, NUMBER, 'odd', or 'even'"];
    }

    return [[PXPseudoClassFunction alloc] initWithFunctionType:type modulus:modulus remainder:remainder];
}

- (id<PXSelector>)parseAttributeSelector
{
    id<PXSelector> result = nil;

    [self assertTypeAndAdvance:PXSS_LBRACKET];

    result = [self parseAttributeTypeSelector];

    if ([self isInTypeSet:ATTRIBUTE_OPERATOR_SET])
    {
        PXAttributeSelectorOperatorType operatorType = kAttributeSelectorOperatorEqual; // make anaylzer happy

        switch (currentLexeme.type)
        {
            case PXSS_STARTS_WITH:          operatorType = kAttributeSelectorOperatorStartsWith; break;
            case PXSS_ENDS_WITH:            operatorType = kAttributeSelectorOperatorEndsWith; break;
            case PXSS_CONTAINS:             operatorType = kAttributeSelectorOperatorContains; break;
            case PXSS_EQUAL:                operatorType = kAttributeSelectorOperatorEqual; break;
            case PXSS_LIST_CONTAINS:        operatorType = kAttributeSelectorOperatorListContains; break;
            case PXSS_EQUALS_WITH_HYPHEN:   operatorType = kAttributeSelectorOperatorEqualWithHyphen; break;

            default:
                [self errorWithMessage:@"Unsupported attribute operator type"];
                break;
        }

        [self advance];

        if ([self isType:PXSS_STRING])
        {
            NSString *value = currentLexeme.value;

            // process string
            result = [[PXAttributeSelectorOperator alloc] initWithOperatorType:operatorType
                                                             attributeSelector:result
                                                                   stringValue:[value substringWithRange:NSMakeRange(1, value.length - 2)]];

            [self advance];
        }
        else if ([self isType:PXSS_IDENTIFIER])
        {
            // process string
            result = [[PXAttributeSelectorOperator alloc] initWithOperatorType:operatorType
                                                             attributeSelector:result
                                                                   stringValue:currentLexeme.value];

            [self advance];
        }
        else
        {
            [self errorWithMessage:@"Expected STRING or IDENTIFIER"];
        }
    }

    [self assertTypeAndAdvance:PXSS_RBRACKET];

    return result;
}

- (id<PXSelector>)parsePseudoClass
{
    id<PXSelector> result = nil;

    [self assertType:PXSS_COLON];
    [self advance];

    if ([self isType:PXSS_IDENTIFIER])
    {
        // process identifier
        result = [[PXPseudoClassSelector alloc] initWithClassName:currentLexeme.value];
        [self advance];
    }
    else
    {
        [self errorWithMessage:@"Expected IDENTIFIER"];
    }

    // TODO: support an+b notation

    return result;
}

- (id<PXSelector>)parseNotSelector
{
    // advance over 'not'
    [self assertType:PXSS_NOT_PSEUDO_CLASS];
    [self advance];

    id<PXSelector> result = [[PXNotPseudoClass alloc] initWithExpression:[self parseNegationArgument]];

    // advance over ')'
    [self assertTypeAndAdvance:PXSS_RPAREN];

    return result;
}

// level 7

- (id<PXSelector>)parseAttributeTypeSelector
{
    PXAttributeSelector *result = nil;

    if ([self isInTypeSet:TYPE_SELECTOR_SET])
    {
        NSString *namespace = nil;
        NSString *name = nil;

        // namespace or type
        if ([self isInTypeSet:TYPE_NAME_SET])
        {
            // assume we have a name only
            name = currentLexeme.value;
            [self advance];
        }

        // if pipe, then we had a namespace, now process type
        if ([self isType:PXSS_PIPE])
        {
            namespace = name;

            // advance over '|'
            [self advance];

            if ([self isInTypeSet:TYPE_NAME_SET])
            {
                // set name
                name = currentLexeme.value;
                [self advance];
            }
            else
            {
                [self errorWithMessage:@"Expected IDENTIFIER or STAR"];
            }
        }
        // NOTE: default namepace is nil indicating no namespace should exist when matching with this selector. This
        // differs from the interpretation used on type selectors

        // find namespace URI from namespace prefix

        NSString *namespaceURI = nil;

        if (namespace)
        {
            if ([namespace isEqualToString:@"*"])
            {
                namespaceURI = namespace;
            }
            else
            {
                namespaceURI = [currentStyleSheet_ namespaceForPrefix:namespace];
            }
        }

        result = [[PXAttributeSelector alloc] initWithNamespaceURI:namespaceURI attributeName:name];
    }
    else
    {
        [self errorWithMessage:@"Expected IDENTIFIER, STAR, or PIPE"];
    }

    return result;
}

- (id<PXSelector>)parseNegationArgument
{
    id<PXSelector> result = nil;

    switch (currentLexeme.type)
    {
        case PXSS_ID:
        {
            NSString *name = [(NSString *) currentLexeme.value substringFromIndex:1];
            result = [[PXIdSelector alloc] initWithIdValue:name];
            [self advance];
            break;
        }

        case PXSS_CLASS:
        {
            NSString *name = [(NSString *) currentLexeme.value substringFromIndex:1];
            result = [[PXClassSelector alloc] initWithClassName:name];
            [self advance];
            break;
        }

        case PXSS_LBRACKET:
            result = [self parseAttributeSelector];
            break;

        case PXSS_COLON:
            result = [self parsePseudoClass];
            break;

        case PXSS_ROOT_PSEUDO_CLASS:
            result = [[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateRoot];
            [self advance];
            break;

        case PXSS_FIRST_CHILD_PSEUDO_CLASS:
            result = [[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateFirstChild];
            [self advance];
            break;

        case PXSS_LAST_CHILD_PSEUDO_CLASS:
            result = [[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateLastChild];
            [self advance];
            break;

        case PXSS_FIRST_OF_TYPE_PSEUDO_CLASS:
            result = [[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateFirstOfType];
            [self advance];
            break;

        case PXSS_LAST_OF_TYPE_PSEUDO_CLASS:
            result = [[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateLastOfType];
            [self advance];
            break;

        case PXSS_ONLY_CHILD_PSEUDO_CLASS:
            result = [[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateOnlyChild];
            [self advance];
            break;

        case PXSS_ONLY_OF_TYPE_PSEUDO_CLASS:
            result = [[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateOnlyOfType];
            [self advance];
            break;

        case PXSS_EMPTY_PSEUDO_CLASS:
            result = [[PXPseudoClassPredicate alloc] initWithPredicateType:PXPseudoClassPredicateEmpty];
            [self advance];
            break;

        case PXSS_NTH_CHILD_PSEUDO_CLASS:
        case PXSS_NTH_LAST_CHILD_PSEUDO_CLASS:
        case PXSS_NTH_OF_TYPE_PSEUDO_CLASS:
        case PXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS:
            result = [self parsePseudoClassFunction];
            [self assertTypeAndAdvance:PXSS_RPAREN];
            break;

            // TODO: implement
        case PXSS_LINK_PSEUDO_CLASS:
        case PXSS_VISITED_PSEUDO_CLASS:
        case PXSS_HOVER_PSEUDO_CLASS:
        case PXSS_ACTIVE_PSEUDO_CLASS:
        case PXSS_FOCUS_PSEUDO_CLASS:
        case PXSS_TARGET_PSEUDO_CLASS:
        case PXSS_ENABLED_PSEUDO_CLASS:
        case PXSS_CHECKED_PSEUDO_CLASS:
        case PXSS_INDETERMINATE_PSEUDO_CLASS:
            result = [[PXPseudoClassSelector alloc] initWithClassName:currentLexeme.value];
            [self advance];
            break;

            // TODO: implement
        case PXSS_LANG_PSEUDO_CLASS:
            result = [[PXPseudoClassSelector alloc] initWithClassName:currentLexeme.value];
            [self advanceToType:PXSS_RPAREN];
            [self advance];
            break;

        case PXSS_RPAREN:
            // empty body
            break;

        default:
            if ([self isInTypeSet:TYPE_SELECTOR_SET])
            {
                result = [self parseTypeSelector];
            }
            else
            {
                [self errorWithMessage:@"Expected ID, CLASS, AttributeSelector, PseudoClass, or TypeSelect as negation argument"];
            }
            break;
    }

    return result;
}

#pragma mark - PXStylesheetLexerDelegate Implementation

- (void)lexerDidPopSource
{
    if (activeImports_.count > 0)
    {
        [activeImports_ pop];
    }
    else
    {
        DDLogError(@"Tried to pop an empty activeImports array");
    }
}

#pragma mark - Overrides

- (PXStylesheetLexeme *)advance
{
    return currentLexeme = css_lexer_get_lexeme();
}

- (NSString *)lexemeNameFromType:(int)type
{
    PXStylesheetLexeme *lexeme = [[PXStylesheetLexeme alloc] initWithType:type text:nil];

    return lexeme.name;
}

- (void)dealloc
{
    currentStyleSheet_ = nil;
    currentSelector_ = nil;
    activeImports_ = nil;
}

#pragma mark - Helpers

- (void)addImportName:(NSString *)name
{
    if (name.length > 0)
    {
        if (activeImports_ == nil)
        {
            activeImports_ = [[NSMutableArray alloc] init];
        }

        [activeImports_ push:name];
    }
}

- (void)advanceToType:(NSInteger)type
{
    while (currentLexeme && currentLexeme.type != type)
    {
        [self advance];
    }
}

- (NSString *)currentFilename
{
    return (activeImports_.count > 0) ? [[activeImports_ lastObject] lastPathComponent] : nil;
}

- (void)addError:(NSString *)error
{
    NSString *offset = (currentLexeme.type != PXSS_EOF) ? [NSString stringWithFormat:@"%lu", (unsigned long) currentLexeme.range.location] : @"EOF";

    [self addError:error filename:[self currentFilename] offset:offset];
}

@end
