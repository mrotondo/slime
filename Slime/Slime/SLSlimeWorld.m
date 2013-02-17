//
//  SLSlimeWorld.m
//  Slime
//
//  Created by Mike Rotondo on 2/16/13.
//  Copyright (c) 2013 Rototyping. All rights reserved.
//

#import "SLSlimeWorld.h"
#import <Spiral/SPEffectsManager.h>
#import <Spiral/SPGeometricPrimitives.h>
#import "SLSlimer.h"

@interface SLSlimeWorld ()

@property (nonatomic, strong) NSMutableSet *slimers;
@property (nonatomic, strong) SLSlimer *currentSlimer;

@end

@implementation SLSlimeWorld

- (id)init
{
    self = [super init];
    if (self) {
        self.currentViewportCenter = GLKVector2Make(0, 0);
        self.currentViewportZoom = 0.1;

        self.slimers = [NSMutableSet set];
    }
    return self;
}

- (GLKVector2)locationInWorldForNormalizedScreenPoint:(CGPoint)normalizedScreenPoint aspectRatio:(float)aspectRatio
{
    float viewportDimension = 2.0 / self.currentViewportZoom;
    GLKVector2 viewportSize = GLKVector2Make(viewportDimension * aspectRatio, viewportDimension);
    GLKVector2 centeredTouchLocationInViewport = GLKVector2Multiply(GLKVector2SubtractScalar(GLKVector2Make(normalizedScreenPoint.x, normalizedScreenPoint.y),  0.5), viewportSize);
    GLKVector2 touchLocationInWorld = GLKVector2Subtract(centeredTouchLocationInViewport, GLKVector2DivideScalar(self.currentViewportCenter, self.currentViewportZoom));
    return touchLocationInWorld;
}

- (void)startSlimerAtPoint:(GLKVector2)worldPoint
{
    self.currentSlimer = [[SLSlimer alloc] init];
    [self.currentSlimer addRearPoint:worldPoint];
    [self.slimers addObject:self.currentSlimer];
}

- (void)finishSlimerAtPoint:(GLKVector2)worldPoint
{
    [self.currentSlimer addFrontPoint:worldPoint];
    self.currentSlimer = nil;
}

- (void)render
{
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, self.currentViewportCenter.x, self.currentViewportCenter.y, 0.0);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, self.currentViewportZoom, self.currentViewportZoom, 1.0);
    [SPEffectsManager sharedEffectsManager].modelViewMatrix = modelViewMatrix;
    
    [SPGeometricPrimitives drawCircleWithColor:GLKVector4Make(1, 1, 1, 1) andModelViewMatrix:modelViewMatrix];
    
    for (SLSlimer *slimer in self.slimers)
    {
        [slimer render];
    }
}

@end
