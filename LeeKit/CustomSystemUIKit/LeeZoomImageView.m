//
//  LeeZoomImageView.m
//  LeeKit
//
//  Created by Lee on 2018/3/19.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeeZoomImageView.h"
#import "LeeEmptyView.h"
#import "UIImage+Lee.h"
#import "UIColor+Lee.h"
#import "UIScrollView+Lee.h"
#import "LeeButton.h"
#import "LeeSlider.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIControl+Lee.h"
#import "UILabel+Lee.h"
#import "LeePieProgressView.h"

#define kIconsColor [UIColor colorWithRed:1 green:1 blue:1 alpha:.75f]
CGRect CGRectSetXY(CGRect rect, CGFloat x, CGFloat y) {
    rect.origin.x = x;
    rect.origin.y = y;
    return rect;
}

CGRect CGRectSetSize(CGRect rect, CGSize size) {
    rect.size = size;
    return rect;
}


// generate icon images needed by LeeZoomImageView
// 用于生成 LeeZoomImageView 所需的一些简单的图标图片
@interface LeeZoomImageViewImageGenerator : NSObject

+ (UIImage *)largePlayImage;
+ (UIImage *)smallPlayImage;
+ (UIImage *)pauseImage;

@end

@interface LeeZoomImageVideoPlayerView : UIView

@end

static NSUInteger const kTagForCenteredPlayButton = 1;

@interface LeeZoomImageView () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIScrollView *scrollView;

// video play
@property(nonatomic, strong) LeeZoomImageVideoPlayerView *videoPlayerView;
@property(nonatomic, strong) AVPlayer *videoPlayer;
@property(nonatomic, strong) id videoTimeObserver;
@property(nonatomic, assign) BOOL isSeekingVideo;
@property(nonatomic, assign) CGSize videoSize;

@end

@implementation LeeZoomImageView

@synthesize imageView = _imageView;
@synthesize livePhotoView = _livePhotoView;
@synthesize videoPlayerLayer = _videoPlayerLayer;
@synthesize videoToolbar = _videoToolbar;
@synthesize videoCenteredPlayButton = _videoCenteredPlayButton;
@synthesize cloudProgressView = _cloudProgressView;
@synthesize cloudDownloadRetryButton = _cloudDownloadRetryButton;

- (void)didMoveToWindow {
    // 当 self.window 为 nil 时说明此 view 被移出了可视区域（比如所在的 controller 被 pop 了），此时应该停止视频播放
    if (!self.window) {
        [self endPlayingVideo];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        LeeZoomImageView *appearance = [LeeZoomImageView appearance];
        _videoCenteredPlayButtonImage = appearance.videoCenteredPlayButtonImage;
        
        self.contentMode = UIViewContentModeCenter;
        self.maximumZoomScale = 2.0;
        
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.minimumZoomScale = 0;
        self.scrollView.maximumZoomScale = self.maximumZoomScale;
        self.scrollView.delegate = self;
        if (@available(iOS 11, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:self.scrollView];
        
        _emptyView = [[LeeEmptyView alloc] init];
        ((UIActivityIndicatorView *)self.emptyView.loadingView).color = [UIColor whiteColor];
        self.emptyView.hidden = YES;
        [self addSubview:self.emptyView];
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGestureWithPoint:)];
        singleTapGesture.delegate = self;
        singleTapGesture.numberOfTapsRequired = 1;
        singleTapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:singleTapGesture];
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGestureWithPoint:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        doubleTapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:doubleTapGesture];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        [self addGestureRecognizer:longPressGesture];
        
        // 双击失败后才出发单击
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    self.scrollView.frame = self.bounds;
    self.emptyView.frame = self.bounds;
    
    CGRect viewportRect = [self finalViewportRect];
    
    if (_videoCenteredPlayButton) {
        _videoCenteredPlayButton.center = CGPointMake(CGRectGetMidX(viewportRect), CGRectGetMidY(viewportRect));
    }
    
    if (_videoToolbar) {
        _videoToolbar.frame = ({
            CGFloat height = [_videoToolbar sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].height;
            CGRectMake(0, CGRectGetHeight(self.bounds) - height, CGRectGetWidth(self.bounds), height);
        });
    }
    
    if (_cloudProgressView && _cloudDownloadRetryButton) {
        CGPoint origin = CGPointMake(12, 12);
        _cloudDownloadRetryButton.frame = CGRectSetXY(_cloudDownloadRetryButton.frame, origin.x, 20 + [self NavigationBarHeight] + origin.y);
        _cloudProgressView.frame = CGRectSetSize(_cloudProgressView.frame, _cloudDownloadRetryButton.currentImage.size);
        _cloudProgressView.center = _cloudDownloadRetryButton.center;
    }
}


-(CGFloat)NavigationBarHeight{
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        return 32;
    }
    return 44;
}

