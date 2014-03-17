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
//  UIView+PXStyling.m
//  PXButtonDemo
//
//  Created by Kevin Lindsey on 8/22/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PixateFreestyle.h"
#import <objc/runtime.h>
#import "UIView+PXStyling.h"
#import "NSObject+PXSubclass.h"
#import "PXLoggingUtils.h"
#import "PXStyleUtils.h"
#import "PixateFreestyle-Private.h"
#import "PixateFreestyle.h"
#import "PXStylesheet-Private.h"
#import "NSDictionary+PXCSSEncoding.h"
#import "PXRuntimeUtils.h"
#import "PXUtils.h"
#import "NSMutableArray+QueueAdditions.h"
#import "NSObject+PXClass.h"
#import "NSObject+PXStyling.h"
#import "PXStylingMacros.h"

static const char STYLE_CLASS_KEY;
static const char STYLE_CLASSES_KEY;
static const char STYLE_ID_KEY;
static const char STYLE_CHANGEABLE_KEY;
static const char STYLE_CSS_KEY;
static const char STYLE_MODE_KEY;
static const char KVC_DICTIONARY;
static const char KVC_SET;

static Class SubclassForViewWithClass(UIView *view, Class viewClass);
static void getMonthDayYear(NSDate *date, NSInteger *month_p, NSInteger *day_p, NSInteger *year_p);

void PXForceLoadUIViewPXStyling() {}

@implementation UIView (PXStyling)

@dynamic bounds;
@dynamic frame;

static NSMutableDictionary *ELEMENT_NAMES;
static NSMutableArray *DYNAMIC_SUBCLASSES;

#pragma mark - Static Methods

+ (void)addElementName:(NSString *)elementName forClassName:(NSString *)className
{
    if (ELEMENT_NAMES == nil)
    {
        ELEMENT_NAMES = [[NSMutableDictionary alloc] init];
    }

    if (elementName && className)
    {
        [ELEMENT_NAMES setObject:elementName forKey:className];
    }
}

+ (NSString *)elementNameForClassName:(NSString *)className
{
    return [ELEMENT_NAMES objectForKey:className];
}

+ (void)removeElementNameForClassName:(NSString *)className
{
    [ELEMENT_NAMES removeObjectForKey:className];
}

+ (void)addStylingSubclass:(NSString *)className
{
    if(DYNAMIC_SUBCLASSES == nil)
    {
        DYNAMIC_SUBCLASSES = [[NSMutableArray alloc] init];
    }

    if (className)
    {
        [DYNAMIC_SUBCLASSES addObject:NSClassFromString(className)];
    }
}

+ (BOOL)hasStylingSubclass:(NSString *)className
{
    return ([DYNAMIC_SUBCLASSES indexOfObject:NSClassFromString(className)] != NSNotFound);
}

- (BOOL)isSubclassable
{
    return ([self.pxStyleElementName isEqualToString:@"<undefined>"] == NO);
}

+ (void)removeStylingSubclass:(NSString *)className
{
    [DYNAMIC_SUBCLASSES removeObject:NSClassFromString(className)];
}

+ (void)registerDynamicSubclass:(Class)subclass forClass:(Class)superClass withElementName:(NSString *)elementName
{
    @autoreleasepool
    {
        if(subclass && superClass)
        {
            NSString *className = [NSString stringWithCString:class_getName(subclass)
                                                     encoding:NSUTF8StringEncoding];

            NSString *superClassName = [NSString stringWithCString:class_getName(superClass)
                                                          encoding:NSUTF8StringEncoding];


            [self addElementName:elementName forClassName:superClassName];
            [self addStylingSubclass:className];
        }
    }
}

+ (void)registerDynamicSubclass:(Class)subclass withElementName:(NSString *)elementName
{
    @autoreleasepool
    {
        NSString *className = [NSString stringWithCString:class_getName(subclass)
                                                 encoding:NSUTF8StringEncoding];

        NSString *superClassName = [NSString stringWithCString:class_getName(class_getSuperclass(subclass))
                                                      encoding:NSUTF8StringEncoding];


        [self addElementName:elementName forClassName:superClassName];
        [self addStylingSubclass:className];
    }
}

