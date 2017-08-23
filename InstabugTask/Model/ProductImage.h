//
//  ProductImage.h
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductImage : NSObject

@property (nonatomic) int width;

@property (nonatomic) int height;

@property (nonatomic,strong) NSString* url;

-(instancetype)initWithJsonObject:(NSDictionary*)dict;

@end
