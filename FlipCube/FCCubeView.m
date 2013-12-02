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

- (id)addFace:(NSString *)imageName
{
	FCFlippingCubeLayer *layer = [[FCFlippingCubeLayer alloc] init];
	layer.bounds = self.bounds;
	[self.flippingCubeLayerContainer addSublayer:layer];
	layer.contents = (id) [UIImage imageNamed:imageName].CGImage;
	layer.anchorPoint = CGPointMake(0.5, 0.5);
	layer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
//	layer.opacity = 0.5;						// so we can see lagging face
	layer.borderColor = [UIColor blackColor].CGColor;
	layer.borderWidth = 2;
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
		transform.m34 = -1.0/1000.0;
		self.flippingCubeLayerContainer.sublayerTransform = transform;
	}
	return  self;
}

- (void)transformFace:(FCFlippingCubeLayer *)face rotation:(float)rotationInRadians
{
	float width = self.bounds.size.width/2.0;
	float height = self.bounds.size.height/2.0;
	float x = self.rotationDirection == FCHorizontal ? width*sinf(rotationInRadians) : 0;
	float y = self.rotationDirection == FCVertical ? height*sinf(rotationInRadians) : 0;
	float z = self.rotationDirection == FCHorizontal ? -(1.0 - sinf(rotationInRadians+M_PI_2))*height : -(1.0 - sinf(rotationInRadians+M_PI_2))*width;
	// translate in 3D to reflect rotation about cube center
	CATransform3D transformTranslated = CATransform3DTranslate(CATransform3DIdentity, x, y, z);
	// rotate about horizontal or vertical axis
	CATransform3D transform = self.rotationDirection == FCHorizontal ? CATransform3DRotate(transformTranslated, rotationInRadians, 0, 1, 0) : CATransform3DRotate(transformTranslated, -rotationInRadians, 1, 0, 0);
	face.transform = transform;
}

//	we want to update all kinds of CALayer transforms whenever the rotation changes

- (void)setRotationInRadians:(float)rotationInRadians
{
	if (rotationInRadians > M_PI_2) rotationInRadians = M_PI_2;					// temporary
	_rotationInRadians = rotationInRadians;
	[self transformFace:self.flippingCubeLayerContainer.faceFront rotation:rotationInRadians];
#if 0
	float width = self.bounds.size.width/2.0;
	float height = self.bounds.size.height/2.0;
	float x = self.rotationDirection == FCHorizontal ? width*sinf(rotationInRadians) : 0;
	float y = self.rotationDirection == FCVertical ? height*sinf(rotationInRadians) : 0;
	float z = self.rotationDirection == FCHorizontal ? -(1.0 - sinf(rotationInRadians+M_PI_2))*height : -(1.0 - sinf(rotationInRadians+M_PI_2))*width;
	// translate in 3D to reflect rotation about cube center
	CATransform3D transformTranslated = CATransform3DTranslate(CATransform3DIdentity, x, y, z);
	// rotate about horizontal or vertical axis
	CATransform3D transform = self.rotationDirection == FCHorizontal ? CATransform3DRotate(transformTranslated, rotationInRadians, 0, 1, 0) : CATransform3DRotate(transformTranslated, -rotationInRadians, 1, 0, 0);
	self.flippingCubeLayerContainer.faceFront.transform = transform;
#endif
	// deal with the lagging view
	// difference from main face
	if (rotationInRadians > 0)
		rotationInRadians -= M_PI_2;
	else
		rotationInRadians += M_PI_2;
#if 1
	[self transformFace:self.flippingCubeLayerContainer.faceBottom rotation:rotationInRadians];
#else
	{
		float x = self.rotationDirection == FCHorizontal ? width*sinf(rotationInRadians) : 0;
		float y = self.rotationDirection == FCVertical ? height*sinf(rotationInRadians) : 0;
		float z = self.rotationDirection == FCHorizontal ? -(1.0 - sinf(rotationInRadians+M_PI_2))*height : -(1.0 - sinf(rotationInRadians+M_PI_2))*width;
		// translate in 3D to reflect rotation about cube center
		CATransform3D transformTranslated = CATransform3DTranslate(CATransform3DIdentity, x, y, z);
		// rotate about horizontal or vertical axis
		CATransform3D transform = self.rotationDirection == FCHorizontal ? CATransform3DRotate(transformTranslated, rotationInRadians, 0, 1, 0) : CATransform3DRotate(transformTranslated, -rotationInRadians, 1, 0, 0);
		self.flippingCubeLayerContainer.faceBottom.transform = transform;
	}
#if 0
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
	self.flippingCubeLayerContainer.faceBottom.contents = contents;
#endif
#endif
	if (fabsf(rotationInRadians) >= 0.001)
		self.flippingCubeLayerContainer.faceBottom.hidden = NO;
	else
		self.flippingCubeLayerContainer.faceBottom.hidden = YES;
}

- (float)rotationInRadians
{
	return _rotationInRadians;
}

@end
