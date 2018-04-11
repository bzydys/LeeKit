//
//  LeeImagePreviewView.m
//  LeeKit
//
//  Created by Lee on 2018/3/19.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeImagePreviewView.h"
#import "LeeZoomImageView.h"
#import "LeeCollectionViewPageLayout.h"
#import "LeeEmptyView.h"
#import "LeePieProgressView.h"
#import "LeeButton.h"
#import <objc/runtime.h>

BOOL betweenOrEqual(CGFloat minimumValue, CGFloat value, CGFloat maximumValue) {
    return minimumValue <= value && value <= maximumValue;
}

@interface LeeImagePreviewCell : UICollectionViewCell

@property(nonatomic, strong) LeeZoomImageView *zoomImageView;
@end

@implementation LeeImagePreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.zoomImageView = [[LeeZoomImageView alloc] init];
        [self.contentView addSubview:self.zoomImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.zoomImageView.frame = self.contentView.bounds;
}

@end

static NSString * const kLivePhotoCellIdentifier = @"livephoto";
static NSString * const kVideoCellIdentifier = @"video";
static NSString * const kImageOrUnknownCellIdentifier = @"imageorunknown";
@interface LeeImagePreviewView ()

@property(nonatomic, assign) BOOL isChangingCollectionViewBounds;
@property(nonatomic, assign) CGFloat previousIndexWhenScrolling;

@end


@implementation LeeImagePreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitializedWithFrame:frame];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitializedWithFrame:self.frame];
    }
    return self;
}

- (void)didInitializedWithFrame:(CGRect)frame {
    _collectionViewLayout = [[LeeCollectionViewPageLayout alloc] initWithStyle:LeeCollectionViewPageLayoutStyleDefault];
    self.collectionViewLayout.allowMutipleItemScroll = NO;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height) collectionViewLayout:self.collectionViewLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.delaysContentTouches = NO;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    if (@available(iOS 11, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.collectionView registerClass:[LeeImagePreviewCell class] forCellWithReuseIdentifier:kImageOrUnknownCellIdentifier];
    [self.collectionView registerClass:[LeeImagePreviewCell class] forCellWithReuseIdentifier:kVideoCellIdentifier];
    [self.collectionView registerClass:[LeeImagePreviewCell class] forCellWithReuseIdentifier:kLivePhotoCellIdentifier];
    [self addSubview:self.collectionView];
    
    self.loadingColor = [UIColor whiteColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL isCollectionViewSizeChanged = !CGSizeEqualToSize(self.collectionView.bounds.size, self.bounds.size);
    if (isCollectionViewSizeChanged) {
        self.isChangingCollectionViewBounds = YES;
        
        // 必须先 invalidateLayout，再更新 collectionView.frame，否则横竖屏旋转前后的图片不一致（因为 scrollViewDidScroll: 时 contentSize、contentOffset 那些是错的）
        [self.collectionViewLayout invalidateLayout];
        self.collectionView.frame = self.bounds;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentImageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        
        self.isChangingCollectionViewBounds = NO;
    }
}

- (void)setCurrentImageIndex:(NSUInteger)currentImageIndex {
    [self setCurrentImageIndex:currentImageIndex animated:NO];
}

- (void)setCurrentImageIndex:(NSUInteger)currentImageIndex animated:(BOOL)animated {
    _currentImageIndex = currentImageIndex;
    [self.collectionView reloadData];
    if (currentImageIndex < [self.collectionView numberOfItemsInSection:0]) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentImageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    } else {
        NSLog(@"这里似乎有问题");
    }
}

