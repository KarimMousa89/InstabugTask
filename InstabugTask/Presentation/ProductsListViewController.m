//
//  ProductsListViewController.m
//  InstabugTask
//
//  Created by Karim Mousa on 8/18/17.
//  Copyright © 2017 Karim Mousa. All rights reserved.
//

#import "ProductsListViewController.h"
#import "ProductCollectionViewCell.h"
#import "VariableSizeCollectionViewLayout.h"
#import "ProductDetailsViewController.h"
#import "ProductsListPresenter.h"

#import "CustomTransition.h"

#import "Product.h"

@interface ProductsListViewController ()<ProductsListPresenterViewDelegate,VariableSizeCollectionViewLayoutDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIViewControllerTransitioningDelegate>{
    
    CustomTransition* transition;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *productsCollectionView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@property (weak, nonatomic) IBOutlet UIView *errorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *errorButton;

@property (nonatomic,strong) ProductsListPresenter* presenter;

@property (strong, nonatomic) NSMutableArray<Product*>* products;

@end

@implementation ProductsListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self localize];
    
    transition = [CustomTransition new];
    
    self.errorContainerView.hidden = true;
    
    [_loadingView stopAnimating];
    
    _loadingView.hidden = true;
    
    _products = [NSMutableArray new];
    
    ((VariableSizeCollectionViewLayout*)self.productsCollectionView.collectionViewLayout).delegate = self;
    
    _presenter = [ProductsListPresenter new];
    
    [_presenter setView:self];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if(self.products.count == 0){
        
        [self.presenter load];
    }
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - actions

- (IBAction)retry:(id)sender {
    
    [self.presenter loadMoreProducts];
}

#pragma mark - private

- (void) orientationChanged:(NSNotification *)note{
    
    [((VariableSizeCollectionViewLayout*)self.productsCollectionView.collectionViewLayout) reset];
    
    [self.productsCollectionView reloadData];
}

-(void)localize{
    
    self.titleLabel.text = @"Products list";
    
    [_errorButton setTitle:@"retry" forState:UIControlStateNormal];
    
    [_errorButton setTitle:@"retry" forState:UIControlStateHighlighted];
}

#pragma mark - ProductsListPresenterViewDelegate

-(void)reset{
    
    [self.products removeAllObjects];
    
    [self.productsCollectionView reloadData];
    
    [((VariableSizeCollectionViewLayout*)self.productsCollectionView.collectionViewLayout) reset];
}

-(void)handleServiceStart{
    
    _errorContainerView.hidden = true;
    
    [_loadingView startAnimating];
    
    _loadingView.hidden = false;
}

-(void)handleServiceEnd{
    
    [_loadingView stopAnimating];
    
    _loadingView.hidden = true;
}

-(void)addProducts:(NSArray<Product *> *)products{
    
    [self.products addObjectsFromArray:products];
    
    [self.productsCollectionView reloadData];
}

-(void)handleServiceFailureWithMsg:(NSString*)msg{
    
    self.errorLabel.text = msg;
    
    self.errorContainerView.hidden = false;
}

-(void)reloadProductAtIndex:(NSIndexPath *)index{
    
    [self.productsCollectionView reloadItemsAtIndexPaths:@[index]];
}

#pragma mark - UIViewControllerTransitioningDelegate

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    
    transition.transitionMode = present;
    
    return transition;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    
    transition.transitionMode = dismiss;
    
    return transition;
}

#pragma mark - VariableSizeCollectionViewLayoutDelegate

-(CGFloat)HeightForItemAtIndexPath:(NSIndexPath*)indexPath WithWidth:(CGFloat)width{
    
    Product* currentProduct = _products[indexPath.row];
    
    CGFloat height = extraVerticalPadding + currentProduct.imageData.height;
    
    NSDictionary *attributes = @{NSFontAttributeName: priceFont};
    
    CGFloat questionLabelWidth = width - LabelsHorizontalPadding;
    
    CGSize size = CGSizeMake(questionLabelWidth, CGFLOAT_MAX);
    
    CGRect rect = [[currentProduct priceString] boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil];
    
    height += rect.size.height;
    
    attributes = @{NSFontAttributeName: descFont};
    
    rect = [currentProduct.desc boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil];
    
    height += rect.size.height;
    
    return height;
}

#pragma mark - UICollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _products.count;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(_products.count != 0 &&
       indexPath.row == _products.count - 1){
        
        [self.presenter loadMoreProducts];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ProductCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductCollectionViewCell" forIndexPath:indexPath];
    
    Product* currentProduct = _products[indexPath.row];
    
    [cell setPrice:[currentProduct priceString]];
    
    [cell setDesc:currentProduct.desc];
    
    UIImage* productImage = currentProduct.image;
    
    if(productImage != nil){
        
        [cell setImage:productImage];
    }else{
        
        [cell setImage:[UIImage imageNamed:@"productImagePlaceholder"]];
        
        [self.presenter downloadImageForProduct:currentProduct AtIndex:indexPath];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ProductDetailsViewController* productDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductDetailsViewController"];
    
    productDetailsViewController.product = _products[indexPath.row];
    
    productDetailsViewController.transitioningDelegate = self;
    productDetailsViewController.modalPresentationStyle = UIModalPresentationCustom;
    
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    CGPoint start = CGPointMake(cell.center.x, cell.center.y - collectionView.contentOffset.y);
    
    transition.startingPoint = start;
    
    [self presentViewController:productDetailsViewController animated:true completion:nil];
}

@end
