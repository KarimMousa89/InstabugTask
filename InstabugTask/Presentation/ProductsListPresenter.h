//
//  ProductsListPresenter.h
//  InstabugTask
//
//  Created by Karim Mousa on 8/21/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Product;

@protocol ProductsListPresenterViewDelegate

-(void)reset;

-(void)handleServiceEnd;

-(void)handleServiceStart;

-(void)addProducts:(NSArray<Product*>*)products;

-(void)handleServiceFailureWithMsg:(NSString*)msg;

-(void)reloadProductAtIndex:(NSIndexPath*)index;

@end

@interface ProductsListPresenter : NSObject

-(void)loadMoreProducts;

-(void)load;

-(void)setView:(id<ProductsListPresenterViewDelegate>)view;

-(void)downloadImageForProduct:(Product*)product AtIndex:(NSIndexPath*)index;

@end
