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
//  PXSSLexer.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/23/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXStylesheetLexeme.h"

/**
 *  The PXStylesheetLexerDelegate protocol defines a set of events that will fire during the lifetime of a
 *  PXStylesheetLexer
 */
@protocol PXStylesheetLexerDelegate <NSObject>

@optional

/**
 *  A method fired when the lexer pops the current source (and other state) when encountered the end of the current
 *  string it is processing
 */
- (void)lexerDidPopSource;

@end

/**
 *  PXStylesheetLexer is responsible for converting an NSString into a stream of PXLexemes. Eacn PXLexeme represents an
 *  instance of a CSS token.
 */
@interface PXStylesheetLexer : NSObject

/**
 *  The source string being tokenized by this lexer. Note that setting this value resets the lexer state
 */
@property (nonatomic, strong) NSString *source;

/**
 *  A delegate to call when various events occur within the lexer
 */
@property (nonatomic, weak) id<PXStylesheetLexerDelegate> delegate;

/**
 *  Initializer a new instance with the specified source value
 *
 *  @param source The source string to lex
 */
- (id)initWithString:(NSString *)source;

/**
 *  Return the next lexeme in the source string from where the last lex ended. This will return nil once the source
 *  string has been completed consumed.
 */
- (PXStylesheetLexeme *)nextLexeme;

/**
 *  Push the specified lexeme onto internal stack. Lexemes will first be removed from this stack when calling
 *  nextLexeme. Once the stack has been depleted, lexing continues from the last successful scan not involving the
 *  lexeme stack.
 *
 *  @param lexeme The lexeme to push on to the stack
 */
- (void)pushLexeme:(PXStylesheetLexeme *)lexeme;

/**
 *  This lexer returns different lexemes for the same source depending on if the lexer is inside or outside of a
 *  delcaration body. This method allows code to indicate that lexing should proceed as if the lexer is inside a block.
 *  This is typically used when processing styles that are associated directly with a styleable object as opposed to
 *  coming from a stylesheet.
 */
- (void)increaseNesting;

/**
 *  This is the complementary method to increaseNesting. This is used to indicate that a block has been completely
 *  lexed.
 */
- (void)decreaseNesting;

/**
 *  Save the current context of the lexer, re-initialize the lexer, and begin lexing the specified source. This is
 *  useful for handling "import" statements, where another file needs to be processed inline with the current file
 *  being processed
 *
 *  @param source The new source
 */
- (void)pushSource:(NSString *)source;

@end