+ (BOOL)subclassIfNeeded:(Class)superClass object:(NSObject *)object
{
    if([object respondsToSelector:@selector(pxClass)] == NO)
    {
        [superClass subclassInstance:object];
        return YES;
    }
    
    return NO;
}

#pragma mark - Dynamic subclassing initializer and property

+ (void)load
{
    @autoreleasepool
    {
#ifdef PX_LOGGING
        // turn on logging
        [PXLoggingUtils enableLogging];

        // set logging level for all classes
        //[PXLoggingUtils setGlobalLoggingLevel:LOG_LEVEL_VERBOSE];
#endif
        // Load default stylesheets and send notification
        NSString* defaultPath = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"css"];
        [PXStylesheet styleSheetFromFilePath:defaultPath withOrigin:PXStylesheetOriginApplication];

        NSString* userPath = [[NSBundle mainBundle] pathForResource:@"user" ofType:@"css"];
        [PXStylesheet styleSheetFromFilePath:userPath withOrigin:PXStylesheetOriginUser];
        
        // Set default styling mode of any UIView to 'normal' (i.e. stylable)
        [[UIView appearance] setStyleMode:PXStylingNormal];
    }
}

#pragma mark - Styling methods for appearance api

- (PXStylingMode)styleMode
{
    NSNumber *modeVal = objc_getAssociatedObject(self, &STYLE_MODE_KEY);

    if(modeVal)
    {
        return modeVal.intValue;
    }

    return PXStylingUndefined;
}

- (void)setStyleMode:(PXStylingMode) mode
{
    //
    // License check
    //
    
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken,
                  ^{
                      NSInteger month, day, year;

                      // Get main info dictionary that keeps plist properties
                      NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

                      // Check for Titanium mode
                      if(infoDictionary && [infoDictionary objectForKey:@"PXTitanium"])
                      {
                          [PixateFreestyle sharedInstance].titaniumMode =
                                [[infoDictionary objectForKey:@"PXTitanium"] boolValue];
                      }

                      getMonthDayYear([PixateFreestyle sharedInstance].buildDate, &month, &day, &year);

                      // Print build info
                      NSLog(@"Pixate Freestyle v%@ (API %d) %@- Build %ld/%02ld/%02ld",
                            [PixateFreestyle sharedInstance].version,
                            [PixateFreestyle sharedInstance].apiVersion,
                            [PixateFreestyle sharedInstance].titaniumMode ? @"Titanium " : @"",
                            (long) year, (long) month, (long) day);


                  });

    //
    // Set the styling mode value on the object
    //
    objc_setAssociatedObject(self, &STYLE_MODE_KEY, [NSNumber numberWithInt:mode], OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    //
    // Perform styling operations
    //
    
    // Style the control
    if (mode == PXStylingNormal)
    {
        // Grabbing Pixate's subclass of this instance
        Class c = SubclassForViewWithClass(self, nil);

        //NSLog(@"%@ : %@ -> %@", [self class], [[self class] superclass], c);

        // We are subclassing 'self' with the Pixate class 'c' we found above
        [c subclassInstance:self];

        // Register for notification center events
        static char Notification;
        if (objc_getAssociatedObject(self, &Notification) == nil)
        {
            objc_setAssociatedObject(self, &Notification, @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);

            if ([self respondsToSelector:@selector(registerNotifications)])
            {
                [self performSelector:@selector(registerNotifications)];
            }
        }

        // List of classes that should not receive styling now (they should style in layoutSubviews or equiv)
        BOOL shouldStyle = !(
                           [self isKindOfClass:[UITableViewCell class]]
                        || [self isKindOfClass:[UICollectionViewCell class]]
                        );

        //NSLog(@"found %@ - Styling: %@", [self class], shouldStyle ? @"YES" : @"NO");

        if (shouldStyle)
        {
            [self updateStyles];
        }
    }
}

