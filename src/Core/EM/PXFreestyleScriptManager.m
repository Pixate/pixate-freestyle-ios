//
//  PXFreestyleScriptManager.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXFreestyleScriptManager.h"
#import "PXFreestyleBuiltInScope.h"

@implementation PXFreestyleScriptManager

- (Class)globalScopeClass
{
    return [PXFreestyleBuiltInScope class];
}

@end