- (void)setFrame:(CGRect)frame {
    BOOL isBoundsChanged = !CGSizeEqualToSize(frame.size, self.frame.size);
    [super setFrame:frame];
    if (isBoundsChanged) {
        [self revertZooming];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Normal Image

- (UIImageView *)imageView {
    [self initImageViewIfNeeded];
    return _imageView;
}

- (void)initImageViewIfNeeded {
    if (_imageView) {
        return;
    }
    _imageView = [[UIImageView alloc] init];
    [self.scrollView addSubview:_imageView];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    // 释放以节省资源
    [_livePhotoView removeFromSuperview];
    _livePhotoView = nil;
    [self destroyVideoRelatedObjectsIfNeeded];
    
    if (!image) {
        _imageView.image = nil;
        return;
    }
    [self initImageViewIfNeeded];
    self.imageView.image = image;
    
    // 更新 imageView 的大小时，imageView 可能已经被缩放过，所以要应用当前的缩放
    self.imageView.frame = CGRectApplyAffineTransform(CGRectMake(0,0,image.size.width,image.size.height), self.imageView.transform);
    
    [self hideViews];
    self.imageView.hidden = NO;
    
    [self revertZooming];
}

#pragma mark - Live Photo

- (PHLivePhotoView *)livePhotoView {
    [self initLivePhotoViewIfNeeded];
    return _livePhotoView;
}

- (void)setLivePhoto:(PHLivePhoto *)livePhoto {
    _livePhoto = livePhoto;
    
    [_imageView removeFromSuperview];
    _imageView = nil;
    [self destroyVideoRelatedObjectsIfNeeded];
    
    if (!livePhoto) {
        _livePhotoView.livePhoto = nil;
        return;
    }
    
    [self initLivePhotoViewIfNeeded];
    if (@available(iOS 9.1, *)) {
        _livePhotoView.livePhoto = livePhoto;
    }
    _livePhotoView.hidden = NO;
    
    // 更新 livePhotoView 的大小时，livePhotoView 可能已经被缩放过，所以要应用当前的缩放
    _livePhotoView.frame = CGRectApplyAffineTransform(CGRectMake(0,0,livePhoto.size.width,livePhoto.size.height), _livePhotoView.transform);
    
    [self revertZooming];
}

- (void)initLivePhotoViewIfNeeded {
    if (@available(iOS 9.1, *)) {
        if (_livePhotoView) {
            return;
        }
        _livePhotoView = [[PHLivePhotoView alloc] init];
        [self.scrollView addSubview:_livePhotoView];
    }
}

#pragma mark - Image Scale

- (void)setContentMode:(UIViewContentMode)contentMode {
    BOOL isContentModeChanged = self.contentMode != contentMode;
    [super setContentMode:contentMode];
    if (isContentModeChanged) {
        [self revertZooming];
    }
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale {
    _maximumZoomScale = maximumZoomScale;
    self.scrollView.maximumZoomScale = maximumZoomScale;
}

- (CGFloat)minimumZoomScale {
    if (!self.image && !self.livePhoto && !self.videoPlayerItem) {
        return 1;
    }
    
    CGRect viewport = [self finalViewportRect];
    CGSize mediaSize = CGSizeZero;
    if (self.image) {
        mediaSize = self.image.size;
    } else if (self.livePhoto) {
        mediaSize = self.livePhoto.size;
    } else if (self.videoPlayerItem) {
        mediaSize = self.videoSize;
    }
    
    CGFloat minScale = 1;
    CGFloat scaleX = CGRectGetWidth(viewport) / mediaSize.width;
    CGFloat scaleY = CGRectGetHeight(viewport) / mediaSize.height;
    if (self.contentMode == UIViewContentModeScaleAspectFit) {
        minScale = fmin(scaleX, scaleY);
    } else if (self.contentMode == UIViewContentModeScaleAspectFill) {
        minScale = fmax(scaleX, scaleY);
    } else if (self.contentMode == UIViewContentModeCenter) {
        if (scaleX >= 1 && scaleY >= 1) {
            minScale = 1;
        } else {
            minScale = fmin(scaleX, scaleY);
        }
    }
    return minScale;
}

- (void)revertZooming {
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    BOOL enabledZoomImageView = [self enabledZoomImageView];
    CGFloat minimumZoomScale = [self minimumZoomScale];
    CGFloat maximumZoomScale = enabledZoomImageView ? self.maximumZoomScale : minimumZoomScale;
    maximumZoomScale = fmax(minimumZoomScale, maximumZoomScale);// 可能外部通过 contentMode = UIViewContentModeScaleAspectFit 的方式来让小图片撑满当前的 zoomImageView，所以算出来 minimumZoomScale 会很大（至少比 maximumZoomScale 大），所以这里要做一个保护
    CGFloat zoomScale = minimumZoomScale;
    BOOL shouldFireDidZoomingManual = zoomScale == self.scrollView.zoomScale;
    self.scrollView.panGestureRecognizer.enabled = enabledZoomImageView;
    self.scrollView.pinchGestureRecognizer.enabled = enabledZoomImageView;
    self.scrollView.minimumZoomScale = minimumZoomScale;
    self.scrollView.maximumZoomScale = maximumZoomScale;
    [self setZoomScale:zoomScale animated:NO];
    
    // 只有前后的 zoomScale 不相等，才会触发 UIScrollViewDelegate scrollViewDidZoom:，因此对于相等的情况要自己手动触发
    if (shouldFireDidZoomingManual) {
        [self handleDidEndZooming];
    }
    
    // 当内容比 viewport 的区域更大时，要把内容放在 viewport 正中间
    self.scrollView.contentOffset = ({
        CGFloat x = self.scrollView.contentOffset.x;
        CGFloat y = self.scrollView.contentOffset.y;
        CGRect viewport = [self finalViewportRect];
        if (!CGRectIsEmpty(viewport)) {
            UIView *contentView = [self currentContentView];
            if (CGRectGetWidth(viewport) < CGRectGetWidth(contentView.frame)) {
                x = (CGRectGetWidth(contentView.frame) / 2 - CGRectGetWidth(viewport) / 2) - CGRectGetMinX(viewport);
            }
            if (CGRectGetHeight(viewport) < CGRectGetHeight(contentView.frame)) {
                y = (CGRectGetHeight(contentView.frame) / 2 - CGRectGetHeight(viewport) / 2) - CGRectGetMinY(viewport);
            }
        }
        CGPointMake(x, y);
    });
}

- (void)setZoomScale:(CGFloat)zoomScale animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:.25 delay:0.0 options:7<<16 animations:^{
            self.scrollView.zoomScale = zoomScale;
        } completion:nil];
    } else {
        self.scrollView.zoomScale = zoomScale;
    }
}

- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:.25 delay:0.0 options:7<<16 animations:^{
            [self.scrollView zoomToRect:rect animated:NO];
        } completion:nil];
    } else {
        [self.scrollView zoomToRect:rect animated:NO];
    }
}

- (CGRect)imageViewRectInZoomImageView {
    UIView *imageView = [self currentContentView];
    return [self convertRect:imageView.frame fromView:imageView.superview];
}

- (void)handleDidEndZooming {
    CGRect viewport = [self finalViewportRect];
    
    UIView *contentView = [self currentContentView];
    // 强制 layout 以确保下面的一堆计算依赖的都是最新的 frame 的值
    [self layoutIfNeeded];
    CGRect contentViewFrame = contentView ? [self convertRect:contentView.frame fromView:contentView.superview] : CGRectZero;
    UIEdgeInsets contentInset = UIEdgeInsetsZero;
    
    contentInset.top = CGRectGetMinY(viewport);
    contentInset.left = CGRectGetMinX(viewport);
    contentInset.right = CGRectGetWidth(self.bounds) - CGRectGetMaxX(viewport);
    contentInset.bottom = CGRectGetHeight(self.bounds) - CGRectGetMaxY(viewport);
    
    // 图片 height 比选图框(viewport)的 height 小，这时应该把图片纵向摆放在选图框中间，且不允许上下移动
    if (CGRectGetHeight(viewport) > CGRectGetHeight(contentViewFrame)) {
        // 用 floor 而不是 flat，是因为 flat 本质上是向上取整，会导致 top + bottom 比实际的大，然后 scrollView 就认为可滚动了
        contentInset.top = floor(CGRectGetMidY(viewport) - CGRectGetHeight(contentViewFrame) / 2.0);
        contentInset.bottom = floor(CGRectGetHeight(self.bounds) - CGRectGetMidY(viewport) - CGRectGetHeight(contentViewFrame) / 2.0);
    }
    
    // 图片 width 比选图框的 width 小，这时应该把图片横向摆放在选图框中间，且不允许左右移动
    if (CGRectGetWidth(viewport) > CGRectGetWidth(contentViewFrame)) {
        contentInset.left = floor(CGRectGetMidX(viewport) - CGRectGetWidth(contentViewFrame) / 2.0);
        contentInset.right = floor(CGRectGetWidth(self.bounds) - CGRectGetMidX(viewport) - CGRectGetWidth(contentViewFrame) / 2.0);
    }
    
    self.scrollView.contentInset = contentInset;
    self.scrollView.contentSize = contentView.frame.size;
}

- (BOOL)enabledZoomImageView {
    BOOL enabledZoom = YES;
    if ([self.delegate respondsToSelector:@selector(enabledZoomViewInZoomImageView:)]) {
        enabledZoom = [self.delegate enabledZoomViewInZoomImageView:self];
    } else if (!self.image && !self.livePhoto && !self.videoPlayerItem) {
        enabledZoom = NO;
    }
    return enabledZoom;
}

#pragma mark - Video

