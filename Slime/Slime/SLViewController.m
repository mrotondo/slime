//
//  SLViewController.m
//  Slime
//
//  Created by Mike Rotondo on 2/16/13.
//  Copyright (c) 2013 Rototyping. All rights reserved.
//

#import "SLViewController.h"
#import <Spiral/SPGeometricPrimitives.h>
#import <Spiral/SPEffectsManager.h>
#import <Spiral/SPAnimation.h>
#import "SLSlimerCreationGestureRecognizer.h"
#import "SLSlimeWorld.h"

@interface SLViewController ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *effect;
@property (nonatomic, strong) SLSlimeWorld *world;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation SLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.preferredFramesPerSecond = 60;
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    
    [self setupGL];
    
    SLSlimerCreationGestureRecognizer *gestureRecognizer = [[SLSlimerCreationGestureRecognizer alloc] initWithTarget:self
                                                                                                              action:@selector(handleSlimerCreation:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.world = [[SLSlimeWorld alloc] init];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glEnable(GL_DEPTH_TEST);
        
    [SPEffectsManager initializeSharedEffectsManager];
    [SPGeometricPrimitives initializeSharedGeometricPrimitives];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - Touch handling

- (void)handleSlimerCreation:(SLSlimerCreationGestureRecognizer *)gestureRecognizer
{
    CGPoint touchLocationInView = [gestureRecognizer locationInView:self.view];
    CGPoint normalizedTouchLocationInView = CGPointMake(touchLocationInView.x / self.view.bounds.size.width,
                                                        1.0 - touchLocationInView.y / self.view.bounds.size.height);
    float aspectRatio = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKVector2 touchLocationInWorld = [self.world locationInWorldForNormalizedScreenPoint:normalizedTouchLocationInView aspectRatio:aspectRatio];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self.world startSlimerAtPoint:touchLocationInWorld];
            break;
        case UIGestureRecognizerStateEnded:
            [self.world finishSlimerAtPoint:touchLocationInWorld];
            break;
        default:
            break;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    [SPAnimation updateAnimationsWithTimeElapsed:self.timeSinceLastUpdate];
    
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);

    GLKMatrix4 orthoMatrix = GLKMatrix4MakeOrtho(-aspect, aspect, -1.0, 1.0, -1.0, 1.0);
    [SPEffectsManager sharedEffectsManager].projectionMatrix = orthoMatrix;
    [SPEffectsManager sharedEffectsManager].modelViewMatrix = GLKMatrix4Identity;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.25f, 0.25f, 0.25f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
//    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
//    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.2, 0.2, 1.0);
//    [SPGeometricPrimitives drawCircleWithColor:GLKVector4Make(1.0, 0.5, 0.0, 1.0) andModelViewMatrix:modelViewMatrix];
    
    [self.world render];
}

@end
