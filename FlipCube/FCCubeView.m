//
//  FCCubeView.m
//  FlipCube
//
//  Created by daltman on 11/29/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "FCOrthoPanGestureRecognizer.h"
#import "FCCubeView.h"

@implementation FCFlippingCubeLayer

@end

@implementation FCFlippingCubeLayerContainer

@end

@implementation FCCubeView

@synthesize rotationInRadians = _rotationInRadians;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//	Add face as sublayer of container layer, using specified image

- (id)addFace:(NSString *)imageName
{
	FCFlippingCubeLayer *layer = [[FCFlippingCubeLayer alloc] init];
	layer.bounds = self.bounds;
	[self.flippingCubeLayerContainer addSublayer:layer];
	layer.contents = (id) [UIImage imageNamed:imageName].CGImage;
	layer.anchorPoint = CGPointMake(0.5, 0.5);
	layer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
	layer.borderColor = [UIColor lightGrayColor].CGColor;
	layer.borderWidth = 5;
	layer.hidden = YES;
	return layer;
}

//	NIB-based initialization

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self) {
		// add flipping cube sublayer container
		self.flippingCubeLayerContainer = [[FCFlippingCubeLayerContainer alloc] init];
		self.flippingCubeLayerContainer.frame = self.bounds;
		[self.layer addSublayer:self.flippingCubeLayerContainer];
		// add main CALayer to container
		self.flippingCubeLayerContainer.faceFront = [self addFace:@"chart1.png"];
		self.flippingCubeLayerContainer.faceFront.hidden = NO;
		self.flippingCubeLayerContainer.faceBack = [self addFace:@"chart2.png"];
		self.flippingCubeLayerContainer.faceTop = [self addFace:@"chart3.png"];
		self.flippingCubeLayerContainer.faceBottom = [self addFace:@"chart4.png"];
		self.flippingCubeLayerContainer.faceRight = [self addFace:@"chart5.png"];
		self.flippingCubeLayerContainer.faceLeft = [self addFace:@"chart6.png"];
		// perspective transform for container
		CATransform3D transform = CATransform3DIdentity;
		transform.m34 = -1.0/1000.0;														// determines degree of perspective applied
		self.flippingCubeLayerContainer.sublayerTransform = transform;
		// pre-transform faces to avoid startup artifacts
		self.rotationDirection = FCVertical;
		[self transformFace:self.flippingCubeLayerContainer.faceTop rotation:-M_PI_2];
		[self transformFace:self.flippingCubeLayerContainer.faceBottom rotation:M_PI_2];
		self.rotationDirection = FCHorizontal;
		[self transformFace:self.flippingCubeLayerContainer.faceLeft rotation:-M_PI_2];
		[self transformFace:self.flippingCubeLayerContainer.faceRight rotation:M_PI_2];
	}
	return  self;
}

- (void)transformFace:(FCFlippingCubeLayer *)face rotation:(float)rotationInRadians
{
	float width = self.bounds.size.width/2.0;
	float height = self.bounds.size.height/2.0;
	float x = self.rotationDirection == FCHorizontal ? width*sinf(rotationInRadians) : 0;				// move x for horizontal rotations, since we're revolving about the cube's center
	float y = self.rotationDirection == FCVertical ? height*sinf(rotationInRadians) : 0;				// move y for vertical rotations, since we're revolving about the cube's center
	float z = self.rotationDirection == FCHorizontal ? -(1.0 - sinf(rotationInRadians+M_PI_2))*width : -(1.0 - sinf(rotationInRadians+M_PI_2))*height;	// the center of the cube is behind the face!
	// translate in 3D to reflect rotation about cube center
	CATransform3D transformTranslated = CATransform3DTranslate(CATransform3DIdentity, x, y, z);
	// rotate about horizontal or vertical axis
	CATransform3D transform = self.rotationDirection == FCHorizontal ? CATransform3DRotate(transformTranslated, rotationInRadians, 0, 1, 0) : CATransform3DRotate(transformTranslated, -rotationInRadians, 1, 0, 0);
	[CATransaction setDisableActions:!self.isAnimating];							// want to disable implicit layer animation during gesture, as it interferes with smooth imaging
	face.transform = transform;														// apply the transform to the CALayer sublayer
}

