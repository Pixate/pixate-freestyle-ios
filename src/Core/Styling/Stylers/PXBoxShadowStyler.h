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
//  PXBoxShadowStyler.h
//  Pixate
//
//  Created by Kevin Lindsey on 12/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXStylerBase.h"

/**
 *  - box-shadow: <shadow> ["," <shadow>]*
 */

/*
 *  Support inner and outer shadows. Note that if no styler callback is supplied, this styler will automatically apply
 *  any outer shadows to the view being styled. It is important to know that if you provide a callback for you box
 *  shadow styler, you are responsible for applying the outer shadows.
 */
@interface PXBoxShadowStyler : PXStylerBase

+ (PXBoxShadowStyler *)sharedInstance;

@end
