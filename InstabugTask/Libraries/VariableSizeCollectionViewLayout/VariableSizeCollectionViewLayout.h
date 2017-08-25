//
//  VariableSizeCollectionViewLayout.h
//  InstabugTask
//
//  Created by Karim Mousa on 8/20/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VariableSizeCollectionViewLayoutDelegate <NSObject>

-(CGFloat)HeightForItemAtIndexPath:(NSIndexPath*)indexPath WithWidth:(CGFloat)width;

@end

@interface VariableSizeCollectionViewLayout : UICollectionViewLayout

@property (nonatomic,weak) id<VariableSizeCollectionViewLayoutDelegate> delegate;

-(void)reset;

@end
