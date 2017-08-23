//
//  ProductCollectionViewCell.h
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import <UIKit/UIKit.h>

#define priceFont ([UIFont boldSystemFontOfSize:17])
#define descFont ([UIFont systemFontOfSize:15])
#define extraVerticalPadding 32
#define LabelsHorizontalPadding 16

@interface ProductCollectionViewCell : UICollectionViewCell

-(void)setPrice:(NSString*)price;

-(void)setDesc:(NSString*)desc;

-(void)setImage:(UIImage*)image;

@end
