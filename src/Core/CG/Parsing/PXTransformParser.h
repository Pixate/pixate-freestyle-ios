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
//  PXTransformParser.h
//  Pixate
//
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXParserBase.h"

/**
 *  PXTransformParser generates a CGAffineTransform by parsing an SVG transform value
 */
@interface PXTransformParser : PXParserBase

/**
 *  Parse the specified source, generating a CGAffineTransform as a result
 *
 *  @param source The source to parse
 */
- (CGAffineTransform)parse:(NSString *)source;

@end
