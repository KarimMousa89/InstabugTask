//
//  CircleTransition.m
//  InstabugTask
//
//  Created by Karim Mousa on 8/21/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import "CustomTransition.h"

@interface CustomTransition(){
    
    CGFloat duration;
}

@property (nonatomic) CGFloat transformValue;

@end

@implementation CustomTransition

-(void)setStartingPoint:(CGPoint)startingPoint{

    _startingPoint = startingPoint;
}

-(instancetype)init{
    
    self = [super init];
    
    if(self){
        
        _transitionMode = present;
        
        _startingPoint = CGPointZero;
        
        _transformValue = 0.01;
        
        duration = 0.4;
    }
    
    return self;
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    return duration;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIView* containerView = transitionContext.containerView;
    
    if(_transitionMode == present){
        
        UIView* presentedView = [transitionContext viewForKey:UITransitionContextToViewKey];
        
        if(presentedView) {
            
            CGPoint viewCenter = presentedView.center;
            
            presentedView.center = _startingPoint;
            presentedView.transform = CGAffineTransformMakeScale(_transformValue, _transformValue);
            presentedView.alpha = 0;
            [containerView addSubview:presentedView];
            
            [UIView animateWithDuration:duration animations:^{
                
                presentedView.transform = CGAffineTransformIdentity;
                
                presentedView.center = viewCenter;
                
                presentedView.alpha = 1;
            } completion:^(BOOL finished) {
                
                [transitionContext completeTransition:finished];
            }];
        }
    }else{
        
        UIView* returningView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        
        if (returningView) {
            
            CGPoint viewCenter = returningView.center;
            
            __weak typeof(self) weakSelf = self;
            
            [UIView animateWithDuration:duration animations:^{
                
                returningView.transform = CGAffineTransformMakeScale(weakSelf.transformValue, weakSelf.transformValue);
                
                returningView.center = weakSelf.startingPoint;
                
                returningView.alpha = 0;
            } completion:^(BOOL finished) {
                
                returningView.center = viewCenter;
                
                [returningView removeFromSuperview];
                
                [transitionContext completeTransition:finished];
            }];
        }
    }
}

@end
