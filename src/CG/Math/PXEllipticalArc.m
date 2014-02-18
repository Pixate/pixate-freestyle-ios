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
//  PXEllipticalArc.m
//  Pixate
//
//  Created by Kevin Lindsey on 3/27/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXEllipticalArc.h"
#import "PXMath.h"

#define THRESHOLD 0.25
#define RATIONAL_FUNCTION(x,c) ((x * (x * c[0] + c[1]) + c[2]) / (x + c[3]))
#define LOG_VAR(v) NSLog(@""#v" = %f", v)

static CGFloat coeffs3Low[2][4][4] = {
    {
        {  3.85268,   -21.229,      -0.330434,    0.0127842  },
        { -1.61486,     0.706564,    0.225945,    0.263682   },
        { -0.910164,    0.388383,    0.00551445,  0.00671814 },
        { -0.630184,    0.192402,    0.0098871,   0.0102527  }
    }, {
        { -0.162211,    9.94329,     0.13723,     0.0124084  },
        { -0.253135,    0.00187735,  0.0230286,   0.01264    },
        { -0.0695069,  -0.0437594,   0.0120636,   0.0163087  },
        { -0.0328856,  -0.00926032, -0.00173573,  0.00527385 }
    }
};

static CGFloat coeffs3High[2][4][4] = {
    {
        {  0.0899116, -19.2349,     -4.11711,     0.183362   },
        {  0.138148,   -1.45804,     1.32044,     1.38474    },
        {  0.230903,   -0.450262,    0.219963,    0.414038   },
        {  0.0590565,  -0.101062,    0.0430592,   0.0204699  }
    }, {
        {  0.0164649,   9.89394,     0.0919496,   0.00760802 },
        {  0.0191603,  -0.0322058,   0.0134667,  -0.0825018  },
        {  0.0156192,  -0.017535,    0.00326508, -0.228157   },
        { -0.0236752,   0.0405821,  -0.0173086,   0.176187   }
    }
};

void CGPathAddEllipticalArc(CGMutablePathRef path, const CGAffineTransform *m, CGFloat x, CGFloat y, CGFloat radiusX, CGFloat radiusY, CGFloat startAngle, CGFloat endAngle)
{
    PXEllipticalArc *arc = [[PXEllipticalArc alloc] initWithCx:x cy:y radiusX:radiusX radiusY:radiusY startingAngle:startAngle endingAngle:endAngle];

    if (m == NULL)
    {
        [arc addToPath:path transform:CGAffineTransformIdentity];
    }
    else
    {
        [arc addToPath:path transform:*m];
    }
}

@implementation PXEllipticalArc
{
    CGFloat cx_;
    CGFloat cy_;
    CGFloat a_;
    CGFloat b_;
    CGFloat eta1_;
    CGFloat eta2_;
    CGFloat sinTheta_;
    CGFloat cosTheta_;
}

#pragma mark - Initializers

- (id)initWithCx:(CGFloat)cx cy:(CGFloat)cy radiusX:(CGFloat)a radiusY:(CGFloat)b startingAngle:(CGFloat)lambda1 endingAngle:(CGFloat)lambda2
{
    if (self = [super init])
    {
        cx_ = cx;
        cy_ = cy;
        a_ = a;
        b_ = b;

        // NOTE: We use the float version of SIN because we get different values for lambda1 and lambda2 in 32-bit and
        // 64-bit. This is probably worth investigating, but this appears to work for now
        eta1_ = ATAN2(sinf(lambda1) / b, COS(lambda1) / a);
        eta2_ = ATAN2(sinf(lambda2) / b, COS(lambda2) / a);

        if (eta1_ > 0 && lambda1 < 0)
        {
            eta1_ -= TWO_PI;
        }
        else if (eta1_ < 0 && lambda1 > 0)
        {
            eta1_ += TWO_PI;
        }
        if (eta2_ > 0 && lambda2 < 0)
        {
            eta2_ -= TWO_PI;
        }
        else if (eta2_ < 0 && lambda2 > 0)
        {
            eta2_ += TWO_PI;
        }

        // assume axis-aligned
        cosTheta_ = 1.0f;
        sinTheta_ = 0.0f;
    }

    return self;
}

#pragma mark - Methods

