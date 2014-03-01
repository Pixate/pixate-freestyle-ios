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
//  objc.c
//
//  Created by Pixate on 8/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#include "objc.h"
#include <string.h>

#define __bridge

void* callSuper0(id self, Class superClass, SEL _cmd)
{
	struct objc_super super;
	super.receiver = (__bridge void *)self;
	super.class = superClass != NULL ? superClass : class_getSuperclass(object_getClass(self));
	return objc_msgSendSuper(&super, _cmd);
}

void* callSuper1(id self, Class superClass, SEL _cmd, id arg1)
{
	struct objc_super super;
	super.receiver = (__bridge void *) self;
	super.class = superClass != NULL ? superClass : class_getSuperclass(object_getClass(self));
    
    void* (*objc_msgSendSuperTyped)(id self, SEL _cmd, void *arg1) = (void*)objc_msgSendSuper;

	return objc_msgSendSuperTyped((id) &super, _cmd, arg1);
}

void* callSuper1b(id self, Class superClass, SEL _cmd, BOOL arg1)
{
	struct objc_super super;
	super.receiver = (__bridge void *)self;
	super.class = superClass != NULL ? superClass : class_getSuperclass(object_getClass(self));
    
    void* (*objc_msgSendSuperTyped)(id self, SEL _cmd, BOOL arg1) = (void*)objc_msgSendSuper;

	return objc_msgSendSuperTyped((id) &super, _cmd, arg1);
}


void* callSuper1v(id self, Class superClass, SEL _cmd, void *arg1)
{
	struct objc_super super;
	super.receiver = (__bridge void *)self;
	super.class = superClass != NULL ? superClass : class_getSuperclass(object_getClass(self));
    
    void* (*objc_msgSendSuperTyped)(id self, SEL _cmd, void *arg1) = (void*)objc_msgSendSuper;

	return objc_msgSendSuperTyped((id) &super, _cmd, arg1);
}

void* callSuper2(id self, Class superClass, SEL _cmd, id arg1, id arg2)
{
	struct objc_super super;
	super.receiver = (__bridge void *)self;
	super.class = superClass != NULL ? superClass : class_getSuperclass(object_getClass(self));
    
    void* (*objc_msgSendSuperTyped)(id self, SEL _cmd, id arg1, void * arg2) = (void*)objc_msgSendSuper;

	return objc_msgSendSuperTyped((id) &super, _cmd, arg1, arg2);
}

void* callSuper2v(id self, Class superClass, SEL _cmd, id arg1, void *arg2)
{
	struct objc_super super;
	super.receiver = (__bridge void *)self;
	super.class = superClass != NULL ? superClass : class_getSuperclass(object_getClass(self));
    
    void* (*objc_msgSendSuperTyped)(id self, SEL _cmd, void *arg1, void *arg2) = (void*)objc_msgSendSuper;

	return objc_msgSendSuperTyped((id) &super, _cmd, arg1, arg2);
}

// The two arg params are cast to CGFloat and 'int', respectively
void* callSuper2vv(id self, Class superClass, SEL _cmd, void *arg1, void *arg2)
{
    CGFloat *arg1_ref = arg1;
    
	struct objc_super super;
	super.receiver = (__bridge void *)self;
	super.class = superClass != NULL ? superClass : class_getSuperclass(object_getClass(self));

    // Need to cast it to the the appropriate type signatures so the float comes in correctly
    void* (*objc_msgSendSuperTyped)(id self, SEL _cmd, CGFloat val1, int val2) = (void*)objc_msgSendSuper;

	return objc_msgSendSuperTyped((id) &super, _cmd, *arg1_ref, (int) arg2);
}

void* callSuper3v(id self, Class superClass, SEL _cmd, id arg1, void *arg2, void *arg3)
{
	struct objc_super super;
	super.receiver = (__bridge void *)self;
	super.class = superClass != NULL ? superClass : class_getSuperclass(object_getClass(self));
    
    void* (*objc_msgSendSuperTyped)(id self, SEL _cmd, void *arg1, void *arg2, void *arg3) = (void*)objc_msgSendSuper;

	return objc_msgSendSuperTyped((id) &super, _cmd, arg1, arg2, arg3);
}

void* callSuper4v(id self, Class superClass, SEL _cmd, id arg1, void *arg2, void *arg3, void *arg4)
{
	struct objc_super super;
	super.receiver = (__bridge void *)self;
	super.class = superClass != NULL ? superClass : class_getSuperclass(object_getClass(self));
    
    void* (*objc_msgSendSuperTyped)(id self, SEL _cmd, void *arg1, void *arg2, void *arg3, void *arg4) = (void*)objc_msgSendSuper;

	return objc_msgSendSuperTyped((id) &super, _cmd, arg1, arg2, arg3, arg4);
}


void copyIndexedIvars(id src, id dest, size_t size)
{
    memmove((__bridge void *)object_getIndexedIvars(dest), (__bridge void *)object_getIndexedIvars(src), size);
}

