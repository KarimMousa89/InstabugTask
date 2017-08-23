//
//  CachingHandler.h
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Product;

#define IMAGES_FOLDER_NAME @"/images"

@interface CachingHandler : NSObject

+(instancetype)sharedInstance;

-(void)clear;

-(void)addProducts:(NSArray<Product *>*)products;

-(NSArray<Product *>*)getAllProducts;

-(void)saveImage:(UIImage*)image ToPath:(NSString*)path;

-(UIImage*)imageFromPath:(NSString*)path;

@end
