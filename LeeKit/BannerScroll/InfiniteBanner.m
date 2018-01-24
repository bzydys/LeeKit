//
//  InfiniteBanner.m
//  LeeKit
//
//  Created by Lee on 2018/1/22.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "InfiniteBanner.h"
#import "InfiniteConfiguration.h"


@interface InfiniteBanner()<UIScrollViewDelegate>
{
    NSInteger _currentIndex;
    NSMutableArray *_imgArray;
    NSMutableArray *_imgUrls;
}
@property(nonatomic, strong) UIScrollView *contentScrollView;
@property(nonatomic, strong) UIImageView *leftImageView;
@property(nonatomic, strong) UIImageView *middleImageView;
@property(nonatomic, strong) UIImageView *rightImageView;
@property(nonatomic, strong) UIPageControl *pageControl;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, copy) loadMethod myLoad;


@end

@implementation InfiniteBanner

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initData];
        self.config = [InfiniteConfiguration new];
    }
    return self;
}

-(instancetype)init{
    return [self initWithFrame:CGRectZero];
}

-(void)showImages:(NSArray<UIImage *> *)imgs{
    self.contentScrollView.contentSize = CGSizeMake(self.frame.size.width * MAX(imgs.count, 3), 0);
    _imgArray = [imgs mutableCopy];
    [self initView];
    [self configData:imgs];
    [self createTimer];
    
}

-(void)showImagesWithUrls:(NSArray<NSURL *> *)urls loadMethod:(loadMethod)loadFunc{
    self.myLoad = loadFunc;
    self.contentScrollView.contentSize = CGSizeMake(self.frame.size.width * MAX(urls.count, 3), 0);
    _imgUrls = [urls mutableCopy];
    [self initView];
    [self configData:urls];
    [self createTimer];
}

#pragma mark - getter & setter
-(UIScrollView *)contentScrollView{
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.delegate = self;
        _contentScrollView.bounces = NO;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
//        [_contentScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.frame) * 3, CGRectGetHeight(self.frame))];
    }
    return _contentScrollView;
}

-(UIImageView *)leftImageView{
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] init];
//        _leftImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _leftImageView;
}

-(UIImageView *)middleImageView{
    if (!_middleImageView) {
        _middleImageView = [[UIImageView alloc] init];
//        _middleImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _middleImageView;
}

-(UIImageView *)rightImageView{
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] init];
//        _rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _rightImageView;
}

-(UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
    }
    return _pageControl;
}

#pragma mark - private method

-(void)initData{
    _currentIndex = 0;
    _imgArray = [NSMutableArray array];
    _imgUrls = [NSMutableArray array];
}
-(void)initView{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.contentScrollView addSubview:self.leftImageView];
    [self.contentScrollView addSubview:self.middleImageView];
    [self.contentScrollView addSubview:self.rightImageView];
    [self addSubview:self.contentScrollView];
    [self addSubview:self.pageControl];
    //一开始现将scrollView往左划一下
    [self resetImages];
//    self.contentScrollView.contentOffset = CGPointMake(CGRectGetWidth(self.frame), 0.f);
}

-(void)configData:(NSArray *)images{
    self.pageControl.numberOfPages = images.count;
    self.pageControl.hidden = images.count <= 1;
    if (self.config.pageSelectColor) {
        self.pageControl.currentPageIndicatorTintColor = self.config.pageSelectColor;
    }
    if (self.config.pageUnselectColor) {
        self.pageControl.pageIndicatorTintColor = self.config.pageUnselectColor;
    }
    switch (self.config.direction) {
        case PageControllDirectionLeft:
            _pageControl.frame = CGRectMake(10, self.frame.size.height - 30, [_pageControl sizeForNumberOfPages:images.count].width, 30);
            break;
        case PageControllDirectionRight:
            _pageControl.frame = CGRectMake(self.frame.size.width - 20 - [_pageControl sizeForNumberOfPages:images.count].width, self.frame.size.height - 30, [_pageControl sizeForNumberOfPages:images.count].width, 30);
            break;
            
        case PageControllDirectionCenter:
            _pageControl.frame = CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 30);
            break;
        default:
            break;
    }
}

-(void)createTimer{
    if (self.config.isInfinite) {
        if (!_timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.config.duration target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
    }
    
}

-(void)destoryTimer{
    if (_timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void)resetImages{
    if (_imgArray.count > 0) {
        NSUInteger idx1 = ((_currentIndex - 1 >= 0)?(_currentIndex - 1):(_imgArray.count - 1))%_imgArray.count;
        self.leftImageView.image = _imgArray[idx1];
        NSUInteger idx2 = (_currentIndex)%_imgArray.count;
        self.middleImageView.image = _imgArray[idx2];
        NSUInteger idx3 = (_currentIndex + 1)%_imgArray.count;
        self.rightImageView.image = _imgArray[idx3];
        self.pageControl.currentPage = idx2;
    }
    
    if (_imgUrls.count > 0) {
        if (self.myLoad) {
            self.myLoad(_imgUrls[((_currentIndex - 1)?(_currentIndex - 1):_imgUrls.count - 1)%_imgUrls.count], self.leftImageView);
            self.myLoad(_imgUrls[(_currentIndex)%_imgUrls.count], self.middleImageView);
            self.myLoad(_imgUrls[(_currentIndex + 1)%_imgUrls.count], self.rightImageView);
            self.pageControl.currentPage = _currentIndex%_imgUrls.count;
        }
    }
    
    self.contentScrollView.contentOffset = CGPointMake(CGRectGetWidth(self.frame), 0);
    
    
}

-(void)autoScroll{
    [self.contentScrollView setContentOffset:CGPointMake(self.frame.size.width * 2, 0) animated:YES];
//    [self.contentScrollView scrollRectToVisible:CGRectMake(self.frame.size.width * 2, 0, self.frame.size.width, self.frame.size.height) animated:YES];
}

#pragma mark - 布局
-(void)layoutSubviews{
    [super layoutSubviews];
    self.contentScrollView.frame = self.bounds;
    self.leftImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.middleImageView.frame = CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
    self.rightImageView.frame = CGRectMake(self.frame.size.width * 2, 0, self.frame.size.width, self.frame.size.height);
    
    
}

#pragma mark - ScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x == self.frame.size.width * 2) {
        //滑动到最右端
        _currentIndex++;
    }else if (scrollView.contentOffset.x == 0){
        //滑动到了最左端
        if (_currentIndex == 0) {
            _currentIndex = _imgUrls.count ? _imgUrls.count - 1 : _imgArray.count - 1;
        }else{
            _currentIndex--;
        }
    }
    [self resetImages];
}
//动画会走这个
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSLog(@"-----------");
    [self scrollViewDidEndDecelerating:scrollView];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self destoryTimer];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self createTimer];
    
}



@end
