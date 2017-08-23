//
//  Product.m
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import "Product.h"

#import "CommonUtils.h"

#import "CachingHandler.h"
#import "ImageDownloader.h"

@interface Product()

@property (nonatomic) BOOL downloading;

@end

@implementation Product

-(UIImage *)image{
    
    return [[CachingHandler sharedInstance] imageFromPath:[self imagePath]];;
}

-(void)loadImageWithCompletionHandler:(void(^)())completionHandler{

    if([self image] == nil && _downloading == false){
        
        _downloading = true;
        
        __weak typeof(self) weakSelf = self;
        
        [[ImageDownloader sharedInstance] downloadImageWithUrl:self.imageData.url AndCompletionBlock:^(NSData *result) {
            
            weakSelf.downloading = false;
            
            if(result != nil){
                
                UIImage* image = [UIImage imageWithData:result];
                
                [[CachingHandler sharedInstance] saveImage:image ToPath:[weakSelf imagePath]];
                
                completionHandler();
            }
        }];
    }
}

-(NSString*)priceString{
    
    return [NSString stringWithFormat:@"%d$",self.price];
}

#pragma mark - private

-(NSString*)imagePath{
    
    NSURL* url = [NSURL URLWithString:_imageData.url];
    
    return [[CommonUtils documentsPath] stringByAppendingFormat:@"%@/%@.png",IMAGES_FOLDER_NAME,[url.relativePath stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
}

#pragma mark - initialize

-(instancetype)initWithJsonObject:(NSDictionary*)dict{
    
    self = [super init];
    
    if(self){
        
        _downloading = false;
        
        _identifier = [dict[@"id"] intValue];
        
        _price = [dict[@"price"] intValue];
        
        _desc = dict[@"productDescription"];
        
        _imageData = [[ProductImage alloc] initWithJsonObject:dict[@"image"]];
    }
    
    return self;
}

-(instancetype)initWithCachedObject:(NSDictionary*)dict{
    
    self = [super init];
    
    if(self){
        
        _downloading = false;
        
        _price = [dict[@"price"] intValue];
        
        _desc = dict[@"desc"];
        
        _imageData = [[ProductImage alloc] init];
        
        _imageData.width = [dict[@"imageWidth"] intValue];
        
        _imageData.height = [dict[@"imageHeight"] intValue];
        
        _imageData.url = dict[@"imageUrl"];
    }
    
    return self;
}

@end