#pragma mark - Styling properties on UIView

- (NSString *)pxStyleElementName
{
    Class class = self.class;
    NSString *name = [ELEMENT_NAMES objectForKey:class.description];

    if (!name)
    {
        while (class && !name)
        {
            class = class.superclass;

            if (class)
            {
                name = [ELEMENT_NAMES objectForKey:class.description];
            }
        }

        if (name)
        {
            [ELEMENT_NAMES setObject:name forKey:self.class.description];
        }
    }

    return (name) ? name : @"<undefined>";
}

- (NSString *)styleClass
{
    return objc_getAssociatedObject(self, &STYLE_CLASS_KEY);
}

- (NSArray *)styleClasses
{
    return objc_getAssociatedObject(self, &STYLE_CLASSES_KEY);
}

- (NSString *)styleId
{
    NSString *id = objc_getAssociatedObject(self, &STYLE_ID_KEY);
    return id;
}

- (BOOL)styleChangeable
{
    return [objc_getAssociatedObject(self, &STYLE_CHANGEABLE_KEY) boolValue];
}

- (id)pxStyleParent
{
    return self.superview;
}

- (NSArray *)pxStyleChildren
{
    return self.subviews;
}

- (NSString *)styleCSS
{
    NSMutableDictionary *properties = objc_getAssociatedObject(self, &KVC_DICTIONARY);

    if (properties != nil)
    {
        NSMutableOrderedSet *set = objc_getAssociatedObject(self, &KVC_SET);

        return [properties toCSSWithKeys:[set array]];
    }
    else
    {
        return objc_getAssociatedObject(self, &STYLE_CSS_KEY);
    }
}

- (NSString *)styleKey
{
    return [PXStyleUtils selectorFromStyleable:self];
}

