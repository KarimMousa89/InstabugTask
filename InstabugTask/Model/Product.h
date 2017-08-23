//
//  Product.h
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "ProductImage.h"

@interface Product : NSObject

@property (nonatomic) int identifier;

@property (nonatomic) int price;

@property (nonatomic,strong) NSString *desc;

@property (nonatomic,strong) ProductImage *imageData;

-(instancetype)initWithJsonObject:(NSDictionary*)dict;

-(instancetype)initWithCachedObject:(NSDictionary*)dict;

-(void)loadImageWithCompletionHandler:(void(^)())completionHandler;

-(UIImage*)image;

-(NSString*)priceString;

@end
