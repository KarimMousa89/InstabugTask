//
//  CachingHandler.m
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import "CachingHandler.h"

#import "CommonUtils.h"

#import "Product.h"

#import <sqlite3.h>

#define DATA_BASE_FILE_NAME @"Products.sqlite"
#define TABLE_NAME @"Products"

@interface CachingHandler()

@property (strong, nonatomic) dispatch_queue_t dataQueue;

@end

@implementation CachingHandler

-(void)clear{
    
    NSString *query = [NSString stringWithFormat:@"DELETE FROM %@",TABLE_NAME];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_barrier_async(_dataQueue, ^{
        
        [weakSelf executeQuery:[query UTF8String]];
        
//        [weakSelf deletePath:[[CommonUtils documentsPath] stringByAppendingPathComponent:DATA_BASE_FILE_NAME]];
//        
//        [weakSelf copyDataBaseToDocumentsPathIFNeeded];
        
        [CommonUtils deletePath:[[CommonUtils documentsPath] stringByAppendingPathComponent:IMAGES_FOLDER_NAME]];
        
        [weakSelf createImagesFolderIFNeeded];
    });
}

-(NSArray<Product *>*)getAllProducts{
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@",TABLE_NAME];
    
    __block NSArray* result = nil;
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_sync(_dataQueue, ^{
        
        result = [weakSelf runProductsQuery:[query UTF8String]];
    });
    
    return result;
}

-(void)addProducts:(NSArray<Product *>*)products{
    
    NSMutableString* valuesString = [NSMutableString new];
    
    for (Product* product in products) {
        
        [valuesString appendString:[NSString stringWithFormat:@"(%d, '%@', %d, %d, '%@'), ",product.price,product.desc,product.imageData.width,product.imageData.height,product.imageData.url]];
    }
    
    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ (price, desc, imageWidth, imageHeight, imageUrl) VALUES %@;",TABLE_NAME,[valuesString substringToIndex:valuesString.length-2]];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_barrier_async(_dataQueue, ^{
        
        [weakSelf executeQuery:[query UTF8String]];
    });
}

-(void)saveImage:(UIImage*)image ToPath:(NSString*)path{
    
    dispatch_barrier_async(_dataQueue, ^{
        
        [CommonUtils saveImage:image ToPath:path];
        
        [CommonUtils addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",path]]];
    });
}

-(UIImage*)imageFromPath:(NSString*)path{
    
    __block UIImage* result;
    
    dispatch_sync(_dataQueue, ^{
        
        result = [CommonUtils imageFromPath:path];
    });
    
    return result;
}

#pragma mark - private

#pragma mark file managment

-(void)createImagesFolderIFNeeded{
    
    NSString* path = [[CommonUtils documentsPath] stringByAppendingString:IMAGES_FOLDER_NAME];
    
    [CommonUtils createFolderIFNeededAtPath:path];
}

-(void)copyDataBaseToDocumentsPathIFNeeded{
    
    NSString *destinationPath = [[CommonUtils documentsPath] stringByAppendingPathComponent:DATA_BASE_FILE_NAME];
    
    NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATA_BASE_FILE_NAME];
    
    [CommonUtils copyFileIFNeededFromPath:sourcePath ToPath:destinationPath];
}

#pragma mark database
-(sqlite3*)openDB{
    
    sqlite3 *sqlite3Database;

    NSString *databasePath = [[CommonUtils documentsPath] stringByAppendingPathComponent:DATA_BASE_FILE_NAME];
    
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    
    if(openDatabaseResult == SQLITE_OK) {
        
        return sqlite3Database;
    }
    
    return nil;
}

-(sqlite3_stmt*)compiledStatementWithDB:(sqlite3*)db AndQuery:(const char *)query{
    
    sqlite3_stmt *compiledStatement;
    
    BOOL prepareStatementResult = sqlite3_prepare_v2(db, query, -1, &compiledStatement, NULL);
    
    if(prepareStatementResult == SQLITE_OK) {
        
        return compiledStatement;
    }
    
    return nil;
}

-(BOOL)executeQuery:(const char *)query{
    
    BOOL result = false;
    
    sqlite3 *sqlite3Database = [self openDB];
    
    if(sqlite3Database != nil){
        
        sqlite3_stmt *compiledStatement = [self compiledStatementWithDB:sqlite3Database AndQuery:query];
        
        if(compiledStatement != nil){
            
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                
                NSLog(@"***executeQuery DB Error: %s", sqlite3_errmsg(sqlite3Database));
                
            }else{
                
                result = true;
            }
            
            sqlite3_finalize(compiledStatement);
        }
        
        sqlite3_close(sqlite3Database);
    }
    
    return result;
}

-(NSArray*)runProductsQuery:(const char *)query{
    
    NSMutableArray *arrResults = nil;
    
    sqlite3 *sqlite3Database = [self openDB];
    
    if(sqlite3Database != nil){
        
        sqlite3_stmt *compiledStatement = [self compiledStatementWithDB:sqlite3Database AndQuery:query];
        
        if(compiledStatement != nil){
            
            arrResults = [NSMutableArray new];
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
                int totalColumns = sqlite3_column_count(compiledStatement);
                
                NSMutableDictionary* productDict = [NSMutableDictionary new];
                
                for (int i=0; i<totalColumns; i++){
                    
                    char *columnNameChar = (char *)sqlite3_column_name(compiledStatement, i);
                    
                    if (columnNameChar != NULL) {
                        
                        NSString* columnName = [NSString stringWithUTF8String:columnNameChar];
                        
                        if ([columnName isEqualToString:@"desc"] ||
                            [columnName isEqualToString:@"imageUrl"]) {
                            
                            char *columnValueChar = (char *)sqlite3_column_text(compiledStatement, i);
                            
                            [productDict setValue: [NSString stringWithUTF8String:columnValueChar] forKey:columnName];
                        }else{
                            
                            int columnValueint = sqlite3_column_int(compiledStatement, i);
                            
                            [productDict setValue: [NSNumber numberWithInt:columnValueint] forKey:columnName];
                        }
                    }
                }
                
                [arrResults addObject:[[Product alloc] initWithCachedObject:productDict]];
            }
            
            sqlite3_finalize(compiledStatement);
        }
        
        sqlite3_close(sqlite3Database);
    }
    
    return arrResults;
}

#pragma mark - initialization

-(void)initialize{
    
    _dataQueue = dispatch_queue_create("CachingHandlerSafeQueue", DISPATCH_QUEUE_CONCURRENT);
    
    [self copyDataBaseToDocumentsPathIFNeeded];
    
    [self createImagesFolderIFNeeded];
}

#pragma mark - singlton implementation

+ (instancetype)sharedInstance{
    
    static CachingHandler *sharedInstance = nil;
    
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
