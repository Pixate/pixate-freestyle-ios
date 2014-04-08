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
//  PXUITableViewDelegate.m
//  Pixate
//
//  Created by Paul Colton on 11/24/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXUITableViewDelegate.h"
#import <objc/runtime.h>
#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "PXUITableViewCell.h"
#import "PXUITableViewHeaderFooterView.h"
#import "PXProxy.h"

@implementation PXUITableViewDelegate

#pragma mark - delegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Apparently we need to do this because at times, we get normal cells here.
    if([UIView subclassIfNeeded:[PXUITableViewHeaderFooterView class] object:view] == YES)
    {
        view.styleMode = PXStylingNormal;
    }
    
    [view updateStyles];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    // Apparently we need to do this because at times, we get normal cells here.
    if([UIView subclassIfNeeded:[PXUITableViewHeaderFooterView class] object:view] == YES)
    {
        view.styleMode = PXStylingNormal;
    }
    
    [view updateStyles];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([UIView subclassIfNeeded:[PXUITableViewCell class] object:cell] == YES)
    {
        cell.styleMode = PXStylingNormal;
    }
    
    [PXStyleUtils setItemIndex:indexPath forObject:cell];
    
    [cell updateStyles];
    
    [PXStyleUtils setItemIndex:nil forObject:cell];
}

#pragma mark - datasource

/* 
 * Added to prevent an exception described below on iOS6 when using UIDatePicker
 *
 * Uncaught exception 'NSInvalidArgumentException', reason: '*** -[NSProxy
 * doesNotRecognizeSelector:tableView:numberOfRowsInSection:] called
 *
 */
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    NSLog(@"numberOfRowsInSection: %@", [((PXProxy *)tableView.dataSource) baseObject]);
//    
//    return [[((PXProxy *)tableView.dataSource) baseObject] tableView:tableView numberOfRowsInSection:section];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"cellForRowAtIndexPath: %@", [((PXProxy *)tableView.dataSource) baseObject]);
//
//    return [[((PXProxy *)tableView.dataSource) baseObject] tableView:tableView cellForRowAtIndexPath:indexPath];
//}

//
// Keep for now until we decide whether we should be doing text transforms this way instead.
//
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *title = [[((PXProxy *) tableView.dataSource) baseObject] tableView:tableView
//                                                         titleForHeaderInSection:section];
//
//    return title;
//}

@end

