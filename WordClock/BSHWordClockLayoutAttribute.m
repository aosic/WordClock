//
//  BSHWordClockLayoutAttribute.m
//  WordClock
//
//  Created by aoxingkui on 2019/8/26.
//  Copyright © 2019 Aosic. All rights reserved.
//

#import "BSHWordClockLayoutAttribute.h"

@implementation BSHWordClockLayoutAttribute

- (UIColor *)normalColor {
    if (!_normalColor) {
        _normalColor = [UIColor grayColor];
    }
    return _normalColor;
}

- (UIColor *)selectedColor {
    if (!_selectedColor) {
        _selectedColor = [UIColor whiteColor];
    }
    return _selectedColor;
}

- (UIColor *)disableColor {
    if (!_disableColor) {
        _disableColor = [UIColor blackColor];
    }
    return _disableColor;
}

@end
