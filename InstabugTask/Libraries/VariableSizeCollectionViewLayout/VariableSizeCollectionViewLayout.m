//
//  VariableSizeCollectionViewLayout.m
//  InstabugTask
//
//  Created by Karim Mousa on 8/20/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import "VariableSizeCollectionViewLayout.h"

#define MIMIMUM_CELL_WIDTH 150

@interface VariableSizeCollectionViewLayout(){
    
    NSMutableArray<UICollectionViewLayoutAttributes*>* attributes;
    
    CGFloat contentHeight;
}

@end

@implementation VariableSizeCollectionViewLayout

-(void)reset{
    
    attributes = [NSMutableArray new];
}

-(void)prepareLayout{
    
    if(attributes == nil){
        
        attributes = [NSMutableArray new];
    }
    
    if(attributes.count != [self.collectionView numberOfItemsInSection:0]){
        
        contentHeight = 0;
        
        [attributes removeAllObjects];
        
        int numberOfColumns = (self.collectionView.bounds.size.width/MIMIMUM_CELL_WIDTH);
        
        CGFloat columnWidth = self.collectionView.bounds.size.width/numberOfColumns;
        
        NSMutableArray *xoffsets = [NSMutableArray new];
        
        NSMutableArray *yoffsets = [NSMutableArray new];
        
        for (int i = 0; i<numberOfColumns; i++) {
            
            xoffsets[i] = [NSNumber numberWithFloat:i*columnWidth];
            
            yoffsets[i] = @(0);
        }
        
        int currentColumn = 0;
        
        for (int index = 0; index < [self.collectionView numberOfItemsInSection:0]; index++) {
            
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            
            CGSize itemSize = CGSizeMake(columnWidth, [self.delegate HeightForItemAtIndexPath:indexPath WithWidth:columnWidth]);
            
            CGRect itemFrame = CGRectMake([xoffsets[currentColumn] floatValue], [yoffsets[currentColumn] floatValue], itemSize.width, itemSize.height);
            
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            attr.frame = itemFrame;
            
            [attributes addObject:attr];
            
            contentHeight = MAX(contentHeight, CGRectGetMaxY(itemFrame));
            
            yoffsets[currentColumn] = [NSNumber numberWithFloat:[yoffsets[currentColumn] floatValue] + itemFrame.size.height];
            
            if(index < numberOfColumns-1){
                
                currentColumn ++;
            }else{
                
                float ymin = MAXFLOAT;
                
                for (int i = 0; i<numberOfColumns; i++) {
                    
                    float y = [yoffsets[i] floatValue];
                    
                    if (y < ymin) {
                        
                        ymin = y;
                        
                        currentColumn = i;
                    }
                }
            }
        }
    }
}

-(CGSize)collectionViewContentSize{
    
    return CGSizeMake(self.collectionView.bounds.size.width, contentHeight);
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    NSMutableArray* layoutAttributes = [NSMutableArray new];
    
    for (UICollectionViewLayoutAttributes* attr in attributes) {
        
        if(CGRectIntersectsRect(attr.frame, rect)){
            
            [layoutAttributes addObject:attr];
        }
    }
    
    return layoutAttributes;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{

    return attributes[indexPath.row];
}

@end
