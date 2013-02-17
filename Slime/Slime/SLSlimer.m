//
//  SLSlimer.m
//  Slime
//
//  Created by Mike Rotondo on 2/16/13.
//  Copyright (c) 2013 Rototyping. All rights reserved.
//

#import "SLSlimer.h"
#import <Spiral/SPGeometricPrimitives.h>
#import <Spiral/SPGLKitHelper.h>
#import <Spiral/SPEffectsManager.h>

@interface SLSlimer ()

@property (nonatomic) BOOL hasFirstPoint;
@property (nonatomic) BOOL hasLastPoint;

@end

@implementation SLSlimer

- (void)setFirstPoint:(GLKVector2)firstPoint
{
    _firstPoint = firstPoint;
    self.hasFirstPoint = YES;
}

- (void)setLastPoint:(GLKVector2)lastPoint
{
    _lastPoint = lastPoint;
    self.hasLastPoint = YES;
}

- (void)render
{
    if (self.hasFirstPoint)
    {
        GLKMatrix4 firstPointModelViewMatrix = GLKMatrix4Translate([SPEffectsManager sharedEffectsManager].modelViewMatrix,
                                                                   self.firstPoint.x, self.firstPoint.y, 0.0);
        [SPGeometricPrimitives drawCircleWithColor:GLKVector4MakeWithVector3([SPGLKitHelper randomGLKVector3], 1.0) andModelViewMatrix:firstPointModelViewMatrix];
    }
    if (self.hasLastPoint)
    {
        GLKMatrix4 lastPointModelViewMatrix = GLKMatrix4Translate([SPEffectsManager sharedEffectsManager].modelViewMatrix,
                                                                   self.lastPoint.x, self.lastPoint.y, 0.0);
        [SPGeometricPrimitives drawCircleWithColor:GLKVector4MakeWithVector3([SPGLKitHelper randomGLKVector3], 1.0) andModelViewMatrix:lastPointModelViewMatrix];
    }
}

@end