- (void)setVideoPlayerItem:(AVPlayerItem *)videoPlayerItem {
    _videoPlayerItem = videoPlayerItem;
    
    [_livePhotoView removeFromSuperview];
    _livePhotoView = nil;
    [_imageView removeFromSuperview];
    _imageView = nil;
    
    if (!videoPlayerItem) {
        [self hideViews];
        return;
    }
    
    // 获取视频尺寸
    NSArray<AVAssetTrack *> *tracksArray = videoPlayerItem.asset.tracks;
    self.videoSize = CGSizeZero;
    for (AVAssetTrack *track in tracksArray) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            CGSize size = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
            self.videoSize = CGSizeMake(fabs(size.width), fabs(size.height));
            break;
        }
    }
    
    self.videoPlayer = [AVPlayer playerWithPlayerItem:videoPlayerItem];
    [self initVideoRelatedViewsIfNeeded];
    _videoPlayerLayer.player = self.videoPlayer;
    // 更新 videoPlayerView 的大小时，videoView 可能已经被缩放过，所以要应用当前的缩放
    self.videoPlayerView.frame = CGRectApplyAffineTransform(CGRectMake(0,0,self.videoSize.width,self.videoSize.height), self.videoPlayerView.transform);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVideoPlayToEndEvent) name:AVPlayerItemDidPlayToEndTimeNotification object:videoPlayerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self configVideoProgressSlider];
    
    [self hideViews];
    self.videoPlayerLayer.hidden = NO;
    self.videoCenteredPlayButton.hidden = NO;
    self.videoToolbar.playButton.hidden = NO;
    
    [self revertZooming];
}

- (void)handlePlayButton:(UIButton *)button {
    [self addPlayerTimeObserver];
    [self.videoPlayer play];
    self.videoCenteredPlayButton.hidden = YES;
    self.videoToolbar.playButton.hidden = YES;
    self.videoToolbar.pauseButton.hidden = NO;
    if (button.tag == kTagForCenteredPlayButton) {
        self.videoToolbar.hidden = YES;
        if ([self.delegate respondsToSelector:@selector(zoomImageView:didHideVideoToolbar:)]) {
            [self.delegate zoomImageView:self didHideVideoToolbar:YES];
        }
    }
}
- (void)handlePauseButton {
    [self.videoPlayer pause];
    self.videoToolbar.playButton.hidden = NO;
    self.videoToolbar.pauseButton.hidden = YES;
}

- (void)handleVideoPlayToEndEvent {
    [self.videoPlayer seekToTime:CMTimeMake(0, 1)];
    self.videoCenteredPlayButton.hidden = NO;
    self.videoToolbar.playButton.hidden = NO;
    self.videoToolbar.pauseButton.hidden = YES;
}

- (void)handleStartDragVideoSlider:(UISlider *)slider {
    [self.videoPlayer pause];
    [self removePlayerTimeObserver];
}

- (void)handleDraggingVideoSlider:(UISlider *)slider {
    if (!self.isSeekingVideo) {
        self.isSeekingVideo = YES;
        [self updateVideoSliderLeftLabel];
        
        CGFloat currentValue = slider.value;
        [self.videoPlayer seekToTime:CMTimeMakeWithSeconds(currentValue, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isSeekingVideo = NO;
            });
        }];
    }
}

- (void)handleFinishDragVideoSlider:(UISlider *)slider {
    [self.videoPlayer play];
    self.videoCenteredPlayButton.hidden = YES;
    self.videoToolbar.playButton.hidden = YES;
    self.videoToolbar.pauseButton.hidden = NO;
    
    [self addPlayerTimeObserver];
}

- (void)syncVideoProgressSlider {
    double currentSeconds = CMTimeGetSeconds(self.videoPlayer.currentTime);
    [self.videoToolbar.slider setValue:currentSeconds];
    [self updateVideoSliderLeftLabel];
}

- (void)configVideoProgressSlider {
    self.videoToolbar.sliderLeftLabel.text = [self timeStringFromSeconds:0];
    double duration = CMTimeGetSeconds(self.videoPlayerItem.asset.duration);
    self.videoToolbar.sliderRightLabel.text = [self timeStringFromSeconds:duration];
    
    self.videoToolbar.slider.minimumValue = 0.0;
    self.videoToolbar.slider.maximumValue = duration;
    self.videoToolbar.slider.value = 0;
    [self.videoToolbar.slider addTarget:self action:@selector(handleStartDragVideoSlider:) forControlEvents:UIControlEventTouchDown];
    [self.videoToolbar.slider addTarget:self action:@selector(handleDraggingVideoSlider:) forControlEvents:UIControlEventValueChanged];
    [self.videoToolbar.slider addTarget:self action:@selector(handleFinishDragVideoSlider:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addPlayerTimeObserver];
}

- (void)addPlayerTimeObserver {
    if (self.videoTimeObserver) {
        return;
    }
    double interval = .1f;
    __weak LeeZoomImageView *weakSelf = self;
    self.videoTimeObserver = [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf syncVideoProgressSlider];
    }];
}

- (void)removePlayerTimeObserver {
    if (!self.videoTimeObserver) {
        return;
    }
    [self.videoPlayer removeTimeObserver:self.videoTimeObserver];
    self.videoTimeObserver = nil;
}

- (void)updateVideoSliderLeftLabel {
    double currentSeconds = CMTimeGetSeconds(self.videoPlayer.currentTime);
    self.videoToolbar.sliderLeftLabel.text = [self timeStringFromSeconds:currentSeconds];
}

