//
//  FCOrthoPanGestureRecognizer.h
//  FlipCube
//
//  Created by daltman on 11/29/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCCubeView.h"
#import "FCDirection.h"

@interface FCOrthoPanGestureRecognizer : UIPanGestureRecognizer

@property CGPoint		startPoint;
@property FCDirection	direction;
@property BOOL			firstTouchMove;
@property (weak, nonatomic) IBOutlet FCCubeView *cubeView;

@end
