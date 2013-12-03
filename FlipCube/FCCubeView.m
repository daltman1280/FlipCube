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
	layer.borderWidth = 1;
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
//		self.flippingCubeLayerContainer.faceTop.hidden = NO;
		self.flippingCubeLayerContainer.faceBottom = [self addFace:@"chart4.png"];
//		self.flippingCubeLayerContainer.faceBottom.hidden = NO;
		self.flippingCubeLayerContainer.faceRight = [self addFace:@"chart5.png"];
		self.flippingCubeLayerContainer.faceLeft = [self addFace:@"chart6.png"];
		// perspective transform for container
		CATransform3D transform = CATransform3DIdentity;
		transform.m34 = -1.0/1000.0;
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
	float x = self.rotationDirection == FCHorizontal ? width*sinf(rotationInRadians) : 0;
	float y = self.rotationDirection == FCVertical ? height*sinf(rotationInRadians) : 0;
	float z = self.rotationDirection == FCHorizontal ? -(1.0 - sinf(rotationInRadians+M_PI_2))*width : -(1.0 - sinf(rotationInRadians+M_PI_2))*height;
	// translate in 3D to reflect rotation about cube center
	CATransform3D transformTranslated = CATransform3DTranslate(CATransform3DIdentity, x, y, z);
	// rotate about horizontal or vertical axis
	CATransform3D transform = self.rotationDirection == FCHorizontal ? CATransform3DRotate(transformTranslated, rotationInRadians, 0, 1, 0) : CATransform3DRotate(transformTranslated, -rotationInRadians, 1, 0, 0);
	face.transform = transform;
}

//	we want to update all kinds of CALayer transforms whenever the rotation changes

- (void)setRotationInRadians:(float)rotationInRadians
{
//	NSLog(@"rotation = %f", rotationInRadians);
	static float magic = 0.14;
	if (rotationInRadians > +M_PI_2) rotationInRadians = +M_PI_2;					// temporary
	if (rotationInRadians < -M_PI_2) rotationInRadians = -M_PI_2;					// temporary
	_rotationInRadians = rotationInRadians;
	[self transformFace:self.flippingCubeLayerContainer.faceFront rotation:rotationInRadians];
	if (self.rotationDirection == FCVertical) {
		if (rotationInRadians > +magic) [self transformFace:self.flippingCubeLayerContainer.faceTop rotation:rotationInRadians-M_PI_2];
		if (rotationInRadians < -magic) [self transformFace:self.flippingCubeLayerContainer.faceBottom rotation:rotationInRadians+M_PI_2];
		self.flippingCubeLayerContainer.faceLeft.hidden =	YES;
		self.flippingCubeLayerContainer.faceRight.hidden =	YES;
		self.flippingCubeLayerContainer.faceTop.hidden =	rotationInRadians > +magic ? NO : YES;
		self.flippingCubeLayerContainer.faceBottom.hidden = rotationInRadians < -magic ? NO : YES;
	} else {
		if (rotationInRadians > +magic) [self transformFace:self.flippingCubeLayerContainer.faceLeft rotation:rotationInRadians-M_PI_2];
		if (rotationInRadians < -magic) [self transformFace:self.flippingCubeLayerContainer.faceRight rotation:rotationInRadians+M_PI_2];
		self.flippingCubeLayerContainer.faceLeft.hidden =	rotationInRadians > +magic ? NO : YES;
		self.flippingCubeLayerContainer.faceRight.hidden =	rotationInRadians < -magic ? NO : YES;
		self.flippingCubeLayerContainer.faceTop.hidden =	YES;
		self.flippingCubeLayerContainer.faceBottom.hidden =	YES;
	}
}

- (float)rotationInRadians
{
	return _rotationInRadians;
}

- (void)drawRect:(CGRect)rect
{
	
}

@end
