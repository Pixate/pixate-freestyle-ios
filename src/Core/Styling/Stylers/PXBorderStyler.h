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
//  PXBorderStyler.h
//  Pixate
//
//  Created by Kevin Lindsey on 12/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXStylerBase.h"

/**
 *  - border: <width> || <border-style> || <paint>
 *  - border-radius: <size>
 *  - border-top-left-radius: <length>
 *  - border-top-right-radius: <length>
 *  - border-bottom-right-radius: <length>
 *  - border-bottom-left-radius: <length>
 *  - border-width: <length>
 *  - border-color: <paint>
 *  - border-style: <border-style>
 */

/*  WE PARSE THESE BUT WE DON'T RENDER THEM
 *
 *  - border-top: <width> || <border-style> || <paint>
 *  - border-right: <width> || <border-style> || <paint>
 *  - border-bottom: <width> || <border-style> || <paint>
 *  - border-left: <width> || <border-style> || <paint>
 *  - border-top-width: <length>
 *  - border-right-width: <length>
 *  - border-bottom-width: <length>
 *  - border-left-width: <length>
 *  - border-top-color: <paint>
 *  - border-right-color: <paint>
 *  - border-bottom-color: <paint>
 *  - border-left-color: <paint>
 *  - border-top-style: <border-style>
 *  - border-right-style: <border-style>
 *  - border-bottom-style: <border-style>
 *  - border-left-style: <border-style>
 */

@interface PXBorderStyler : PXStylerBase

+ (PXBorderStyler *)sharedInstance;

@end