// convert "100" to "01:40"
- (NSString *)timeStringFromSeconds:(NSUInteger)seconds {
    NSUInteger min = floor(seconds / 60);
    NSUInteger sec = floor(seconds - min * 60);
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)min, (long)sec];
}

- (void)pauseVideo {
    if (!self.videoPlayer) {
        return;
    }
    [self handlePauseButton];
    [self removePlayerTimeObserver];
}

- (void)endPlayingVideo {
    if (!self.videoPlayer) {
        return;
    }
    [self.videoPlayer seekToTime:CMTimeMake(0, 1)];
    [self pauseVideo];
    [self syncVideoProgressSlider];
    self.videoToolbar.hidden = YES;
    self.videoCenteredPlayButton.hidden = NO;
    
}

- (AVPlayerLayer *)videoPlayerLayer {
    [self initVideoPlayerLayerIfNeeded];
    return _videoPlayerLayer;
}

- (LeeZoomImageViewVideoToolbar *)videoToolbar {
    [self initVideoToolbarIfNeeded];
    return _videoToolbar;
}

- (LeeButton *)videoCenteredPlayButton {
    [self initVideoCenteredPlayButtonIfNeeded];
    return _videoCenteredPlayButton;
}

- (void)initVideoPlayerLayerIfNeeded {
    if (self.videoPlayerView) {
        return;
    }
    self.videoPlayerView = [[LeeZoomImageVideoPlayerView alloc] init];
    _videoPlayerLayer = (AVPlayerLayer *)self.videoPlayerView.layer;
    self.videoPlayerView.hidden = YES;
    [self.scrollView addSubview:self.videoPlayerView];
}

- (void)initVideoToolbarIfNeeded {
    if (_videoToolbar) {
        return;
    }
    _videoToolbar = ({
        LeeZoomImageViewVideoToolbar * b = [[LeeZoomImageViewVideoToolbar alloc] init];
        if ([self.delegate respondsToSelector:@selector(contentInsetsForVideoToolbar:inZoomingImageView:)]) {
            b.contentInsets = [self.delegate contentInsetsForVideoToolbar:b inZoomingImageView:self];
        }
        [b.playButton addTarget:self action:@selector(handlePlayButton:) forControlEvents:UIControlEventTouchUpInside];
        [b.pauseButton addTarget:self action:@selector(handlePauseButton) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:b belowSubview:self.emptyView];
        b.hidden = YES;
        b;
    });
}

- (void)initVideoCenteredPlayButtonIfNeeded {
    if (_videoCenteredPlayButton) {
        return;
    }
    
    _videoCenteredPlayButton = ({
        LeeButton *b = [[LeeButton alloc] init];
        b.lee_outsideEdge = UIEdgeInsetsMake(-60, -60, -60, -60);
        b.tag = kTagForCenteredPlayButton;
        [b setImage:self.videoCenteredPlayButtonImage forState:UIControlStateNormal];
        [b sizeToFit];
        [b addTarget:self action:@selector(handlePlayButton:) forControlEvents:UIControlEventTouchUpInside];
        b.hidden = YES;
        [self insertSubview:b belowSubview:self.emptyView];
        b;
    });
}

- (void)initVideoRelatedViewsIfNeeded {
    [self initVideoPlayerLayerIfNeeded];
    [self initVideoToolbarIfNeeded];
    [self initVideoCenteredPlayButtonIfNeeded];
    [self setNeedsLayout];
}

- (void)destroyVideoRelatedObjectsIfNeeded {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self removePlayerTimeObserver];
    
    [self.videoPlayerView removeFromSuperview];
    self.videoPlayerView = nil;
    
    [self.videoToolbar removeFromSuperview];
    _videoToolbar = nil;
    
    [self.videoCenteredPlayButton removeFromSuperview];
    _videoCenteredPlayButton = nil;
    
    self.videoPlayer = nil;
}

