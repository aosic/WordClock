//
//  BSHWordClockLayoutAttribute.h
//  WordClock
//
//  Created by aoxingkui on 2019/8/26.
//  Copyright © 2019 Aosic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSHWordClockLayoutAttribute : NSObject

@property (nonatomic, assign) CGRect flowRect;
@property (nonatomic, assign) CGRect circleRect;
@property (nonatomic, assign) CGAffineTransform flowTransform;
@property (nonatomic, assign) CGAffineTransform circleTransform;

@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *disableColor;

@end
