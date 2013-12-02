//
//  FCCubeView.m
//  FlipCube
//
//  Created by daltman on 11/29/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

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
		self.flippingCubeLayerContainer.flippingCubeLayer = [[FCFlippingCubeLayer alloc] init];
		self.flippingCubeLayerContainer.flippingCubeLayer.bounds = self.bounds;
		[self.flippingCubeLayerContainer addSublayer:self.flippingCubeLayerContainer.flippingCubeLayer];
		self.flippingCubeLayerContainer.flippingCubeLayer.contents = (id) [UIImage imageNamed:@"chart1.png"].CGImage;
		self.flippingCubeLayerContainer.flippingCubeLayer.anchorPoint = CGPointMake(0.5, 0.5);
		self.flippingCubeLayerContainer.flippingCubeLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		self.flippingCubeLayerContainer.flippingCubeLayer.opacity = 0.5;						// so we can see lagging face
		self.flippingCubeLayerContainer.flippingCubeLayer.borderColor = [UIColor blackColor].CGColor;
		self.flippingCubeLayerContainer.flippingCubeLayer.borderWidth = 2;
		// add lagging CALayer to container
		self.flippingCubeLayerContainer.flippingCubeLayerLagging = [[FCFlippingCubeLayer alloc] init];
		self.flippingCubeLayerContainer.flippingCubeLayerLagging.bounds = self.bounds;
		[self.flippingCubeLayerContainer addSublayer:self.flippingCubeLayerContainer.flippingCubeLayerLagging];
		self.flippingCubeLayerContainer.flippingCubeLayerLagging.contents = (id) [UIImage imageNamed:@"chart2.png"].CGImage;
		self.flippingCubeLayerContainer.flippingCubeLayerLagging.anchorPoint = CGPointMake(0.5, 0.5);
		self.flippingCubeLayerContainer.flippingCubeLayerLagging.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		self.flippingCubeLayerContainer.flippingCubeLayerLagging.hidden = YES;
		self.flippingCubeLayerContainer.flippingCubeLayerLagging.borderColor = [UIColor blackColor].CGColor;
		self.flippingCubeLayerContainer.flippingCubeLayerLagging.borderWidth = 2;
		// perspective transform for container
		CATransform3D transform = CATransform3DIdentity;
		transform.m34 = -1.0/1000.0;
		self.flippingCubeLayerContainer.sublayerTransform = transform;
	}
	return  self;
}

//	we want to update all kinds of CALayer transforms whenever the rotation changes

- (void)setRotationInRadians:(float)rotationInRadians
{
	if (rotationInRadians > M_PI_2) rotationInRadians = M_PI_2;
	_rotationInRadians = rotationInRadians;
	float width = self.bounds.size.width/2.0;
	float height = self.bounds.size.height/2.0;
	float x = self.rotationDirection == FCHorizontal ? width*sinf(rotationInRadians) : 0;
	float y = self.rotationDirection == FCVertical ? height*sinf(rotationInRadians) : 0;
	float z = self.rotationDirection == FCHorizontal ? -(1.0 - sinf(rotationInRadians+M_PI_2))*height : -(1.0 - sinf(rotationInRadians+M_PI_2))*width;
	// translate in 3D to reflect rotation about cube center
	CATransform3D transformTranslated = CATransform3DTranslate(CATransform3DIdentity, x, y, z);
	// rotate about horizontal or vertical axis
	CATransform3D transform = self.rotationDirection == FCHorizontal ? CATransform3DRotate(transformTranslated, rotationInRadians, 0, 1, 0) : CATransform3DRotate(transformTranslated, -rotationInRadians, 1, 0, 0);
	self.flippingCubeLayerContainer.flippingCubeLayer.transform = transform;
	// deal with the lagging view
	{
		// difference from main face
		if (rotationInRadians > 0)
			rotationInRadians -= M_PI_2;
		else
			rotationInRadians += M_PI_2;
		float x = self.rotationDirection == FCHorizontal ? width*sinf(rotationInRadians) : 0;
		float y = self.rotationDirection == FCVertical ? height*sinf(rotationInRadians) : 0;
		float z = self.rotationDirection == FCHorizontal ? -(1.0 - sinf(rotationInRadians+M_PI_2))*height : -(1.0 - sinf(rotationInRadians+M_PI_2))*width;
		// translate in 3D to reflect rotation about cube center
		CATransform3D transformTranslated = CATransform3DTranslate(CATransform3DIdentity, x, y, z);
		// rotate about horizontal or vertical axis
		CATransform3D transform = self.rotationDirection == FCHorizontal ? CATransform3DRotate(transformTranslated, rotationInRadians, 0, 1, 0) : CATransform3DRotate(transformTranslated, -rotationInRadians, 1, 0, 0);
		self.flippingCubeLayerContainer.flippingCubeLayerLagging.transform = transform;
	}
	// swap chart image on lagging face, depending on direction of movement
	id contents;
	if (self.rotationDirection == FCHorizontal) {
		if (rotationInRadians > 0)
			contents = (id) [UIImage imageNamed:@"chart2.png"].CGImage;
		else
			contents = (id) [UIImage imageNamed:@"chart3.png"].CGImage;
	} else {
		if (rotationInRadians > 0)
			contents = (id) [UIImage imageNamed:@"chart4.png"].CGImage;
		else
			contents = (id) [UIImage imageNamed:@"chart5.png"].CGImage;
	}
	self.flippingCubeLayerContainer.flippingCubeLayerLagging.contents = contents;
	if (fabsf(rotationInRadians) >= 0.001)
		self.flippingCubeLayerContainer.flippingCubeLayerLagging.hidden = NO;
	else
		self.flippingCubeLayerContainer.flippingCubeLayerLagging.hidden = YES;
}

- (float)rotationInRadians
{
	return _rotationInRadians;
}

@end