- (void)setVideoCenteredPlayButtonImage:(UIImage *)videoCenteredPlayButtonImage {
    _videoCenteredPlayButtonImage = videoCenteredPlayButtonImage;
    if (!self.videoCenteredPlayButton) {
        return;
    }
    [self.videoCenteredPlayButton setImage:videoCenteredPlayButtonImage forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)applicationDidEnterBackground {
    [self pauseVideo];
}

#pragma mark - iCloud

- (LeePieProgressView *)cloudProgressView {
    [self initCloudRelatedViewsIfNeeded];
    return _cloudProgressView;
}

- (UIButton *)cloudDownloadRetryButton {
    [self initCloudRelatedViewsIfNeeded];
    return _cloudDownloadRetryButton;
}

- (void)initCloudRelatedViewsIfNeeded {
    [self initCloudProgressViewIfNeeded];
    [self initCloudDownloadRetryButtonIfNeeded];
}

- (void)initCloudProgressViewIfNeeded {
    if (_cloudProgressView) {
        return;
    }
    _cloudProgressView = [[LeePieProgressView alloc] init];
    _cloudProgressView.tintColor = ((UIActivityIndicatorView *)self.emptyView.loadingView).color;
    _cloudProgressView.hidden = YES;
    [self addSubview:_cloudProgressView];
}

- (void)initCloudDownloadRetryButtonIfNeeded {
    if (_cloudDownloadRetryButton) {
        return;
    }
    
    _cloudDownloadRetryButton = [[LeeButton alloc] init];
    [_cloudDownloadRetryButton setImage:[UIImage imageNamed:@"LeeToastResource.bundle/Lee_icloud_download_fault"] forState:UIControlStateNormal];
    _cloudDownloadRetryButton.adjustsImageTintColorAutomatically = YES;
    _cloudDownloadRetryButton.tintColor = ((UIActivityIndicatorView *)self.emptyView.loadingView).color;
    [_cloudDownloadRetryButton sizeToFit];
    _cloudDownloadRetryButton.lee_outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
    _cloudDownloadRetryButton.hidden = YES;
    [_cloudDownloadRetryButton addTarget:self action:@selector(handleICloudDownloadRetryEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cloudDownloadRetryButton];
}

- (void)setCloudDownloadStatus:(LeeAssetDownloadStatus)cloudDownloadStatus {
    BOOL statusChanged = _cloudDownloadStatus != cloudDownloadStatus;
    _cloudDownloadStatus = cloudDownloadStatus;
    switch (cloudDownloadStatus) {
        case LeeAssetDownloadStatusSucceed:
            self.cloudProgressView.hidden = YES;
            self.cloudDownloadRetryButton.hidden = YES;
            break;
            
        case LeeAssetDownloadStatusDownloading:
            self.cloudProgressView.hidden = NO;
            [self.cloudProgressView.superview bringSubviewToFront:self.cloudProgressView];
            self.cloudDownloadRetryButton.hidden = YES;
            break;
            
        case LeeAssetDownloadStatusCanceled:
            self.cloudProgressView.hidden = YES;
            self.cloudDownloadRetryButton.hidden = YES;
            break;
            
        case LeeAssetDownloadStatusFailed:
            self.cloudProgressView.hidden = YES;
            self.cloudDownloadRetryButton.hidden = NO;
            [self.cloudDownloadRetryButton.superview bringSubviewToFront:self.cloudDownloadRetryButton];
            break;
            
        default:
            break;
    }
    if (statusChanged) {
        [self setNeedsLayout];
    }
}

- (void)handleICloudDownloadRetryEvent:(UIView *)sender {
    if ([self.delegate respondsToSelector:@selector(didTouchICloudRetryButtonInZoomImageView:)]) {
        [self.delegate didTouchICloudRetryButtonInZoomImageView:self];
    }
}

#pragma mark - GestureRecognizers

- (void)handleSingleTapGestureWithPoint:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint gesturePoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    if ([self.delegate respondsToSelector:@selector(singleTouchInZoomingImageView:location:)]) {
        [self.delegate singleTouchInZoomingImageView:self location:gesturePoint];
    }
    if (self.videoPlayerItem) {
        self.videoToolbar.hidden = !self.videoToolbar.hidden;
        if ([self.delegate respondsToSelector:@selector(zoomImageView:didHideVideoToolbar:)]) {
            [self.delegate zoomImageView:self didHideVideoToolbar:self.videoToolbar.hidden];
        }
    }
}

- (void)handleDoubleTapGestureWithPoint:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint gesturePoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    if ([self.delegate respondsToSelector:@selector(doubleTouchInZoomingImageView:location:)]) {
        [self.delegate doubleTouchInZoomingImageView:self location:gesturePoint];
    }
    
    if ([self enabledZoomImageView]) {
        // 如果图片被压缩了，则第一次放大到原图大小，第二次放大到最大倍数
        if (self.scrollView.zoomScale >= self.scrollView.maximumZoomScale) {
            [self setZoomScale:self.scrollView.minimumZoomScale animated:YES];
        } else {
            CGFloat newZoomScale = 0;
            if (self.scrollView.zoomScale < 1) {
                // 如果目前显示的大小比原图小，则放大到原图
                newZoomScale = 1;
            } else {
                // 如果当前显示原图，则放大到最大的大小
                newZoomScale = self.scrollView.maximumZoomScale;
            }
            
            CGRect zoomRect = CGRectZero;
            CGPoint tapPoint = [[self currentContentView] convertPoint:gesturePoint fromView:gestureRecognizer.view];
            zoomRect.size.width = CGRectGetWidth(self.bounds) / newZoomScale;
            zoomRect.size.height = CGRectGetHeight(self.bounds) / newZoomScale;
            zoomRect.origin.x = tapPoint.x - CGRectGetWidth(zoomRect) / 2;
            zoomRect.origin.y = tapPoint.y - CGRectGetHeight(zoomRect) / 2;
            [self zoomToRect:zoomRect animated:YES];
        }
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if ([self enabledZoomImageView] && longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(longPressInZoomingImageView:)]) {
            [self.delegate longPressInZoomingImageView:self];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - EmptyView

- (void)showLoading {
    // 挪到最前面
    [self insertSubview:self.emptyView atIndex:(self.subviews.count - 1)];
    [self.emptyView setLoadingViewHidden:NO];
    [self.emptyView setTextLabelText:nil];
    [self.emptyView setDetailTextLabelText:nil];
    [self.emptyView setActionButtonTitle:nil];
    self.emptyView.hidden = NO;
}

- (void)showEmptyViewWithText:(NSString *)text {
    [self insertSubview:self.emptyView atIndex:(self.subviews.count - 1)];
    [self.emptyView setLoadingViewHidden:YES];
    [self.emptyView setTextLabelText:text];
    [self.emptyView setDetailTextLabelText:nil];
    [self.emptyView setActionButtonTitle:nil];
    self.emptyView.hidden = NO;
}

- (void)hideEmptyView {
    self.emptyView.hidden = YES;
}

#pragma mark - <UIScrollViewDelegate>

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self currentContentView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self handleDidEndZooming];
}

