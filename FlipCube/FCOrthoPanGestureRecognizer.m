//
//  FCOrthoPanGestureRecognizer.m
//  FlipCube
//
//  Created by daltman on 11/29/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "FCOrthoPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

/*
 Subclasses PanGestureRecognizer, detects whether the initial movement (based on a minimum threshold) is horizontal or vertical. If the user's horizontal (or vertical) position
 returns to the zero state (within a threshold), the direction is allowed to change, so that the user can flip horizontally followed by vertically (and vice versa).
 
 Layer enhancement: if the user flips to any row (or column), that row (or column) can be explored, followed by exploring a new column (or row). Thus, the entire matrix can
 be explored using a single gesture.
 */

@implementation FCOrthoPanGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	self.startPoint = CGPointMake([[touches anyObject] locationInView:self.view].x, [[touches anyObject] locationInView:self.view].y);
	self.firstTouchMove = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	float xDist = fabs([[touches anyObject] locationInView:self.view].x-self.startPoint.x);
	float yDist = fabs([[touches anyObject] locationInView:self.view].y-self.startPoint.y);
	static float threshold = 25;
	//	detect a direction, only a one-shot, based on minimum movement
	if (self.firstTouchMove && (xDist > threshold || yDist > threshold)) {
		self.direction = xDist > yDist ? FCHorizontal : FCVertical;
		self.firstTouchMove = NO;
	}
	//	allow the user to change direction, if he returns to the initial point (in the dimension in which the previous movement was detected)
	if (!self.firstTouchMove) {
		if (self.direction == FCVertical) {
			if (fabsf(self.cubeView.rotationInRadians) < 0.1) {
				self.firstTouchMove = YES;
				self.startPoint = CGPointMake([[touches anyObject] locationInView:self.view].x, [[touches anyObject] locationInView:self.view].y);
			}
		} else {
			if (fabsf(self.cubeView.rotationInRadians) < 0.1) {
				self.firstTouchMove = YES;
				self.startPoint = CGPointMake([[touches anyObject] locationInView:self.view].x, [[touches anyObject] locationInView:self.view].y);
			}
		}
	}
	[super touchesMoved:touches withEvent:event];
}

@end
