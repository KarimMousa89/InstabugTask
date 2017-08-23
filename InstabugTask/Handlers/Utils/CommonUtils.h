//
//  CommonUtils.h
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommonUtils : NSObject

+(void)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

+(NSString*)documentsPath;

+(void)saveImage:(UIImage*)image ToPath:(NSString*)path;

+(UIImage*)imageFromPath:(NSString*)path;

+(BOOL)deletePath:(NSString*)path;

+(BOOL)createFolderIFNeededAtPath:(NSString*)path;

+(BOOL)copyFileIFNeededFromPath:(NSString*)sourcePath ToPath:(NSString*)destinationPath;

@end
