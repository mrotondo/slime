//
//  SLAppDelegate.h
//  Slime
//
//  Created by Mike Rotondo on 2/16/13.
//  Copyright (c) 2013 Rototyping. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLViewController;

@interface SLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SLViewController *viewController;

@end
