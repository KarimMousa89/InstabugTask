//
//  ProductDetailsViewController.m
//  InstabugTask
//
//  Created by Karim Mousa on 8/20/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import "ProductDetailsViewController.h"

#import "Product.h"

@interface ProductDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productImageViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ProductDetailsViewController

-(void)viewDidLoad{

    [super viewDidLoad];
    
    self.titleLabel.text = @"Product Details";
}

-(void)viewDidLayoutSubviews{

    [super viewDidLayoutSubviews];

    [self buildWithProduct:_product];
}

-(void)buildWithProduct:(Product*)product{

    _priceLabel.text = [product priceString];
    
    _descLabel.text = product.desc;
    
    [_productImageView setImage:[product image]];
    
    CGFloat requiredWidth = _productImageView.bounds.size.width;
    
    CGFloat requiredHeight = requiredWidth*product.imageData.height/(product.imageData.width);
    
    _productImageViewHeightConstraint.constant = requiredHeight;
}

- (IBAction)close:(id)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
