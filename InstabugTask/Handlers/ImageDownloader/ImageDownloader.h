//
//  ImageDownloader.h
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ImageDownloadCompletionBlock)(NSData* result);

@interface ImageDownloader : NSObject

+(instancetype)sharedInstance;

-(void)downloadImageWithUrl:(NSString*)url AndCompletionBlock:(ImageDownloadCompletionBlock)completionBlock;

-(void)cancelAllDownloads;

@end