#pragma mark - 工具方法

- (CGRect)finalViewportRect {
    CGRect rect = self.viewportRect;
    if (CGRectIsEmpty(rect) && !CGRectIsEmpty(self.bounds)) {
        // 有可能此时还没有走到过 layoutSubviews 因此拿不到正确的 scrollView 的 size，因此这里要强制 layout 一下
        if (!CGSizeEqualToSize(self.scrollView.bounds.size, self.bounds.size)) {
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
        rect = CGRectMake(0,0,self.scrollView.bounds.size.width,self.scrollView.bounds.size.height);
    }
    return rect;
}

- (void)hideViews {
    _livePhotoView.hidden = YES;
    _imageView.hidden = YES;
    _videoCenteredPlayButton.hidden = YES;
    _videoPlayerLayer.hidden = YES;
    _videoToolbar.hidden = YES;
    _videoToolbar.pauseButton.hidden = YES;
    _videoToolbar.playButton.hidden = YES;
    _videoCenteredPlayButton.hidden = YES;
}


- (UIView *)currentContentView {
    if (_imageView) {
        return _imageView;
    }
    if (_livePhotoView) {
        return _livePhotoView;
    }
    if (self.videoPlayerView) {
        return self.videoPlayerView;
    }
    return nil;
}

@end

@interface LeeZoomImageView (UIAppearance)

@end

@implementation LeeZoomImageView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    LeeZoomImageView *appearance = [LeeZoomImageView appearance];
    appearance.videoCenteredPlayButtonImage = [LeeZoomImageViewImageGenerator largePlayImage];
}

@end

@implementation LeeZoomImageVideoPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end

@implementation LeeZoomImageViewImageGenerator