- (void)addToPath:(CGMutablePathRef)path transform:(CGAffineTransform)transform
{
    CGAffineTransform *pTransform = (CGAffineTransformIsIdentity(transform)) ? NULL : &transform;

    BOOL found = NO;
    NSUInteger n = 1;

    while (found == NO && (n < 1024))
    {
        CGFloat dEta = (eta2_ - eta1_) / n;

        if (dEta <= M_PI_2)
        {
            CGFloat etaB = eta1_;

            found = YES;

            for (NSUInteger i = 0; found && (i < n); ++i)
            {
                CGFloat etaA = etaB;

                etaB += dEta;

                CGFloat error = [self estimateErrorForStartingAngle:etaA endingAngle:etaB];

                found = (error <= THRESHOLD);
            }
        }

        n <<= 1;
    }

    CGFloat dEta = (eta2_ - eta1_) / n;
    CGFloat etaB = eta1_;

    CGFloat cosEtaB = COS(etaB);
    CGFloat sinEtaB = SIN(etaB);
    CGFloat aCosEtaB = a_ * cosEtaB;
    CGFloat bSinEtaB = b_ * sinEtaB;
    CGFloat aSinEtaB = a_ * sinEtaB;
    CGFloat bCosEtaB = b_ * cosEtaB;
    CGFloat xB = cx_ + aCosEtaB * cosTheta_ - bSinEtaB * sinTheta_;
    CGFloat yB = cy_ + aCosEtaB * sinTheta_ + bSinEtaB * cosTheta_;
    CGFloat xBDot = -aSinEtaB * cosTheta_ - bCosEtaB * sinTheta_;
    CGFloat yBDot = -aSinEtaB * sinTheta_ + bCosEtaB * cosTheta_;

    CGFloat t = TAN(0.5f * dEta);
    CGFloat alpha = SIN(dEta) * (SQRT(4.0f + 3.0f * t * t) - 1.0f) / 3.0f;

    for (NSUInteger i = 0; i < n; ++i)
    {
        //CGFloat etaA = etaB;
        CGFloat xA = xB;
        CGFloat yA = yB;
        CGFloat xADot = xBDot;
        CGFloat yADot = yBDot;

        etaB += dEta;

        cosEtaB = COS(etaB);
        sinEtaB = SIN(etaB);
        aCosEtaB = a_ * cosEtaB;
        bSinEtaB = b_ * sinEtaB;
        aSinEtaB = a_ * sinEtaB;
        bCosEtaB = b_ * cosEtaB;
        xB = cx_ + aCosEtaB * cosTheta_ - bSinEtaB * sinTheta_;
        yB = cy_ + aCosEtaB * sinTheta_ + bSinEtaB * cosTheta_;
        xBDot = -aSinEtaB * cosTheta_ - bCosEtaB * sinTheta_;
        yBDot = -aSinEtaB * sinTheta_ + bCosEtaB * cosTheta_;

        CGFloat c1x = (xA + alpha * xADot);
        CGFloat c1y = (yA + alpha * yADot);
        CGFloat c2x = (xB - alpha * xBDot);
        CGFloat c2y = (yB - alpha * yBDot);

        CGPathAddCurveToPoint(path, pTransform, c1x, c1y, c2x, c2y, xB, yB);
    }
}

#pragma mark - Helper Methods

- (CGFloat)estimateErrorForStartingAngle:(CGFloat)etaA endingAngle:(CGFloat)etaB
{
    CGFloat eta = (etaA + etaB) * 0.5f;
    CGFloat x = b_ / a_;
    CGFloat dEta = etaB - etaA;
    CGFloat cos2 = COS(2.0f * eta);
    CGFloat cos4 = COS(4.0f * eta);
    CGFloat cos6 = COS(6.0f * eta);

    CGFloat safety[] = { 0.001f, 4.98f, 0.207f, 0.0067f };
    CGFloat c0, c1;

    if (x < 0.25f)
    {
        c0 = RATIONAL_FUNCTION(x, coeffs3Low[0][0])
            + cos2 * RATIONAL_FUNCTION(x, coeffs3Low[0][1])
            + cos4 * RATIONAL_FUNCTION(x, coeffs3Low[0][2])
            + cos6 * RATIONAL_FUNCTION(x, coeffs3Low[0][3]);

        c1 = RATIONAL_FUNCTION(x, coeffs3Low[1][0])
            + cos2 * RATIONAL_FUNCTION(x, coeffs3Low[1][1])
            + cos4 * RATIONAL_FUNCTION(x, coeffs3Low[1][2])
            + cos6 * RATIONAL_FUNCTION(x, coeffs3Low[1][3]);
    }
    else
    {
        c0 = RATIONAL_FUNCTION(x, coeffs3High[0][0])
            + cos2 * RATIONAL_FUNCTION(x, coeffs3High[0][1])
            + cos4 * RATIONAL_FUNCTION(x, coeffs3High[0][2])
            + cos6 * RATIONAL_FUNCTION(x, coeffs3High[0][3]);

        c1 = RATIONAL_FUNCTION(x, coeffs3High[1][0])
            + cos2 * RATIONAL_FUNCTION(x, coeffs3High[1][1])
            + cos4 * RATIONAL_FUNCTION(x, coeffs3High[1][2])
            + cos6 * RATIONAL_FUNCTION(x, coeffs3High[1][3]);
    }

    return RATIONAL_FUNCTION(x, safety) * a_ * EXP(c0 + c1 * dEta);
}

@end
