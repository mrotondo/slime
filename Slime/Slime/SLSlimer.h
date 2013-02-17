//
//  SLSlimer.h
//  Slime
//
//  Created by Mike Rotondo on 2/16/13.
//  Copyright (c) 2013 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface SLSlimer : NSObject

@property (nonatomic) GLKVector2 firstPoint;
@property (nonatomic) GLKVector2 lastPoint;

- (void)render;

@end
