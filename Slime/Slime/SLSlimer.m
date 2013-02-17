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
#import <Spiral/SPAnimation.h>

@interface SLSlimer ()
@property (nonatomic) GLKVector4 color;
@property (nonatomic, strong) NSDate *rearPointSetTime;
@property (nonatomic) NSTimeInterval bodyTime;
@property (nonatomic) BOOL hasFrontPoint;
@property (nonatomic) BOOL hasRearPoint;
@property (nonatomic) GLKVector2 frontPoint;
@property (nonatomic) GLKVector2 rearPoint;
@property (nonatomic) GLKVector2 currentFrontPoint;
@property (nonatomic) GLKVector2 currentRearPoint;
@property (nonatomic) GLKVector2 bodyVector;

@end

@implementation SLSlimer

- (id)init
{
    self = [super init];
    if (self) {
        self.color = GLKVector4MakeWithVector3([SPGLKitHelper randomGLKVector3], 1.0);
    }
    return self;
}

- (void)addRearPoint:(GLKVector2)rearPoint
{
    _rearPoint = rearPoint;
    self.currentRearPoint = rearPoint;
    self.hasRearPoint = YES;
    self.rearPointSetTime = [NSDate date];
}

- (void)addFrontPoint:(GLKVector2)frontPoint
{
    _frontPoint = frontPoint;
    self.currentFrontPoint = frontPoint;
    self.hasFrontPoint = YES;

    self.bodyVector = GLKVector2Subtract(self.frontPoint, self.rearPoint);
    self.bodyTime = [[NSDate date] timeIntervalSinceDate:self.rearPointSetTime];
    [self moveRearPoint];
}

- (void)moveRearPoint
{
    [SPAnimation animateGLKVector2From:GLKVector2Make(0, 0) to:self.bodyVector inSeconds:self.bodyTime withCurve:SP_ANIMATION_CURVE_EASE_IN_EASE_OUT andUpdateBlock:^(GLKVector2 currentValue) {
        self.currentRearPoint = GLKVector2Add(self.rearPoint, currentValue);
    } andCompletionBlock:^{
        self.rearPoint = self.currentRearPoint;
        [self moveFrontPoint];
    }];
}

- (void)moveFrontPoint
{
    [SPAnimation animateGLKVector2From:GLKVector2Make(0, 0) to:self.bodyVector inSeconds:self.bodyTime withCurve:SP_ANIMATION_CURVE_EASE_IN_EASE_OUT andUpdateBlock:^(GLKVector2 currentValue) {
        self.currentFrontPoint = GLKVector2Add(self.frontPoint, currentValue);
    } andCompletionBlock:^{
        self.frontPoint = self.currentFrontPoint;
        [self moveRearPoint];
    }];
}

- (void)render
{
    if (self.hasRearPoint)
    {
        GLKMatrix4 firstPointModelViewMatrix = GLKMatrix4Translate([SPEffectsManager sharedEffectsManager].modelViewMatrix,
                                                                   self.currentRearPoint.x, self.currentRearPoint.y, 0.0);
        [SPGeometricPrimitives drawCircleWithColor:self.color andModelViewMatrix:firstPointModelViewMatrix];
    }
    if (self.hasFrontPoint)
    {
        GLKMatrix4 lastPointModelViewMatrix = GLKMatrix4Translate([SPEffectsManager sharedEffectsManager].modelViewMatrix,
                                                                   self.currentFrontPoint.x, self.currentFrontPoint.y, 0.0);
        [SPGeometricPrimitives drawCircleWithColor:self.color andModelViewMatrix:lastPointModelViewMatrix];
    }
    
    if (self.hasRearPoint && self.hasFrontPoint)
    {
        float angle = atan2f(self.bodyVector.y, self.bodyVector.x);
        GLKMatrix4 quadModelViewMatrix = [SPEffectsManager sharedEffectsManager].modelViewMatrix;
        quadModelViewMatrix = GLKMatrix4Translate(quadModelViewMatrix, self.currentRearPoint.x, self.currentRearPoint.y, 0);
        quadModelViewMatrix = GLKMatrix4Rotate(quadModelViewMatrix, angle, 0, 0, 1);
        float distance = GLKVector2Distance(self.currentRearPoint, self.currentFrontPoint);
        quadModelViewMatrix = GLKMatrix4Translate(quadModelViewMatrix, distance / 2, 0, 0);
        quadModelViewMatrix = GLKMatrix4Scale(quadModelViewMatrix, distance, 1, 1);
        [SPGeometricPrimitives drawQuadWithColor:self.color andModelViewMatrix:quadModelViewMatrix];
    }
}

@end
