//
//  TagView.m
//  LeeKit
//
//  Created by Lee on 2018/2/27.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "TagView.h"
#import "UIButton+imageCliped.h"
#import "UIImage+corner.h"

@interface FloatLeftLayout: UICollectionViewFlowLayout

@property(nonatomic, strong) TagConfig *config;

@property(nonatomic, strong) NSArray<NSString *>* titles;

@property(nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attrs;

@end

@implementation FloatLeftLayout

-(void)prepareLayout{
    NSAssert(self.titles != nil, @"必须给layout的title赋值");
    self.minimumLineSpacing = self.config.itemSpace;
    self.minimumInteritemSpacing = self.config.itemSpace;
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.sectionInset = UIEdgeInsetsMake(self.config.itemSpace, self.config.itemSpace, self.config.itemSpace, self.config.itemSpace);
    CGFloat x = self.sectionInset.left;
    CGFloat y = self.sectionInset.top;
    for (NSUInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
        NSString *title = self.titles[i];
        CGSize tagLabelSize = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}];
        CGSize realSize = CGSizeMake(tagLabelSize.width + self.config.inset.left + self.config.inset.right, self.config.maxItemHeight < (tagLabelSize.height + self.config.inset.bottom + self.config.inset.top) ? self.config.maxItemHeight : (tagLabelSize.height + self.config.inset.bottom + self.config.inset.top));
        UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        if (x + realSize.width + self.sectionInset.right > self.collectionView.frame.size.width) {
            x = self.sectionInset.left;
            y = y + realSize.height + self.minimumLineSpacing;
            attr.frame = CGRectMake(x, y, realSize.width, realSize.height);
            [self.attrs addObject:attr];
        }else{
            if (x == self.sectionInset.left && i != 0) {
                x = x + self.attrs.lastObject.frame.size.width + self.minimumInteritemSpacing;
                attr.frame = CGRectMake(x, y, realSize.width, realSize.height);
                [self.attrs addObject:attr];
            }else{
                attr.frame = CGRectMake(x, y, realSize.width, realSize.height);
                [self.attrs addObject:attr];
                
            }
            x = x + realSize.width + self.minimumInteritemSpacing;
            
        }
    }
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

-(NSArray<UICollectionViewLayoutAttributes *> *)attrs{
    if (!_attrs) {
        _attrs = [NSMutableArray arrayWithCapacity:[self.collectionView numberOfItemsInSection:0]];
    }
    return _attrs;
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{

    return self.attrs;
}

-(CGSize)collectionViewContentSize{
    CGSize size = CGSizeMake(0,CGRectGetMaxY(self.attrs.lastObject.frame) + self.sectionInset.bottom);
    return size;
}

@end

@interface DefaultCell: UICollectionViewCell

@property(nonatomic, strong) UIButton *contentBtn;

@end

@implementation DefaultCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _contentBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _contentBtn.frame = self.bounds;
        _contentBtn.userInteractionEnabled = NO;
        [self.contentView addSubview:_contentBtn];
    }
    return self;
}

-(void)configCellWithTitle:(NSString *)title config:(TagConfig *)config{
    [self.contentBtn lee_setBackgroundImage:[UIImage lee_imageWithColor:config.normalBackgroundColor size:self.contentBtn.bounds.size] forState:UIControlStateNormal cornerRadius:config.cornerRadius isEqualScale:YES];
    [self.contentBtn lee_setBackgroundImage:[UIImage lee_imageWithColor:config.selectedBackgroundColor size:self.contentBtn.bounds.size] forState:UIControlStateSelected cornerRadius:config.cornerRadius isEqualScale:YES];
    [self.contentBtn setTitleColor:config.normalTitleColor forState:UIControlStateNormal];
    [self.contentBtn setTitleColor:config.selectedTitleColor forState:UIControlStateSelected];
    self.contentBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.contentBtn setTitle:title forState:UIControlStateNormal];
}

@end

@interface TagView()<UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) UICollectionView *containerView;

@property(nonatomic, strong) NSArray<NSString *> *titles;

@property(nonatomic, strong) TagConfig *config;

@end

static NSString * cellId = @"cellId";

@implementation TagView


-(instancetype)initWithTitles:(NSArray<NSString *> *)titles config:(TagConfig *)config{
    if (self = [super initWithFrame:CGRectZero]) {
        self.config = config;
        self.titles = titles;
        [self setupUI];
    }
    return self;
}

-(instancetype)initWithTitles:(NSArray<NSString *> *)titles{
    return [self initWithTitles:titles config:[[TagConfig alloc] init]];
}

-(void)setupUI{
    FloatLeftLayout *layout = [[FloatLeftLayout alloc] init];
    layout.minimumInteritemSpacing = self.config.itemSpace;
    layout.minimumLineSpacing = self.config.itemSpace;
    layout.config = self.config;
    layout.titles = self.titles;
    self.containerView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 375, 70) collectionViewLayout:layout];
    [self.containerView registerClass:[DefaultCell class] forCellWithReuseIdentifier:@"cellId"];
    self.containerView.delegate = self;
    self.containerView.dataSource = self;
    [self addSubview:self.containerView];
    self.containerView.backgroundColor = self.containerView.superview.backgroundColor;
    self.containerView.delaysContentTouches = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat height = self.containerView.contentSize.height + self.containerView.adjustedContentInset.top + self.containerView.adjustedContentInset.bottom;
        if (height > self.config.maxHeight) {
            height = self.config.maxHeight;
        }
        self.containerView.frame = CGRectMake(0, 0, self.bounds.size.width, height);
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(self.containerView.frame));

    });
}

#pragma mark - UIcollectionView
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.titles.count;
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DefaultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    [cell configCellWithTitle:self.titles[indexPath.item] config:self.config];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"----------");
}
@end
