//
//  CircleTransition.h
//  InstabugTask
//
//  Created by Karim Mousa on 8/21/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    present,
    dismiss,
} TransitionMode;

@interface CustomTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic) TransitionMode transitionMode;

@property (nonatomic) CGPoint startingPoint;

@end
