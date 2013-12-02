//
//  FCViewController.m
//  FlipCube
//
//  Created by daltman on 11/29/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "FCViewController.h"
#import "FCOrthoPanGestureRecognizer.h"

@interface FCViewController ()

@end

@implementation FCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	// receive orientation change notifications
}

//	center the cubeview, even on startup

- (void)viewDidLayoutSubviews
{
	self.CubeView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	self.CubeView.center = CGPointMake(self.view.bounds.size.height/2, self.view.bounds.size.width/2);			// do the reverse, because it hasn't rotated yet
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handlePanGestureRecognizer:(FCOrthoPanGestureRecognizer *)gestureRecognizer {
	UIView *view = gestureRecognizer.view;
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {     // beginning a pan
		self.initialPoint = [gestureRecognizer locationInView:view];
	} else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
		self.CubeView.rotationDirection = gestureRecognizer.direction;
		float rotationAngle = gestureRecognizer.direction == FCHorizontal ?
		([gestureRecognizer locationInView:view].x - self.initialPoint.x) / 250. : ([gestureRecognizer locationInView:view].y - self.initialPoint.y) / 250.;
		self.CubeView.rotationInRadians = rotationAngle;
		[self.CubeView setNeedsDisplay];
	} else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		self.CubeView.rotationInRadians = 0;
		[self.CubeView setNeedsDisplay];
	}
}

- (void)viewDidUnload {
	[self setCubeView:nil];
	[super viewDidUnload];
}
@end
