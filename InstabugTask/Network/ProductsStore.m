//
//  ProductsStore.m
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import "ProductsStore.h"
#import "Product.h"

@implementation ProductsStore

+(void)loadProductsWithCount:(int)count AndOffset:(int)offset AndSuccessBlock:(void(^)(NSArray <Product*> *resultData))successBlock AndFailureBlock:(void(^)(NSError* resultError))failureBlock{

    NSString* urlString = [NSString stringWithFormat:@"http://instabug.getsandbox.com/products?count=%d&from=%d",count,offset];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if(error == nil){
                
                NSError *parsingError = nil;
                
                NSArray* products = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parsingError];
            
                if(parsingError == nil){
                    
                    NSMutableArray* result = [NSMutableArray new];
                    
                    for (NSDictionary* product in products) {
                        
                        [result addObject:[[Product alloc] initWithJsonObject:product]];
                    }
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        successBlock([result copy]);
                    });
                }else{
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        failureBlock(parsingError);
                    });
                }
            }else{
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    failureBlock(error);
                });
            }
        }] resume];
    });
}

@end