//	we want to update all kinds of CALayer transforms whenever the rotation changes

- (void)setRotationInRadians:(float)rotationInRadians
{
	if (rotationInRadians > +M_PI_2) rotationInRadians = +M_PI_2;					// temporarily limit the rotation
	if (rotationInRadians < -M_PI_2) rotationInRadians = -M_PI_2;					// temporarily limit the rotation
	_previousRotationInRadians = _rotationInRadians;								// when we start out animation, want to know which way the cube is facing
	_rotationInRadians = rotationInRadians;
}

- (float)rotationInRadians
{
	return _rotationInRadians;
}

//	Apply rotations to cube faces in drawRect (somewhat arbitrary). Only rotate visible faces. Apply visibility.
//	Special logic for animation: we don't want to change the visibility from its previous state, or the animation will give unexpected results!

- (void)drawRect:(CGRect)rect
{
	static float magic = 0.14;																// to determine whether a side (non-facing) is visible, based on perspective (TODO: calculate)
	float rotationInRadians = self.rotationInRadians;
	[self transformFace:self.flippingCubeLayerContainer.faceFront rotation:rotationInRadians];
	if (self.rotationDirection == FCVertical) {
		// transform the relevant side faces if they're visible (if we're doing implicit layer animation: always do the transform!)
		if (rotationInRadians > +magic || self.isAnimating) [self transformFace:self.flippingCubeLayerContainer.faceTop rotation:rotationInRadians-M_PI_2];
		if (rotationInRadians < -magic || self.isAnimating) [self transformFace:self.flippingCubeLayerContainer.faceBottom rotation:rotationInRadians+M_PI_2];
		self.flippingCubeLayerContainer.faceLeft.hidden =	YES;
		self.flippingCubeLayerContainer.faceRight.hidden =	YES;
		// make side faces visible only if we can see them (if we're doing implicit layer animation: always do the transform!)
		// during animation, if the side was visible before, want to maintain its visibility
		self.flippingCubeLayerContainer.faceTop.hidden =	rotationInRadians > +magic || (self.isAnimating && _previousRotationInRadians > 0) ? NO : YES;
		self.flippingCubeLayerContainer.faceBottom.hidden = rotationInRadians < -magic || (self.isAnimating && _previousRotationInRadians < 0) ? NO : YES;
	} else {
		// transform the relevant side faces if they're visible (if we're doing implicit layer animation: always do the transform!)
		if (rotationInRadians > +magic || self.isAnimating) [self transformFace:self.flippingCubeLayerContainer.faceLeft rotation:rotationInRadians-M_PI_2];
		if (rotationInRadians < -magic || self.isAnimating) [self transformFace:self.flippingCubeLayerContainer.faceRight rotation:rotationInRadians+M_PI_2];
		// make side faces visible only if we can see them (if we're doing implicit layer animation: always do the transform!)
		// during animation, if the side was visible before, want to maintain its visibility
		self.flippingCubeLayerContainer.faceLeft.hidden =	rotationInRadians > +magic || (self.isAnimating && _previousRotationInRadians > 0) ? NO : YES;
		self.flippingCubeLayerContainer.faceRight.hidden =	rotationInRadians < -magic || (self.isAnimating && _previousRotationInRadians < 0) ? NO : YES;
		self.flippingCubeLayerContainer.faceTop.hidden =	YES;
		self.flippingCubeLayerContainer.faceBottom.hidden =	YES;
	}
}

- (void)startAnimation
{
	[CATransaction setAnimationDuration:1];													// do it here for now
	self.isAnimating = YES;
}

- (void)disableAnimation
{
	self.isAnimating = NO;
}

@end
