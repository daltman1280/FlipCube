//
//  FCViewController.h
//  FlipCube
//
//  Created by daltman on 11/29/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCCubeView.h"

@interface FCViewController : UIViewController
@property (weak, nonatomic) IBOutlet FCCubeView *CubeView;
@property CGPoint		initialPoint;
@end
