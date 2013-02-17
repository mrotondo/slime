//
//  SLSlimerCreationGestureRecognizer.m
//  Slime
//
//  Created by Mike Rotondo on 2/16/13.
//  Copyright (c) 2013 Rototyping. All rights reserved.
//

#import "SLSlimerCreationGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface SLSlimerCreationGestureRecognizer ()

@property (nonatomic, weak) UITouch *firstTouch;
@property (nonatomic) CGPoint touchLocation;

@end

@implementation SLSlimerCreationGestureRecognizer

- (CGPoint)locationInView:(UIView *)view
{
    return [view convertPoint:self.touchLocation fromView:self.view];
}

- (void)reset
{
    self.firstTouch = nil;
    self.touchLocation = CGPointZero;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.firstTouch)
    {
        return;
    }
    
    if (!self.firstTouch && [touches count] > 1)
    {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    self.firstTouch = [touches anyObject];
    self.touchLocation = [self.firstTouch locationInView:self.view];
    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.firstTouch && [touches containsObject:self.firstTouch])
    {
        self.touchLocation = [self.firstTouch locationInView:self.view];
        self.state = UIGestureRecognizerStateChanged;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.firstTouch && [touches containsObject:self.firstTouch])
    {
        self.touchLocation = [self.firstTouch locationInView:self.view];
        self.state = UIGestureRecognizerStateEnded;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.firstTouch && [touches containsObject:self.firstTouch])
    {
        self.touchLocation = [self.firstTouch locationInView:self.view];
        self.state = UIGestureRecognizerStateEnded;
    }
}

@end
