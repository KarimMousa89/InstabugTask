//
//  ImageDownloader.m
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import "ImageDownloader.h"
#import "AppDelegate.h"

@interface ImageDownloader()<NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate>

@property (nonatomic,strong) NSMutableDictionary* currentDownloads;

@property (nonatomic,strong) NSURLSession* sharedSession;

@end

@implementation ImageDownloader

-(void)cancelAllDownloads{

    NSArray* allKeys = [_currentDownloads allKeys];
    
    for (NSString* key in allKeys) {
        
        NSArray* blocks = _currentDownloads[key];
        
        for (ImageDownloadCompletionBlock block in blocks) {
            
            block(nil);
        }
    }
    
    [_currentDownloads removeAllObjects];
}

-(void)downloadImageWithUrl:(NSString*)url AndCompletionBlock:(ImageDownloadCompletionBlock)completionBlock{
    
    NSMutableArray* currentUrlSuccessBlocks = _currentDownloads[url];
    
    if(currentUrlSuccessBlocks != nil){
        
        [currentUrlSuccessBlocks addObject:completionBlock];
    }else{
        
        currentUrlSuccessBlocks = [NSMutableArray new];
        
        [currentUrlSuccessBlocks addObject:completionBlock];
        
        [_currentDownloads setValue:currentUrlSuccessBlocks forKey:url];
        
        [self downloadImageWithUrlSting:url];
    }
}

#pragma mark - NSURLSessionTaskDelegate

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    NSData* data = [NSData dataWithContentsOfURL:location];
    
    [[NSFileManager defaultManager] removeItemAtPath:location.absoluteString error:nil];
    
    NSString* absoluteString = downloadTask.response.URL.absoluteString;
    
    NSString* key = [absoluteString substringToIndex:absoluteString.length - 1];
    
    [self fireBlockOfURL:key WithData:data];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    NSString* absoluteString = task.response.URL.absoluteString;
    
    NSString* key = [absoluteString substringToIndex:absoluteString.length - 1];
    
    if(key != nil){
        
        [self.currentDownloads removeObjectForKey:key];
    }
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [_sharedSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        
        if(downloadTasks.count == 0){
            
            if (appDelegate.backgroundTransferCompletionHandler != nil) {
                
                void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;
                
                appDelegate.backgroundTransferCompletionHandler = nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    completionHandler();
                });
            }
        }
    }];
}

#pragma mark - private

-(void)downloadImageWithUrlSting:(NSString*)urlStirng{
    
    NSURL *url = [NSURL URLWithString:urlStirng];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[weakSelf.sharedSession downloadTaskWithURL:url]resume];
    });
}

-(void)fireBlockOfURL:(NSString*)url WithData:(NSData*)data{
    
    NSMutableArray* currentUrlSuccessBlocks = self.currentDownloads[url];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (ImageDownloadCompletionBlock block in currentUrlSuccessBlocks) {
            
            block(data);
        }
    });
}

#pragma mark - initialization

-(void)initialize{
    
    _currentDownloads = [NSMutableDictionary new];
    
    _sharedSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
}

#pragma mark - singlton implementation

+ (instancetype)sharedInstance{
    
    static ImageDownloader *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[super allocWithZone:NULL]init];
        
        [sharedInstance initialize];
    });
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone {
    
    return self;
}

@end
