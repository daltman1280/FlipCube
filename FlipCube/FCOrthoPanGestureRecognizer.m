//
//  FCOrthoPanGestureRecognizer.m
//  FlipCube
//
//  Created by daltman on 11/29/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "FCOrthoPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation FCOrthoPanGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	self.startPoint = CGPointMake([[touches anyObject] locationInView:self.view].x, [[touches anyObject] locationInView:self.view].y);
	self.firstTouchMove = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.firstTouchMove) {
		float xDist = fabs([[touches anyObject] locationInView:self.view].x-self.startPoint.x);
		float yDist = fabs([[touches anyObject] locationInView:self.view].y-self.startPoint.y);
		self.direction = xDist > yDist ? FCHorizontal : FCVertical;
		self.firstTouchMove = NO;
	}
	[super touchesMoved:touches withEvent:event];
}

@end
