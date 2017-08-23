//
//  ProductImage.m
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import "ProductImage.h"

@implementation ProductImage

-(instancetype)initWithJsonObject:(NSDictionary*)dict{
    
    self = [super init];
    
    if(self){
        
        _width = [dict[@"width"] intValue];
        
        _height = [dict[@"height"] intValue];
        
        _url = dict[@"url"];
    }
    
    return self;
}

@end
