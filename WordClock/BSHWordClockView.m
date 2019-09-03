//
//  BSHWordClockView.m
//  WordClock
//
//  Created by aoxingkui on 2019/8/25.
//  Copyright © 2019 Aosic. All rights reserved.
//

#import "BSHWordClockView.h"

@interface BSHWordClockView ()

@property (nonatomic, strong) NSMutableSet *reuseCells;
@property (nonatomic, strong) NSMutableDictionary *cachedCells;

@property (nonatomic, assign) BOOL needsReload;

@property (nonatomic, assign) CGRect lastRect;

@property (nonatomic, assign) NSInteger month;

@property (nonatomic, assign) NSInteger day;

@property (nonatomic, assign) NSInteger week;

@property (nonatomic, assign) NSInteger hour;

@property (nonatomic, assign) NSInteger minute;

@property (nonatomic, assign) NSInteger second;

@property (nonatomic, assign) NSInteger totalMonthDays;

@property (nonatomic) dispatch_source_t timer;

@property (nonatomic, strong) UILabel *yearLabel;

@property (nonatomic, assign) NSInteger year;

@end

@implementation BSHWordClockView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpInitData];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpInitData];
    }
    return self;
}

- (void)setUpInitData {
    _month = 1;
    _day = 1;
    _week = 0;
    _hour = 1;
    _minute = 1;
    _second = 1;
    _totalMonthDays = 31;
    _year = 2019;
}

- (void)reloadData {
    [[self.cachedCells allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.reuseCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.cachedCells removeAllObjects];
    [self.reuseCells removeAllObjects];
    [self.yearLabel removeFromSuperview];
    self.yearLabel = nil;
    self.needsReload = NO;
}

- (void)setDataSource:(id<BSHWordDataSource>)dataSource {
    _dataSource = dataSource;
    [self _setNeedsReload];
}

//由角度转换弧度
#define DegreesToRadian(x) (M_PI * (x) / 180.0)
//由弧度转换角度
#define RadianToDegrees(radian) (radian*180.0)/(M_PI)

- (void)startClock {
    if (!_timer) {
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_timer, ^{
            NSInteger cmonth = 0;
            NSInteger cday = 0;
            NSInteger cweek = 0;
            NSInteger chour = 0;
            NSInteger cminute = 0;
            NSInteger csecond = 0;
            NSInteger cmonthdays = 0;
            NSInteger cyear = 0;
            NSString *formatstr = nil;
            [self.dataSource getMonth:&cmonth day:&cday week:&cweek hour:&chour minute:&cminute second:&csecond monthDays:&cmonthdays year:&cyear formatString:&formatstr];
            self.totalMonthDays = cmonthdays;
            self.yearLabel.text = formatstr;
            if (csecond != self.second) {
                NSInteger section = 5;
                [self sectionAnimationAt:section value:csecond];
            }
            if (cminute != self.minute) {
                NSInteger section = 4;
                [self sectionAnimationAt:section value:cminute];
            }
            if (chour != self.hour) {
                NSInteger section = 3;
                [self sectionAnimationAt:section value:chour];
            }
            if (cweek != self.week) {
                NSInteger section = 2;
                [self sectionAnimationAt:section value:cweek];
            }
            if (cday != self.day) {
                NSInteger section = 1;
                [self sectionAnimationAt:section value:cday];
            }
            if (cmonth != self.month) {
                NSInteger section = 0;
                [self sectionAnimationAt:section value:cmonth];
            }
        });
        dispatch_resume(_timer);
    }
}

