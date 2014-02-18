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
//  PXUtils.m
//  Pixate
//
//  Created by Paul Colton on 11/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXUtils.h"

@implementation PXUtils

+ (BOOL)isIOS6OrGreater
{
	static BOOL value =  NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		value = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6");
	});
	return value;
}

+ (BOOL)isBeforeIOS7O
{
	static BOOL value =  NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		value = SYSTEM_VERSION_LESS_THAN(@"7");
	});
	return value;
}

+ (BOOL)isIOS7OrGreater
{
	static BOOL value =  NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		value = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7");
	});
	return value;
}

+ (BOOL)isIPhone
{
	static BOOL value =  NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		value = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
	});
	return value;
}

+ (BOOL)isSimulator
{
	static BOOL value =  NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		value = SIMULATOR;
	});
	return value;
}

@end
