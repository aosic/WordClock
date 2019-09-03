//
//  BSHWordClockView.h
//  WordClock
//
//  Created by aoxingkui on 2019/8/25.
//  Copyright © 2019 Aosic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSHWordItemLabel.h"

@protocol BSHWordDelegate <NSObject>

@end

@protocol BSHWordDataSource <NSObject>

@required
- (NSInteger)numberOfWordClockSections;

- (NSInteger)numberOfWordClockItemsIn:(NSInteger)section;

- (NSString *)wordClockTextSection:(NSInteger)section andIndex:(NSInteger)index;

- (__kindof UIView *)wordItemViewForIndex:(NSInteger)index section:(NSInteger)section;

- (void)getMonth:(NSInteger *)cmonth day:(NSInteger *)cday week:(NSInteger *)cweek hour:(NSInteger *)chour minute:(NSInteger *)cminute second:(NSInteger *)csecond monthDays:(NSInteger*)monthDays year:(NSInteger *)cyear formatString:(NSString **)formatString;

@end

@interface BSHWordClockView : UIView

@property (nonatomic, weak) id<BSHWordDelegate> delegate;
@property (nonatomic, weak) id<BSHWordDataSource> dataSource;

- (void)reloadData;

- (__kindof UIView *)dequeueReusableCell;

- (void)startClock;

// todo
- (void)todoWorkApi;

@end
