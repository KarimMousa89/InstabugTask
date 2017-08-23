//
//  CommonUtils.m
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import "CommonUtils.h"

@implementation CommonUtils

#pragma mark - file managment

+(void)addSkipBackupAttributeToItemAtURL:(NSURL *)URL{
    
    if([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]){
        
        NSError *error = nil;
        
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        
        if(!success){
            
            NSLog(@"***Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
    }
}

+(BOOL)createFolderIFNeededAtPath:(NSString*)path{
    
    BOOL isDir;
    
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    
    if(exist == false){
        
        NSError *error;
        
        [[NSFileManager defaultManager]createDirectoryAtPath:path withIntermediateDirectories:false attributes:nil error:&error];
        
        if (error != nil) {
            
            NSLog(@"*** createImagesFolderIFNeeded error%@", [error localizedDescription]);
        }
        
        return (error == nil);
    }
    
    return true;
}

+(BOOL)copyFileIFNeededFromPath:(NSString*)sourcePath ToPath:(NSString*)destinationPath{
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        
        NSError *error;
        
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        if (error != nil) {
            
            NSLog(@"*** copyDataBaseToDocumentsPathIFNeeded error%@", [error localizedDescription]);
        }
        
        return (error == nil);
    }
    
    return true;
}

+(BOOL)deletePath:(NSString*)path{
    
    NSError *error;
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    return (error == nil);
}

+(NSString*)documentsPath{
    
    return [NSString stringWithFormat:@"%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
}

#pragma mark - image
+(void)saveImage:(UIImage*)image ToPath:(NSString*)path{
    
    NSData *pngData = UIImagePNGRepresentation(image);
    
    [pngData writeToFile:path atomically:YES];
}

+(UIImage*)imageFromPath:(NSString*)path{
    
    return  [UIImage imageWithContentsOfFile:path];
}

@end
