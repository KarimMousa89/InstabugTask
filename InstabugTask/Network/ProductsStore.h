//
//  ProductsStore.h
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Product;

@interface ProductsStore : NSObject

+(void)loadProductsWithCount:(int)count AndOffset:(int)offset AndSuccessBlock:(void(^)(NSArray <Product*> *resultData))successBlock AndFailureBlock:(void(^)(NSError* resultError))failureBlock;

@end
