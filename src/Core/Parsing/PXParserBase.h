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
//  PXParserBase.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/30/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXParser.h"

/**
 *  PXParserBase is an abstract class with a collection of helper functions useful during parsing.
 */
@interface PXParserBase : NSObject <PXParser>
{
    /**
     *  The current lexeme from the last call to advance. This value may be nil if none of the advance methods have been
     *  called or if there are no more lexemes in the scanner's lexeme stream
     */
    @protected id<PXLexeme> currentLexeme;
}



@end