-(void) pauseTimer{
    if(_timer){
        dispatch_suspend(_timer);
    }
}
-(void) resumeTimer{
    if(_timer){
        dispatch_resume(_timer);
    }
}
-(void) stopTimer{
    if(_timer){
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)sectionAnimationAt:(NSInteger)section value:(NSInteger)value {
    switch (section) {
        case 0:
            self.month = value;
            break;
        case 1:
            self.day = value;
            break;
        case 2:
            self.week = value;
            break;
        case 3:
            self.hour = value;
            break;
        case 4:
            self.minute = value;
            break;
        case 5:
            self.second = value;
            break;
        default:
            break;
    }
    NSInteger totalRows = [self.dataSource numberOfWordClockItemsIn:section];
    [UIView animateWithDuration:0.6f delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
        for (int i = 0; i < totalRows; i++) {
            BSHWordItemLabel *v = [self.cachedCells objectForKey:[NSIndexPath indexPathForRow:i inSection:section]];
            v.wordAttribute.circleTransform = CGAffineTransformIdentity;
            v.wordAttribute.circleTransform = CGAffineTransformMakeRotation(DegreesToRadian((360 * i / totalRows)) - DegreesToRadian((value - 1) * 360 / totalRows));
            v.transform = v.wordAttribute.circleTransform;
            if (i == value - 1) {
                v.textColor = v.wordAttribute.selectedColor;
            } else {
                v.textColor = v.wordAttribute.normalColor;
            }
            if ((section == 4 || section == 5) && value == 0 && i == 59) {
                v.textColor = v.wordAttribute.selectedColor;
            }
            if (section == 1) {
                if (i >= self.totalMonthDays) {
                    v.textColor = v.wordAttribute.disableColor;
                }
            }
        }
    } completion:nil];

}

- (void)_setNeedsReload {
    self.needsReload = YES;
    [self setNeedsLayout];
}

- (void)_reloadDataIfNeeded {
    if (_needsReload) {
        [self reloadData];
    }
}

- (void)layoutSubviews {
    [self _reloadDataIfNeeded];
    [self _layoutWordItems];
    [super layoutSubviews];
}

- (void)_layoutWordItems {
    if (CGRectEqualToRect(CGRectZero, self.bounds)) {
        return;
    }
    if (self.cachedCells.count > 0) {
        return;
    }
    NSInteger sections = [self.dataSource numberOfWordClockSections];
    for (int i = 0; i < sections; i++) {
        NSInteger rows = [self.dataSource numberOfWordClockItemsIn:i];
        for (int j = 0; j < rows; j++) {
            UIView *rowView = [self.dataSource wordItemViewForIndex:j section:i];
            [self addSubview:rowView];
            rowView.layer.anchorPoint = CGPointMake(0, 0.5);
            
            if ([rowView isKindOfClass:[BSHWordItemLabel class]]) {
                
                BSHWordItemLabel *label = ((BSHWordItemLabel *)rowView);
                NSString *wordText = [self.dataSource wordClockTextSection:i andIndex:j];
                label.text = wordText;
                
                BSHWordClockLayoutAttribute *att = [self needAttribute:sections nowSection:i index:j totalRows:rows wordText:wordText];
                label.wordAttribute  = att;
                label.frame = att.circleRect;
                label.transform = att.circleTransform;
                
            }
            [self.cachedCells setObject:rowView forKey:[NSIndexPath indexPathForRow:j inSection:i]];
        }
    }
    self.yearLabel = [[UILabel alloc] init];
    [self addSubview:self.yearLabel];
    self.yearLabel.numberOfLines = 0;
    self.yearLabel.textAlignment = NSTextAlignmentCenter;
    self.yearLabel.font = [UIFont systemFontOfSize:14];
    self.yearLabel.textColor = [UIColor whiteColor];
    self.yearLabel.frame = CGRectMake(0, 0, 100, 50);
    CGFloat midx = CGRectGetMidX(self.bounds);
    CGFloat midy = CGRectGetMidY(self.bounds);
    self.yearLabel.center = CGPointMake(midx, midy);
}

