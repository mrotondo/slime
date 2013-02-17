//
//  SLSlimer.h
//  Slime
//
//  Created by Mike Rotondo on 2/16/13.
//  Copyright (c) 2013 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class SLSlimeWorld;

@interface SLSlimer : NSObject

@property (nonatomic, strong) SLSlimeWorld *world;

- (void)addRearPoint:(GLKVector2)rearPoint;
- (void)addFrontPoint:(GLKVector2)frontPoint;

- (void)render;

@end
