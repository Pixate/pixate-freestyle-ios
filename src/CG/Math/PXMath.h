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
//  PXMath.h
//  Pixate
//
//  Created by Kevin Lindsey on 7/28/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#ifndef PXShapeKit_PXMath_h
#define PXShapeKit_PXMath_h

#define DEGREES_TO_RADIANS(angle)   ( (angle)  / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * 180.0 / M_PI)
#define TWO_PI (2.0 * M_PI)

#if CGFLOAT_IS_DOUBLE
#define SIN(t) sin(t)
#define COS(t) cos(t)
#define TAN(t) tan(t)
#define ACOS(t) acos(t)
#define ASIN(t) asin(t)
#define ATAN2(y,x) atan2(y,x)
#define SQRT(n) sqrt(n)
#define EXP(n) exp(n)
#define FLOOR(n) floor(n)
#else
#define SIN(t) sinf(t)
#define COS(t) cosf(t)
#define TAN(t) tanf(t)
#define ACOS(t) acosf(t)
#define ASIN(t) asinf(t)
#define ATAN2(y,x) atan2f(y,x)
#define SQRT(n) sqrtf(n)
#define EXP(n) expf(n)
#define FLOOR(n) floorf(n)
#endif

#endif
