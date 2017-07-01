//
//  FEFPSIndicator.m
//  FEFPSLabel
//
//  Created by keso on 2017/7/1.
//  Copyright © 2017年 FlyElephant. All rights reserved.
//

#import "FEFPSIndicator.h"
#import <UIKit/UIKit.h>


@interface FEFPSIndicator() {
    NSUInteger count;
    NSTimeInterval lastTime;
}

@property (strong, nonatomic) CADisplayLink *displayLink;

@property (strong, nonatomic) UILabel *fpsLabel;

@end

@implementation FEFPSIndicator

#pragma mark - LifeCycle

+ (instancetype)sharedInstance {
    static FEFPSIndicator *fpsIndicator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fpsIndicator = [[FEFPSIndicator alloc] init];
    });
    return fpsIndicator;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        self.fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 60, 30)];
        self.fpsLabel.font = [UIFont boldSystemFontOfSize:12];
        self.fpsLabel.textColor = [UIColor colorWithRed:0.33 green:0.84 blue:0.43 alpha:1.00];
        self.fpsLabel.backgroundColor = [UIColor grayColor];
        self.fpsLabel.tag = 25;
        self.fpsLabel.textAlignment = NSTextAlignmentCenter;
        self.fpsLabel.text = [NSString stringWithFormat:@"0 fps"];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self.fpsLabel addGestureRecognizer:panGesture];
        
        self.fpsLabel.userInteractionEnabled = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationDidBecomeActiveNotification:)
                                                     name: UIApplicationDidBecomeActiveNotification
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationWillResignActiveNotification:)
                                                     name: UIApplicationWillResignActiveNotification
                                                   object: nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - Public

- (void)start {
    self.displayLink.paused = NO;
    
    NSArray *rootVCViewSubViews = [[UIApplication sharedApplication].delegate window].rootViewController.view.subviews;
    for (UIView *label in rootVCViewSubViews) {
        if ([label isKindOfClass:[UILabel class]] && label.tag == 25) {
            [label removeFromSuperview];
            return;
        }
    }
    
    [[UIApplication sharedApplication].delegate.window addSubview:self.fpsLabel];
    [[UIApplication sharedApplication].delegate.window bringSubviewToFront:self.fpsLabel];
}

- (void)stop {
    self.displayLink.paused = YES;
    NSArray *rootVCViewSubViews = [[UIApplication sharedApplication].delegate window].rootViewController.view.subviews;
    for (UIView *label in rootVCViewSubViews) {
        if ([label isKindOfClass:[UILabel class]]&& label.tag == 25) {
            [label removeFromSuperview];
            return;
        }
    }
}

#pragma mark - NSNotification

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    self.displayLink.paused = NO;
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification {
    self.displayLink.paused = YES;
}


#pragma mark - Private 

- (void)displayLinkAction:(CADisplayLink *)link {
    
    if (lastTime == 0) {
        lastTime = link.timestamp;
        return;
    }
    
    count += 1;
    
    NSTimeInterval delta = link.timestamp - lastTime;
    if (delta < 1) {
        return;
    }
    
    CGFloat fps = count / delta;
    count = 0;
    lastTime = link.timestamp;
 
    self.fpsLabel.text = [NSString stringWithFormat:@"%d fps",(int)(round(fps))];

}

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    UIWindow *superView = [UIApplication sharedApplication].delegate.window;
    CGPoint position = [gesture locationInView:superView];
    if(gesture.state == UIGestureRecognizerStateBegan){
        
    }else if(gesture.state == UIGestureRecognizerStateChanged){
        _fpsLabel.center = position;
    }else if(gesture.state == UIGestureRecognizerStateEnded){
        
        CGRect frame = CGRectMake(MIN(superView.frame.size.width-_fpsLabel.frame.size.width, MAX(0, _fpsLabel.frame.origin.x)),
                                     MIN(superView.frame.size.height-_fpsLabel.frame.size.height, MAX(0, _fpsLabel.frame.origin.y)),
                                     _fpsLabel.frame.size.width,
                                     _fpsLabel.frame.size.height);

        [UIView animateWithDuration:0.25 animations:^{
            _fpsLabel.frame = frame;
        }];
    }
}

@end
