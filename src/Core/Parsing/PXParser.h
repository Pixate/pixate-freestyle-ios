//
//  PXParser.h
//  PixateCore
//
//  Created by Kevin Lindsey on 12/17/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXLexeme.h"

@protocol PXParser <NSObject>

/**
 *  A mutable array of all errors that occurred during parsing. Note that if an instance of a parser is used, each new
 *  parse should call clearErrors so that this value will be empty before the parse initiates.
 */
@property (readonly, nonatomic, strong) NSMutableArray *errors;

/**
 *  Advance to the next lexeme in the lexeme stream. The current lexeme is returned and the currentLexeme is set to that
 *  return value.
 */
- (id<PXLexeme>)advance;

/**
 *  Return a string name for the given lexeme type
 */
- (NSString *)lexemeNameFromType:(int)type;

/**
 *  Add an error message to the list of errors encountered during parsing
 *
 *  @param error The error message to add
 */
- (void)addError:(NSString *)error;

/**
 *  Add an error message, including the filename and offset where the error occurred
 *
 *  @param error The error message
 *  @param filename The filename where the error occurred
 *  @param offset A string representing the offset where the error occurred
 */
- (void)addError:(NSString *)error filename:(NSString *)filename offset:(NSString *)offset;

/**
 *  Remove all errors that have been previously reported. This should be called before a parse begins if the parser
 *  instance is being re-used.
 */
- (void)clearErrors;

/**
 *  Throw an NSException and add an error message to the list of errors collected so far.
 *
 *  @param message The error message
 */
- (void)errorWithMessage:(NSString *)message;

/**
 *  Assert that the current lexeme matches the specified type. If it does not match, then throw an exception
 *
 *  @param type The lexeme type to test against
 */
- (void)assertType:(int)type;

/**
 *  Assert that the current lexeme matches one of the types in the specified set. If it does not match, then throw an
 *  exception.
 *
 *  @param types An NSIndexSet containing a collection of types to match against
 */
- (void)assertTypeInSet:(NSIndexSet *)types;

/**
 *  Assert that the current lexeme matches the specified type. If it does not match, then throw an exception. If the
 *  types do match, then advance to the next lexeme.
 *
 *  @param type The lexeme type to test against
 */
- (id<PXLexeme>)assertTypeAndAdvance:(int)type;

/**
 *  Advance to the next lexeme if the current lexeme matches the specified type.
 *
 *  @param type The lexeme type to test against
 */
- (void)advanceIfIsType:(int)type;

/**
 *  Advance to the next lexeme if the current lexeme matches the specified type. If the type does not match, then add
 *  a warning to the current list of errors, but do not throw an exception
 *
 *  @param type The lexeme type to test against
 *  @param warning The warning message to emit
 */
- (void)advanceIfIsType:(int)type withWarning:(NSString *)warning;

/**
 *  Determine if the current lexeme matches the specified type.
 *
 *  @param type The lexeme type to test against
 */
- (BOOL)isType:(int)type;

/**
 *  Determine if the current lexeme matches one of the types in the specified set.
 *
 *  @param types An NSIndexSet containing a collection of types to match against
 */
- (BOOL)isInTypeSet:(NSIndexSet *)types;

@end
