//
//  PXXPath.m
//  Pixate
//
//  Created by Kevin Lindsey on 11/13/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "PXXPath.h"
#import "NSMutableArray+QueueAdditions.h"

@implementation PXXPath

- (NSArray *)findNodesFromNode:(id<PXDOMNode>)node withPath:(NSString *)path
{
    NSArray *steps = [path componentsSeparatedByString:@"/"];
    __block NSMutableArray *result = [[NSMutableArray alloc] init];

    // process each step in our path
    [steps enumerateObjectsUsingBlock:^(NSString *step, NSUInteger idx, BOOL *stop) {
        if (step.length == 0)
        {
            // we found either a slash at the beginning of the path or two consecutive slashes

            if (idx == 0)
            {
                // This is a leading slash, so add the specified node to our result set
                [result addObject:node];
            }
            else
            {
                // This is an empty step coming from two slashes, so we collect all descendants of all nodes in our
                // current result set
                NSMutableArray *descendants = [[NSMutableArray alloc] init];

                // Visit each node in our current result set, collecting all descendants for each
                [result enumerateObjectsUsingBlock:^(id<PXDOMNode> currentNode, NSUInteger idx, BOOL *stop) {
                    // The only way the current node can be in the result list is if we've already processed one of its
                    // ancestor nodes. Without this test, we would grab all descendants and then add none; effectively a
                    // rather expensive no-op
                    if ([descendants indexOfObject:currentNode] == NSNotFound)
                    {
                        NSArray *descendantsForNode = [self collectDescendantsForNode:currentNode];

                        // Only add nodes that we don't know about already
                        [descendantsForNode enumerateObjectsUsingBlock:^(id<PXDOMNode> candidateNode, NSUInteger idx, BOOL *stop) {
                            if ([descendants indexOfObject:candidateNode] == NSNotFound)
                            {
                                [descendants addObject:candidateNode];
                            }
                        }];
                    }
                }];

                result = descendants;
            }
        }
        else
        {
            // find all nodes in the current result set that are "step" elements
            result = [self filterList:result withElementName:step];
        }
    }];

    return [NSArray arrayWithArray:result];
}

- (NSArray *)collectDescendantsForNode:(id<PXDOMNode>)node
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSMutableArray *queue = [[NSMutableArray alloc] init];

    // push children onto queue
    [queue addObjectsFromArray:node.children];

    // process queue
    while (queue.count > 0)
    {
        id<PXDOMNode> currentNode = [queue dequeue];

        [result addObject:currentNode];

        [queue addObjectsFromArray:currentNode.children];
    }

    return [NSArray arrayWithArray:result];
}

- (NSMutableArray *)filterList:(NSMutableArray *)set withElementName:(NSString *)elementName
{
    if ([@"*" isEqualToString:elementName])
    {
        return set;
    }
    else
    {
        NSMutableArray *result = [[NSMutableArray alloc] init];

        [set enumerateObjectsUsingBlock:^(id<PXDOMNode> node, NSUInteger idx, BOOL *stop) {
            if ([node.name isEqualToString:elementName])
            {
                [result addObject:node];
            }
        }];

        return result;
    }
}

@end