+ (UIImage *)largePlayImage {
    CGFloat width = 60;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *color = kIconsColor;
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    // circle outside
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:0 alpha:.25f].CGColor);
    CGFloat circleLineWidth = 1;
    // consider line width to avoid edge clip
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(circleLineWidth / 2, circleLineWidth / 2, width - circleLineWidth, width - circleLineWidth)];
    [circle setLineWidth:circleLineWidth];
    [circle stroke];
    [circle fill];
    
    // triangle inside
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGFloat triangleLength = width / 2.5;
    UIBezierPath *triangle = [self trianglePathWithLength:triangleLength];
    UIOffset offset = UIOffsetMake(width / 2 - triangleLength * tan(M_PI / 6) / 2, width / 2 - triangleLength / 2);
    [triangle applyTransform:CGAffineTransformMakeTranslation(offset.horizontal, offset.vertical)];
    [triangle fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)smallPlayImage {
    // width and height are equal
    CGFloat width = 17;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *color = kIconsColor;
    CGContextSetFillColorWithColor(context, color.CGColor);
    UIBezierPath *path = [self trianglePathWithLength:width];
    [path fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)pauseImage {
    CGSize size = CGSizeMake(12, 18);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *color = kIconsColor;
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGFloat lineWidth = 2;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(lineWidth / 2, 0)];
    [path addLineToPoint:CGPointMake(lineWidth / 2, size.height)];
    [path moveToPoint:CGPointMake(size.width - lineWidth / 2, 0)];
    [path addLineToPoint:CGPointMake(size.width - lineWidth / 2, size.height)];
    [path setLineWidth:lineWidth];
    [path stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// @param length of the triangle side
+ (UIBezierPath *)trianglePathWithLength:(CGFloat)length {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path addLineToPoint:CGPointMake(length * cos(M_PI / 6), length / 2)];
    [path addLineToPoint:CGPointMake(0, length)];
    [path closePath];
    return path;
}

@end

@implementation LeeZoomImageViewVideoToolbar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        LeeZoomImageViewVideoToolbar *appearance = [LeeZoomImageViewVideoToolbar appearance];
        _contentInsets = appearance.contentInsets;
        _playButtonImage = appearance.playButtonImage;
        _pauseButtonImage = appearance.pauseButtonImage;
        
        self.backgroundColor = [UIColor colorWithRed:0.5/255.0 green:1 blue:0 alpha:0];
        
        _playButton = [[LeeButton alloc] init];
        self.playButton.lee_outsideEdge = UIEdgeInsetsMake(-10, -10, -10, -10);
        [self.playButton setImage:self.playButtonImage forState:UIControlStateNormal];
        [self addSubview:self.playButton];
        
        _pauseButton = [[LeeButton alloc] init];
        self.pauseButton.lee_outsideEdge = UIEdgeInsetsMake(-10, -10, -10, -10);
        [self.pauseButton setImage:self.pauseButtonImage forState:UIControlStateNormal];
        [self addSubview:self.pauseButton];
        
        _slider = [[LeeSlider alloc] init];
        self.slider.minimumTrackTintColor = [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1];
        self.slider.maximumTrackTintColor = [UIColor colorWithRed:95/255.0 green:95/255.0 blue:95/255.0 alpha:1];
        self.slider.thumbSize = CGSizeMake(12, 12);
        self.slider.thumbColor = [UIColor whiteColor];
        [self addSubview:self.slider];
        
        _sliderLeftLabel = [[UILabel alloc] init];
        _sliderLeftLabel.font = [UIFont systemFontOfSize:12];
        _sliderLeftLabel.textColor = [UIColor whiteColor];
        self.sliderLeftLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.sliderLeftLabel];
        
        _sliderRightLabel = [[UILabel alloc] init];
        _sliderRightLabel.font = self.sliderLeftLabel.font;
        _sliderRightLabel.backgroundColor = self.sliderLeftLabel.backgroundColor;
        _sliderRightLabel.lineBreakMode = self.sliderLeftLabel.lineBreakMode;
        _sliderRightLabel.textAlignment = self.sliderLeftLabel.textAlignment;
        [self addSubview:self.sliderRightLabel];
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = .5;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 10;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat contentHeight = [self maxHeightAmongViews:@[self.playButton, self.pauseButton, self.sliderLeftLabel, self.sliderRightLabel, self.slider]];
    
    self.playButton.frame = ({
        CGSize size = [self.playButton sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        CGRectMake(self.contentInsets.left, contentHeight / 2 - size.height / 2 + self.contentInsets.top, size.width, size.height);
    });
    
    self.pauseButton.frame = ({
        CGSize size = [self.pauseButton sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        CGRectMake(CGRectGetMidX(self.playButton.frame) - size.width / 2, CGRectGetMidY(self.playButton.frame) - size.height / 2, size.width, size.height);
    });
    
    CGFloat timeLabelWidth = 55;
    self.sliderLeftLabel.frame = ({
        CGFloat marginLeft = 19;
        CGRectMake(CGRectGetMaxX(self.playButton.frame) + marginLeft, self.contentInsets.top, timeLabelWidth, contentHeight);
    });
    self.sliderRightLabel.frame = ({
        CGRectMake(CGRectGetWidth(self.bounds) - self.contentInsets.right - timeLabelWidth, self.contentInsets.top, timeLabelWidth, contentHeight);
    });
    self.slider.frame = ({
        CGFloat marginToLabel = 4;
        CGFloat x = CGRectGetMaxX(self.sliderLeftLabel.frame) + marginToLabel;
        CGRectMake(x, self.contentInsets.top, CGRectGetMinX(self.sliderRightLabel.frame) - marginToLabel - x, contentHeight);
    });
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat contentHeight = [self maxHeightAmongViews:@[self.playButton, self.pauseButton, self.sliderLeftLabel, self.sliderRightLabel, self.slider]];
    size.height = contentHeight + self.contentInsets.top + self.contentInsets.bottom;
    return size;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    [self setNeedsLayout];
}

- (void)setPlayButtonImage:(UIImage *)playButtonImage {
    _playButtonImage = playButtonImage;
    [self.playButton setImage:playButtonImage forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)setPauseButtonImage:(UIImage *)pauseButtonImage {
    _pauseButtonImage = pauseButtonImage;
    [self.pauseButton setImage:pauseButtonImage forState:UIControlStateNormal];
    [self setNeedsLayout];
}

// 返回一堆 view 中高度最大的那个的高度
- (CGFloat)maxHeightAmongViews:(NSArray<UIView *> *)views {
    __block CGFloat maxValue = 0;
    [views enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat height = [obj sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].height;
        maxValue = MAX(height, maxValue);
    }];
    return maxValue;
}

@end

@interface LeeZoomImageViewVideoToolbar (UIAppearance)

@end

@implementation LeeZoomImageViewVideoToolbar (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    LeeZoomImageViewVideoToolbar *appearance = [LeeZoomImageViewVideoToolbar appearance];
    appearance.contentInsets = UIEdgeInsetsMake(25, 25, 25, 18);
    appearance.playButtonImage = [LeeZoomImageViewImageGenerator smallPlayImage];
    appearance.pauseButtonImage = [LeeZoomImageViewImageGenerator pauseImage];
}

@end
