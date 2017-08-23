//
//  ProductCollectionViewCell.m
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import "ProductCollectionViewCell.h"

@interface ProductCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *productImgView;

@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation ProductCollectionViewCell

-(void)setPrice:(NSString *)price{
    
    _productPriceLabel.text = price;
}

-(void)setDesc:(NSString *)desc{
    
    _productDescriptionLabel.text = desc;
}

-(void)setImage:(UIImage *)image{

    _productImgView.image = image;
}

-(void)awakeFromNib{

    [super awakeFromNib];
    
    _containerView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    
    _containerView.layer.borderWidth = 1;
}

@end