- (void)setLoadingColor:(UIColor *)loadingColor {
    BOOL isLoadingColorChanged = _loadingColor && ![_loadingColor isEqual:loadingColor];
    _loadingColor = loadingColor;
    if (isLoadingColorChanged) {
        [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
    }
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(numberOfImagesInImagePreviewView:)]) {
        return [self.delegate numberOfImagesInImagePreviewView:self];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = kImageOrUnknownCellIdentifier;
    if ([self.delegate respondsToSelector:@selector(imagePreviewView:assetTypeAtIndex:)]) {
        LeeImagePreviewMediaType type = [self.delegate imagePreviewView:self assetTypeAtIndex:indexPath.item];
        if (type == LeeImagePreviewMediaTypeLivePhoto) {
            identifier = kLivePhotoCellIdentifier;
        } else if (type == LeeImagePreviewMediaTypeVideo) {
            identifier = kVideoCellIdentifier;
        }
    }
    LeeImagePreviewCell *cell = (LeeImagePreviewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    LeeZoomImageView *zoomView = cell.zoomImageView;
    ((UIActivityIndicatorView *)zoomView.emptyView.loadingView).color = self.loadingColor;
    zoomView.cloudProgressView.tintColor = self.loadingColor;
    zoomView.cloudDownloadRetryButton.tintColor = self.loadingColor;
    zoomView.delegate = self;
    
    // 因为 cell 复用的问题，很可能此时会显示一张错误的图片，因此这里要清空所有图片的显示
    zoomView.image = nil;
    zoomView.videoPlayerItem = nil;
    if (@available(iOS 9.1, *)) {
        zoomView.livePhoto = nil;
    }
    if ([self.delegate respondsToSelector:@selector(imagePreviewView:renderZoomImageView:atIndex:)]) {
        [self.delegate imagePreviewView:self renderZoomImageView:zoomView atIndex:indexPath.item];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    LeeImagePreviewCell *previewCell = (LeeImagePreviewCell *)cell;
    [previewCell.zoomImageView revertZooming];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    LeeImagePreviewCell *previewCell = (LeeImagePreviewCell *)cell;
    [previewCell.zoomImageView endPlayingVideo];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    
    // 当前滚动到的页数
    if ([self.delegate respondsToSelector:@selector(imagePreviewView:didScrollToIndex:)]) {
        [self.delegate imagePreviewView:self didScrollToIndex:self.currentImageIndex];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    
    if (self.isChangingCollectionViewBounds) {
        return;
    }
    
    CGFloat pageWidth = [self collectionView:self.collectionView layout:self.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].width;
    CGFloat pageHorizontalMargin = self.collectionViewLayout.minimumLineSpacing;
    CGFloat contentOffsetX = self.collectionView.contentOffset.x;
    CGFloat index = contentOffsetX / (pageWidth + pageHorizontalMargin);
    
    // 在滑动过临界点的那一次才去调用 delegate，避免过于频繁的调用
    BOOL isFirstDidScroll = self.previousIndexWhenScrolling == 0;
    BOOL turnPageToRight = betweenOrEqual(self.previousIndexWhenScrolling, floor(index) + 0.5, index);
    BOOL turnPageToLeft = betweenOrEqual(index, floor(index) + 0.5, self.previousIndexWhenScrolling);
    if (!isFirstDidScroll && (turnPageToRight || turnPageToLeft)) {
        index = round(index);
        if (0 <= index && index < [self.collectionView numberOfItemsInSection:0]) {
            
            // 不调用 setter，避免又走一次 scrollToItem
            _currentImageIndex = index;
            
            if ([self.delegate respondsToSelector:@selector(imagePreviewView:willScrollHalfToIndex:)]) {
                [self.delegate imagePreviewView:self willScrollHalfToIndex:index];
            }
        }
    }
    self.previousIndexWhenScrolling = index;
}

@end

@implementation LeeImagePreviewView (LeeZoomImageView)

- (NSInteger)indexForZoomImageView:(LeeZoomImageView *)zoomImageView {
    if ([zoomImageView.superview.superview isKindOfClass:[LeeImagePreviewCell class]]) {
        return [self.collectionView indexPathForCell:(LeeImagePreviewCell *)zoomImageView.superview.superview].item;
    } else {
        NSAssert(NO, @"尝试通过 %s 获取 LeeZoomImageView 所在的 index，但找不到 LeeZoomImageView 所在的 cell，index 获取失败。%@", __func__, zoomImageView);
    }
    return NSUIntegerMax;
}

- (LeeZoomImageView *)zoomImageViewAtIndex:(NSUInteger)index {
    LeeImagePreviewCell *cell = (LeeImagePreviewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell.zoomImageView;
}

- (void)checkIfDelegateMissing {
#ifdef DEBUG
    [self enumerateProtocolMethods:@protocol(LeeZoomImageViewDelegate) usingBlock:^(SEL selector) {
        if (![self respondsToSelector:selector]) {
            NSAssert(NO, @"%@ 需要响应 %@ 的方法 -%@", NSStringFromClass([self class]), NSStringFromProtocol(@protocol(LeeZoomImageViewDelegate)), NSStringFromSelector(selector));
        }
    }];
#endif
}

- (void)enumerateProtocolMethods:(Protocol *)protocol usingBlock:(void (^)(SEL))block {
    unsigned int methodCount = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, NO, YES, &methodCount);
    for (int i = 0; i < methodCount; i++) {
        struct objc_method_description methodDescription = methods[i];
        if (block) {
            block(methodDescription.name);
        }
    }
    free(methods);
}

#pragma mark - <LeeZoomImageViewDelegate>

- (void)singleTouchInZoomingImageView:(LeeZoomImageView *)imageView location:(CGPoint)location {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate singleTouchInZoomingImageView:imageView location:location];
    }
}

- (void)doubleTouchInZoomingImageView:(LeeZoomImageView *)imageView location:(CGPoint)location {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate doubleTouchInZoomingImageView:imageView location:location];
    }
}

- (void)longPressInZoomingImageView:(LeeZoomImageView *)imageView {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate longPressInZoomingImageView:imageView];
    }
}

- (void)didTouchICloudRetryButtonInZoomImageView:(LeeZoomImageView *)imageView {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate didTouchICloudRetryButtonInZoomImageView:imageView];
    }
}

- (void)zoomImageView:(LeeZoomImageView *)imageView didHideVideoToolbar:(BOOL)didHide {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate zoomImageView:imageView didHideVideoToolbar:didHide];
    }
}

- (BOOL)enabledZoomViewInZoomImageView:(LeeZoomImageView *)imageView {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        return [self.delegate enabledZoomViewInZoomImageView:imageView];
    }
    return YES;
}

- (UIEdgeInsets)contentInsetsForVideoToolbar:(LeeZoomImageViewVideoToolbar *)toolbar inZoomingImageView:(LeeZoomImageView *)zoomImageView {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        return [self.delegate contentInsetsForVideoToolbar:toolbar inZoomingImageView:zoomImageView];
    }
    return toolbar.contentInsets;
}

@end

