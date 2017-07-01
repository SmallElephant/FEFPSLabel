//
//  FEFPSIndicator.h
//  FEFPSLabel
//
//  Created by keso on 2017/7/1.
//  Copyright © 2017年 FlyElephant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FEFPSIndicator : NSObject

+ (instancetype)sharedInstance;

- (void)start;

- (void)stop;

@end
