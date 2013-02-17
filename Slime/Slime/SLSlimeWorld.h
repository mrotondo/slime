//
//  SLSlimeWorld.h
//  Slime
//
//  Created by Mike Rotondo on 2/16/13.
//  Copyright (c) 2013 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface SLSlimeWorld : NSObject

@property (nonatomic) GLKVector2 currentViewportCenter;
@property (nonatomic) float currentViewportZoom;
@property (nonatomic) GLKVector2 size;

- (GLKVector2)locationInWorldForNormalizedScreenPoint:(CGPoint)normalizedScreenPoint aspectRatio:(float)aspectRatio;
- (void)startSlimerAtPoint:(GLKVector2)worldPoint;
- (void)finishSlimerAtPoint:(GLKVector2)worldPoint;
- (void)render;

@end
