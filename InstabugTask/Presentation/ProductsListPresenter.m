//
//  ProductsListPresenter.m
//  InstabugTask
//
//  Created by Karim Mousa on 8/21/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import "ProductsListPresenter.h"

#import "Reachability.h"
#import "ProductsStore.h"
#import "CachingHandler.h"
#import "ImageDownloader.h"

#import "Product.h"

#import "ProductsListViewController.h"

#define PATCH_COUNT (([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 20 : 10)

@interface ProductsListPresenter(){
    
    Reachability* reachability;
    
    NetworkStatus lastReachabilityState;
}

@property (nonatomic) BOOL cachedDataLoaded;

@property (nonatomic) int lastProductId;

@property (nonatomic) id<ProductsListPresenterViewDelegate> view;

@end

@implementation ProductsListPresenter

-(instancetype)init{
    
    self = [super init];
    
    if(self){
        
        _cachedDataLoaded = false;
        
        _lastProductId = 0;
        
        reachability = [Reachability reachabilityForInternetConnection];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        [reachability startNotifier];
        
        lastReachabilityState = NotReachable;
    }
    
    return self;
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setView:(id<ProductsListPresenterViewDelegate>)view{
    
    _view = view;
}

-(void)downloadImageForProduct:(Product*)product AtIndex:(NSIndexPath*)index{
    
    __weak typeof(self) weakSelf = self;
    
    [product loadImageWithCompletionHandler:^{
        
        [weakSelf.view reloadProductAtIndex:index];
    }];
}

-(void)load{
    
    [self handleReachabilityChanged:reachability];
}

#pragma mark - actions

- (void) reachabilityChanged:(NSNotification *)note{
    
    Reachability* curReach = [note object];
    
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    
    [self handleReachabilityChanged:curReach];
}

#pragma mark - private

-(void)handleReachabilityChanged:(Reachability*)curReach{
    
    if(curReach.currentReachabilityStatus != NotReachable){
        
        if(lastReachabilityState == NotReachable){
        
            if(_lastProductId == 0){
                
                [self loadMoreProducts];
            }else{
                
                [self.view addProducts:nil];
            }
        }
    }else{
        
        [[ImageDownloader sharedInstance] cancelAllDownloads];
        
        if(_lastProductId == 0 && _cachedDataLoaded == false){
            
            [self loadCachedData];
            
            if(_cachedDataLoaded == false){
                
                [_view handleServiceFailureWithMsg:@"The Internet connection appears to be offline."];
            }
        }
    }
    
    lastReachabilityState = curReach.currentReachabilityStatus;
}

-(void)loadMoreProducts{
    
    [_view handleServiceStart];
    
    int offset = (_lastProductId == 0) ? 0 : (_lastProductId + 1);
    
    __weak typeof(self) weakSelf = self;
    
    [ProductsStore loadProductsWithCount:PATCH_COUNT AndOffset:offset AndSuccessBlock:^(NSArray<Product *> *result) {
        
        [weakSelf.view handleServiceEnd];
        
        if(weakSelf.lastProductId == 0){
            
            [[CachingHandler sharedInstance] clear];
            
            [weakSelf.view reset];
        }
        
        if(result.count != 0){
            
            [[CachingHandler sharedInstance] addProducts:result];
            
            [weakSelf.view addProducts:result];
            
            weakSelf.lastProductId = result.lastObject.identifier;
            
        }else if(weakSelf.lastProductId == 0){
            
            [weakSelf.view handleServiceFailureWithMsg:@"No Data Found"];
        }
    } AndFailureBlock:^(NSError *error) {
        
        [weakSelf.view handleServiceEnd];
        
        if(!(weakSelf.cachedDataLoaded == true || weakSelf.lastProductId != 0)){
            
            [weakSelf.view handleServiceFailureWithMsg:error.localizedDescription];
        }
    }];
}

-(void)loadCachedData{
    
    NSArray* cachedProducts = [[CachingHandler sharedInstance] getAllProducts];
    
    _cachedDataLoaded = (cachedProducts.count > 0);
    
    if(_cachedDataLoaded){
        
        [_view addProducts:cachedProducts];
    }
}

@end
