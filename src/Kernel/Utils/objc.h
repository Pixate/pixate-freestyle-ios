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
//  objc.h
//
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#ifndef PXStyleKit_objc_h
#define PXStyleKit_objc_h

#ifdef __OBJC__
#import <objc/runtime.h>
#import <objc/message.h>
#else
#include <objc/runtime.h> 
#include <objc/message.h>
#endif

#include <CoreGraphics/CGBase.h>

extern void* callSuper0(id self, Class superClass, SEL _cmd);
extern void* callSuper1(id self, Class superClass, SEL _cmd, id arg1);
extern void* callSuper1b(id self, Class superClass, SEL _cmd, BOOL arg1);
extern void* callSuper1v(id self, Class superClass, SEL _cmd, void *arg1);
extern void* callSuper2(id self, Class superClass, SEL _cmd, id arg1, id arg2);
extern void* callSuper2v(id self, Class superClass, SEL _cmd, id arg1, void *arg2);
extern void* callSuper2vv(id self, Class superClass, SEL _cmd, void *arg1, void *arg2);
extern void* callSuper3v(id self, Class superClass, SEL _cmd, id arg1, void *arg2, void *arg3);
extern void* callSuper4v(id self, Class superClass, SEL _cmd, id arg1, void *arg2, void *arg3, void *arg4);

extern void copyIndexedIvars(id src, id dest, size_t size);

#define CALL_SUPER1(self, superClass, sel, TYPE1, arg1)	\
{	\
	Class _superClass = superClass;	\
	struct objc_super super;	\
	super.receiver = self;	\
	super.super_class = _superClass != NULL ? _superClass : class_getSuperclass(object_getClass(self));	\
	((void(*)(struct objc_super*, SEL, TYPE1))objc_msgSendSuper)(&super, sel, arg1);	\
}

#define CALL_SUPER2(self, superClass, sel, TYPE1, TYPE2, arg1, arg2)	\
{	\
	Class _superClass = superClass;	\
	struct objc_super super;	\
	super.receiver = self;	\
	super.super_class = _superClass != NULL ? _superClass : class_getSuperclass(object_getClass(self));	\
	((void(*)(struct objc_super*, SEL, TYPE1, TYPE2))objc_msgSendSuper)(&super, sel, arg1, arg2);	\
}

#define CALL_SUPER3(self, superClass, sel, TYPE1, TYPE2, TYPE3, arg1, arg2, arg3)	\
{	\
	Class _superClass = superClass;	\
	struct objc_super super;	\
	super.receiver = self;	\
	super.super_class = _superClass != NULL ? _superClass : class_getSuperclass(object_getClass(self));	\
	((void(*)(struct objc_super*, SEL, TYPE1, TYPE2, TYPE3))objc_msgSendSuper)(&super, sel, arg1, arg2, arg3);	\
}

#define CALL_SUPER4(self, superClass, sel, TYPE1, TYPE2, TYPE3, TYPE4, arg1, arg2, arg3, arg4)	\
{	\
	Class _superClass = superClass;	\
	struct objc_super super;	\
	super.receiver = self;	\
	super.super_class = _superClass != NULL ? _superClass : class_getSuperclass(object_getClass(self));	\
	((void(*)(struct objc_super*, SEL, TYPE1, TYPE2, TYPE3, TYPE4))objc_msgSendSuper)(&super, sel, arg1, arg2, arg3, arg4);	\
}

#endif
