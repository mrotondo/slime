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

@interface SLViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *effect;
@property (nonatomic, strong) SLSlimerCreationGestureRecognizer *drawGestureRecognizer;
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
    
    self.drawGestureRecognizer = [[SLSlimerCreationGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleSlimerCreation:)];
    self.drawGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.drawGestureRecognizer];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinchGestureRecognizer.delegate = self;
    [pinchGestureRecognizer requireGestureRecognizerToFail:self.drawGestureRecognizer];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGestureRecognizer.minimumNumberOfTouches = 2;
    panGestureRecognizer.delegate = self;
    [panGestureRecognizer requireGestureRecognizerToFail:self.drawGestureRecognizer];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
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

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
    self.world.currentViewportZoom *= gestureRecognizer.scale;
    [gestureRecognizer setScale:1];
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self.view];
    CGPoint normalizedTranslationInView = CGPointMake(translation.x / self.view.bounds.size.width,
                                                      -1.0 * translation.y / self.view.bounds.size.height);
    float aspectRatio = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    CGPoint aspectRatioNormalizedTranslationInView = CGPointMake(normalizedTranslationInView.x * aspectRatio, normalizedTranslationInView.y);
    self.world.currentViewportCenter = GLKVector2Add(self.world.currentViewportCenter,
                                                     GLKVector2Make(aspectRatioNormalizedTranslationInView.x, aspectRatioNormalizedTranslationInView.y));
    [gestureRecognizer setTranslation:CGPointZero inView:self.view];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isEqual:self.drawGestureRecognizer] || [otherGestureRecognizer isEqual:self.drawGestureRecognizer])
    {
        return NO;
    }
    else
    {
        return YES;
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