- (void)setStyleClass:(NSString *)aClass
{
    // make sure we have a string - needed to filter bad input from IB
    aClass = [aClass description];

    // trim leading and trailing whitespace
    aClass = [aClass stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    objc_setAssociatedObject(self, &STYLE_CLASS_KEY, aClass, OBJC_ASSOCIATION_COPY_NONATOMIC);

    //Precalculate classes array for performance gain
    NSArray *classes = [aClass componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    classes = [classes sortedArrayUsingComparator:^NSComparisonResult(NSString *class1, NSString *class2) {
        return [class1 compare:class2];
    }];
    objc_setAssociatedObject(self, &STYLE_CLASSES_KEY, classes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
	if ([aClass length])
    {
        self.styleMode = PXStylingNormal;
	}

//    [[PXStyleController sharedInstance] setViewNeedsStyle:self];
}

- (void)setStyleId:(NSString *)anId
{
    // make sure we have a string - needed to filter bad input from IB
    anId = [anId description];

    // trim leading and trailing whitespace
    anId = [anId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    objc_setAssociatedObject(self, &STYLE_ID_KEY, anId, OBJC_ASSOCIATION_COPY_NONATOMIC);

    if ([anId length])
    {
        self.styleMode = PXStylingNormal;
	}

//    [[PXStyleController sharedInstance] setViewNeedsStyle:self];
}

- (void)setStyleChangeable:(BOOL)changeable
{
    objc_setAssociatedObject(self, &STYLE_CHANGEABLE_KEY, [NSNumber numberWithBool:changeable], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setStyleCSS:(NSString *)css
{
    // make sure we have a string - needed to filter bad input from IB
    css = [css description];

    objc_setAssociatedObject(self, &STYLE_CSS_KEY, css, OBJC_ASSOCIATION_COPY_NONATOMIC);

    if ([css length])
    {
        self.styleMode = PXStylingNormal;
	}

//    [[PXStyleController sharedInstance] setViewNeedsStyle:self];
}

- (NSString *)attributeValueForName:(NSString *)name withNamespace:(NSString *)namespace
{
    NSString *stringValue = nil;

    @try
    {
        id value = [self valueForKey:name];

        if ([value isKindOfClass:[NSObject class]])
        {
            stringValue = [(NSObject *)value description];
        }
    }
    @catch (NSException *e) {
        // do nothing
    }

    return stringValue;
}

#pragma mark - Static Styling Method

+ (void)updateStyles:(id<PXStyleable>)styleable recursively:(bool)recurse
{
    if (styleable.styleMode == PXStylingNormal)
    {
        if(recurse)
        {
            for (id<PXStyleable> child in styleable.pxStyleChildren)
            {
                if ([child conformsToProtocol:@protocol(PXVirtualControl)] && child.styleMode == PXStylingNormal)
                {
                    [PXStyleUtils enumerateStyleableDescendants:child usingBlock:^(id<PXStyleable> styleable, BOOL *stop, BOOL *stopDescending)
                    {
                        if ([styleable conformsToProtocol:@protocol(PXVirtualControl)] && styleable.styleMode == PXStylingNormal)
                        {
                            [PXStyleUtils updateStyleForStyleable:styleable];
                        }
                    }];
                    
                    [PXStyleUtils updateStyleForStyleable:child];
                }
            }
        }
        
        [PXStyleUtils updateStylesForStyleable:styleable andDescendants:recurse];
    }
}

#pragma mark - Methods

- (void)updateStyles
{
    [UIView updateStyles:self recursively:YES];
}

- (void)updateStylesNonRecursively
{
    [UIView updateStyles:self recursively:NO];
}

- (void)updateStylesAsync
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateStyles];
    });
}

-(void)updateStylesNonRecursivelyAsync
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateStylesNonRecursively];
    });
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if (value == nil || [value isKindOfClass:[NSString class]])
    {
        NSMutableDictionary *properties = objc_getAssociatedObject(self, &KVC_DICTIONARY);
        NSMutableOrderedSet *set = objc_getAssociatedObject(self, &KVC_SET);

        if ([key hasPrefix:@"+"])
        {
            key = [key substringFromIndex:1];
        }

        if (properties == nil)
        {
            properties = [[NSMutableDictionary alloc] init];
            objc_setAssociatedObject(self, &KVC_DICTIONARY, properties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            set = [[NSMutableOrderedSet alloc] init];
            objc_setAssociatedObject(self, &KVC_SET, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }

        if (key == nil)
        {
            [set removeObject:key];
        }
        else
        {
            [set addObject:key];
        }

        [properties setValue:value forKey:key];
    }
}

- (id)valueForUndefinedKey:(NSString *)key
{
    NSMutableDictionary *properties = objc_getAssociatedObject(self, &KVC_DICTIONARY);

    if ([key hasPrefix:@"+"])
    {
        key = [key substringFromIndex:1];
    }

    id value = [properties objectForKey:key];

    return (value != nil) ? value : [super valueForUndefinedKey:key];
}

@end

#pragma mark - Static Functions

static void getMonthDayYear(NSDate *date, NSInteger *month_p, NSInteger *day_p, NSInteger *year_p)
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];

    *month_p = [components month];
    *day_p   = [components day];
    *year_p  = [components year];
}

static Class SubclassForViewWithClass(UIView *view, Class viewClass)
{
	if (viewClass == nil)
    {
		viewClass = object_getClass(view);
	}

	if ([UIResponder class] == viewClass)
    {
		return nil;
	}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
	if ([view respondsToSelector:@selector(pxClass)])
    {
        return nil;
	}

    if (class_getInstanceMethod(viewClass, @selector(pxClass)) != NULL)
    {
        return nil;
    }
#pragma clang diagnostic pop

	for (Class c in DYNAMIC_SUBCLASSES)
    {
		if (c == viewClass)
        {
			return nil;
		}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        
		if ([c respondsToSelector:@selector(targetSuperclass)])
        {
			if ([c performSelector:@selector(targetSuperclass)] == viewClass)
            {
				return c;
			}
		}
#pragma clang diagnostic pop
        
        else if (class_getSuperclass(c) == viewClass)
        {
			return c;
		}
	}

	return SubclassForViewWithClass(view, class_getSuperclass(viewClass));
}






