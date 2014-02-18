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
//  PXPseudoClassPredicate.m
//  Pixate
//
//  Created by Kevin Lindsey on 11/26/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXPseudoClassPredicate.h"
#import "PXStyleUtils.h"

@implementation PXPseudoClassPredicate

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

#pragma mark - Initializers

- (id)initWithPredicateType:(PXPseudoClassPredicateType)type
{
    if (self = [super init])
    {
        _predicateType = type;
    }

    return self;
}

#pragma mark - PXSelector Implementation

- (BOOL)matches:(id<PXStyleable>)element
{
    BOOL result = NO;
    PXStyleableChildrenInfo *info = [PXStyleUtils childrenInfoForStyleable:element];

    switch (_predicateType)
    {
        case PXPseudoClassPredicateRoot:
            // TODO: not sure how robust this test is
            result = (element.pxStyleParent == nil);
            break;

        case PXPseudoClassPredicateFirstChild:
        {
            result = (info->childrenIndex == 1);
            break;
        }

        case PXPseudoClassPredicateLastChild:
        {
            result = (info->childrenIndex == info->childrenCount);
            break;
        }

        case PXPseudoClassPredicateFirstOfType:
        {
            result = (info->childrenOfTypeIndex == 1);
            break;
        }

        case PXPseudoClassPredicateLastOfType:
        {
            result = (info->childrenOfTypeIndex == info->childrenOfTypeCount);
            break;
        }

        case PXPseudoClassPredicateOnlyChild:
        {
            result = (info->childrenCount == 1 && info->childrenIndex == 1);
            break;
        }

        case PXPseudoClassPredicateOnlyOfType:
        {
            result = (info->childrenOfTypeCount == 1 && info->childrenOfTypeIndex == 1);
            break;
        }

        case PXPseudoClassPredicateEmpty:
        {
            result = ([PXStyleUtils childCountForStyleable:element] == 0);
            break;
        }
    }

    free(info);

    if (result)
    {
        DDLogVerbose(@"%@ matched %@", self.description, [PXStyleUtils descriptionForStyleable:element]);
    }
    else
    {
        DDLogVerbose(@"%@ did not match %@", self.description, [PXStyleUtils descriptionForStyleable:element]);
    }

    return result;
}

- (void)incrementSpecificity:(PXSpecificity *)specificity
{
    [specificity incrementSpecifity:kSpecificityTypeClassOrAttribute];
}

#pragma mark - Overrides

- (NSString *)description
{
    switch (_predicateType)
    {
        case PXPseudoClassPredicateRoot: return @":root";
        case PXPseudoClassPredicateFirstChild: return @":first-child";
        case PXPseudoClassPredicateLastChild: return @":list-child";
        case PXPseudoClassPredicateFirstOfType: return @":first-of-type";
        case PXPseudoClassPredicateLastOfType: return @":last-of-type";
        case PXPseudoClassPredicateOnlyChild: return @":only-child";
        case PXPseudoClassPredicateOnlyOfType: return @":only-of-type";
        case PXPseudoClassPredicateEmpty: return @":empty";
        default: return @"<uknown-pseudo-class-predicate";
    }
}

- (void)sourceWithSourceWriter:(PXSourceWriter *)writer
{
    [writer printIndent];
    [writer print:@"(PSEUDO_CLASS_PREDICATE "];
    [writer print:self.description];
    [writer print:@")"];
}

@end
