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
//  PXGraphics.h
//  Pixate
//
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

// categories
#import "UIColor+PXColors.h"

// math
#import "PXDimension.h"
#import "PXMath.h"
#import "PXVector.h"

// paints
#import "PXGradient.h"
#import "PXLinearGradient.h"
#import "PXPaint.h"
#import "PXPaintGroup.h"
#import "PXRadialGradient.h"
#import "PXSolidPaint.h"

// parsing
#import "PXSVGLoader.h"

// shadows
#import "PXShadow.h"
#import "PXShadowGroup.h"
#import "PXShadowPaint.h"

// shapes
#import "PXArc.h"
#import "PXBoundable.h"
#import "PXCircle.h"
#import "PXEllipse.h"
#import "PXLine.h"
#import "PXPaintable.h"
#import "PXPath.h"
#import "PXPie.h"
#import "PXPolygon.h"
#import "PXRectangle.h"
#import "PXRenderable.h"
#import "PXShapeDocument.h"
#import "PXShape.h"
#import "PXShapeGroup.h"
#ifdef PXTEXT_SUPPORT
#import "PXText.h"
#endif

// strokes
#import "PXNonScalingStroke.h"
#import "PXStroke.h"
#import "PXStrokeGroup.h"
#import "PXStrokeRenderer.h"
#import "PXStrokeStroke.h"

// views
#import "PXShapeView.h"