- (BSHWordClockLayoutAttribute *)needAttribute:(NSInteger)totalSections nowSection:(NSInteger)nowSection index:(NSInteger)index totalRows:(NSInteger)totalRows wordText:(NSString *)wordText {
    if (nowSection == 0 && index == 0) {
        self.lastRect = CGRectZero;
    }
    BSHWordClockLayoutAttribute *att = [[BSHWordClockLayoutAttribute alloc] init];
    CGFloat midx = CGRectGetMidX(self.bounds);
    CGFloat midy = CGRectGetMidY(self.bounds) - 10;
    CGFloat supWdith = CGRectGetWidth(self.bounds) - 10;
    CGFloat width = (CGFloat)(nowSection + 1) / (CGFloat)totalSections * supWdith / 2.0;
    if (nowSection == 0 || nowSection == 1) {
        width += (CGFloat)(1) / (CGFloat)totalSections * supWdith / 2.0 / 2.0;
    }
    
    UIFont *font = [UIFont systemFontOfSize:8];
    CGSize size = [wordText boundingRectWithSize:CGSizeMake(100.0f, 20.0f) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: font} context:nil].size;
    
    CGFloat flowx = self.lastRect.origin.x;
    CGFloat flowy = self.lastRect.origin.y;
    if (self.lastRect.origin.x + self.lastRect.size.width + size.width < self.bounds.size.width) {
        flowx = flowx + self.lastRect.size.width;
    } else {
        flowx = 0;
        flowy = flowy + 20;
    }
    att.flowRect = CGRectMake(flowx, flowy, size.width, 20);
    self.lastRect = att.flowRect;
    
    att.flowTransform = CGAffineTransformIdentity;
    att.circleRect = CGRectMake(midx, midy, width, 20);
    att.circleTransform = CGAffineTransformMakeRotation(DegreesToRadian((360 * index / totalRows)));
    return att;
}

- (UIView *)dequeueReusableCell {
    return [self.reuseCells anyObject];
}

- (NSMutableDictionary *)cachedCells {
    if (!_cachedCells) {
        _cachedCells = [[NSMutableDictionary alloc] init];
    }
    return _cachedCells;
}

// TODO: 流样 & 球形布局切换
- (void)changeLayoutAt:(NSInteger)section flowOrCircle:(BOOL)flowOrCircle totalSections:(NSInteger)totalSections duration:(NSTimeInterval)duration {
    if (section >= totalSections) {
        return;
    }
    [UIView animateWithDuration:duration animations:^{
        for (int i = 0; i < [self.dataSource numberOfWordClockItemsIn:section]; i++) {
            BSHWordItemLabel *v = [self.cachedCells objectForKey:[NSIndexPath indexPathForRow:i inSection:section]];
            v.transform = CGAffineTransformIdentity;
            if (flowOrCircle) {
                v.frame = v.wordAttribute.circleRect;
                v.transform = v.wordAttribute.circleTransform;
            } else {
                v.frame = v.wordAttribute.flowRect;
                v.transform = v.wordAttribute.flowTransform;
            }
        }
    } completion:^(BOOL finished) {
        [self changeLayoutAt:section + 1 flowOrCircle:flowOrCircle totalSections:totalSections duration:duration];
    }];
}

- (void)changeLayoutSection:(NSInteger)section index:(NSInteger)index flowOrCircle:(BOOL)flowOrCircle totalsections:(NSInteger)totalSections duration:(NSTimeInterval)duration {
    if (section >= totalSections) { return; }
    NSInteger rows = [self.dataSource numberOfWordClockItemsIn:section];
    if (index >= rows) {
        [self changeLayoutSection:section + 1 index:0 flowOrCircle:flowOrCircle totalsections:totalSections duration:duration];
    } else {
        [UIView animateWithDuration:duration animations:^{
            BSHWordItemLabel *v = [self.cachedCells objectForKey:[NSIndexPath indexPathForRow:index inSection:section]];
            v.transform = CGAffineTransformIdentity;
            if (flowOrCircle) {
                v.frame = v.wordAttribute.circleRect;
                v.transform = v.wordAttribute.circleTransform;
            } else {
                v.frame = v.wordAttribute.flowRect;
                v.transform = v.wordAttribute.flowTransform;
            }
        } completion:^(BOOL finished) {
            [self changeLayoutSection:section index:index + 1 flowOrCircle:flowOrCircle totalsections:totalSections duration:duration];
        }];
    }
}

- (void)todoWorkApi {
    NSInteger beginSection = 0;
    NSInteger beginIndex = 0;
    NSInteger sections = [self.dataSource numberOfWordClockSections];
    static BOOL yesornot = YES;
    yesornot = !yesornot;
    //    NSTimeInterval duration = 0.35f;
    //    [self changeLayoutAt:beginIndex flowOrCircle:yesornot totalSections:sections duration:duration];
    NSTimeInterval duration = 0.1f;
    [self changeLayoutSection:beginSection index:beginIndex flowOrCircle:yesornot totalsections:sections duration:duration];
}

@end
