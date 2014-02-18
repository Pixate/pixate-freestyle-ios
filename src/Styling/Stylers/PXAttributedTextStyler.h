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
//  PXAttributedTextStyler.h
//  Pixate
//
//  Created by Robin Debreuil on 1/9/2014.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXStylerBase.h"

/**
 *  - text: <string>
 *  - color: <color>
 *  - font-family: <string>
 *  - font-size: <length>
 *  - font-style: normal | italic | oblique
 *  - font-weight: normal | bold | black | heavy | extra-bold | ultra-bold | semi-bold | demi-bold | medium | light | extra-thin | ultra-thin | thin | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900
 *  - font-stretch: normal | ultra-condensed | extra-condensed | condensed | semi-condensed | semi-expanded | expanded | extra-expanded | ultra-expanded
 *  - letter-spacing: <length> | ems | percent
 *  - text-transform: uppercase | lowercase | capitalize
 *  - text-decoration: underline | line-through | letterpress
 */

@interface PXAttributedTextStyler : PXStylerBase

@end
