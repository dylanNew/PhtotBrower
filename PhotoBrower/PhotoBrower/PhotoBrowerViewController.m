//
//  PhotoBrowerViewController.m
//  RongYi
//
//  Created by udspj on 14-9-19.
//  Copyright (c) 2014年 bluemobi. All rights reserved.
//

#import "PhotoBrowerViewController.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "XLCycleScrollView.h"


#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface PhotoBrowerViewController ()<XLCycleScrollViewDatasource,XLCycleScrollViewDelegate,UIScrollViewDelegate>
{
    
}

@property (nonatomic, strong) XLCycleScrollView *scrollView;
@property (nonatomic, strong) UIView *itemView;//放置2个功能的按钮

@property (nonatomic, strong) UIScrollView *currentScrollView;
@end

@implementation PhotoBrowerViewController

#pragma mark - init
- (instancetype)initWithDataSource:(NSArray *)theDataSource
{
    return [self initWIthDataSource:theDataSource andCurrentPage:0];
}

- (instancetype)initWIthDataSource:(NSArray *)theDataSource andCurrentPage:(int)page
{
    self = [super init];
    if (self)
    {
        dataSource = theDataSource;
        self.currentPage = page;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self initalizerView];
    
    UIBarButtonItem *back=[[UIBarButtonItem alloc] init];
    back.title = @" ";
    UIImage *backbtn = [UIImage imageNamed:@"back_btn_icon.png"];
    [back setBackButtonBackgroundImage:backbtn forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [back setBackButtonBackgroundImage:[UIImage imageNamed:@"back_btn_icon_sel.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [back setStyle:UIBarButtonItemStylePlain];
    
    self.navigationItem.backBarButtonItem = back;
    self.navigationItem.hidesBackButton =YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)initalizerView
{
    //最主要的循环滑动的View
    self.scrollView = [[XLCycleScrollView alloc] initWithFrame:self.view.bounds];
    [self.scrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.scrollView setCurrentPage:self.currentPage];
    [self.scrollView setDataource:self];
    [self.scrollView setDelegate:self];
    [self.scrollView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.scrollView];
    
    //功能按钮的
    self.itemView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, 10, 80, 50)];
    [self.itemView setBackgroundColor:[UIColor clearColor]];
    [self.itemView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.view addSubview:self.itemView];
    
    //2个放在上面的按钮
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setImage:[UIImage imageNamed:@"photo_save.png"] forState:UIControlStateNormal];
    [saveBtn setFrame:CGRectMake(0, 0, 35, 50)];
    [saveBtn addTarget:self action:@selector(saveBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setBackgroundColor:[UIColor clearColor]];
    [saveBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 25, 0)];
    [self.itemView addSubview:saveBtn];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"photo_share.png"] forState:UIControlStateNormal];
    [shareBtn setFrame:CGRectMake(45, 0, 35, 50)];
    [shareBtn addTarget:self action:@selector(shareBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [shareBtn setBackgroundColor:[UIColor clearColor]];
    [shareBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 25, 10)];
    [self.itemView addSubview:shareBtn];
    
}

- (void)saveBtnDidClick:(id)sender
{
    NSString *urlStr = [dataSource objectAtIndex:self.scrollView.currentPage];
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:urlStr] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        if (image)
        {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
    }];
}

- (void)shareBtnDidClick:(id)sender
{
   //分享还是回到一起拿的处理逻辑
    if (self.scrollView.currentPage < dataSource.count)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(phototBrowerShareBtnDidClick:object:)])
        {
            NSString *urlStr = [dataSource objectAtIndex:self.scrollView.currentPage];
            [self.delegate phototBrowerShareBtnDidClick:self object:urlStr];
        }
    }
    else
    {
        //分享发生错误的提示
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error == nil)
    {
//        [SVProgressHUD showSuccessWithStatus:@"保存图片成功！"];
    }
    else
    {
        if ([error code] == -3310)
        {
//            [ShowBox showError:@"无法访问您的相片库！请在设置->隐私->照片 中允许摩生活访问相册。"];
        }
        else
        {
            
//            [SVProgressHUD showErrorWithStatus:@"保存图片失败！"];
        }
    }
}

#pragma mark - XLScrollerViewDelegate
- (NSInteger)numberOfPages
{
    return dataSource.count;
}

- (UIView *)pageAtIndex:(NSInteger)index
{
    UIScrollView *itemScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [itemScrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [itemScrollView setBackgroundColor:[UIColor clearColor]];
    [itemScrollView setDelegate:self];
    [itemScrollView setBounces:NO];
    [itemScrollView setMultipleTouchEnabled:YES];
    [itemScrollView setMinimumZoomScale:1.0];
    [itemScrollView setMaximumZoomScale:8.0];
    
    __weak typeof(self) wSelf = self;
    
    if (index < dataSource.count)
    {
        NSString *urlStr = [dataSource objectAtIndex:index];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.view.bounds, 5, 0)];
        __weak UIImageView *wImgView = imageView;
        
        [imageView setImageWithURL:[NSURL URLWithString:urlStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [wSelf reSetImageView:wImgView image:image];
        }];
        
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [itemScrollView addSubview:imageView];
    }
    return itemScrollView;
}

- (void)reSetImageView:(UIImageView *)imgView image:(UIImage *)img;
{
    if (img == nil || imgView == nil)//参数不齐全
    {
        return;
    }
    
    CGRect sourceRect = self.view.bounds;
    
    
    CGFloat imgViewWidth;
    CGFloat imgViewHeight;
    
    //优先确定 是按 高 还是 宽缩放
    CGFloat imgRate = img.size.width / img.size.height;
    CGFloat sourceRate = sourceRect.size.width / sourceRect.size.height;
    if (imgRate > sourceRate)//目前只处理以宽为主的缩放。 还有一些俄情况
    {
        imgViewWidth = (img.size.width > sourceRect.size.width) ? sourceRect.size.width : img.size.width;
        if (img.size.width > sourceRect.size.width)
        {
            CGFloat origin = sourceRect.size.width/img.size.width;
            imgViewHeight = img.size.height * origin;
        }
        else
        {
            CGFloat origin = img.size.width/sourceRect.size.width;
            imgViewHeight = sourceRect.size.height * origin;
        }
    }
    else
    {
        imgViewHeight = (img.size.height > sourceRect.size.height) ? sourceRect.size.height : img.size.height;
        if (img.size.height > sourceRect.size.height)
        {
            CGFloat origin = sourceRect.size.height/img.size.height;
            imgViewWidth = img.size.width * origin;
        }
        else
        {
            CGFloat origin = img.size.height/sourceRect.size.height;
            imgViewWidth = sourceRect.size.height * origin;
        }
    }
    
    imgView.bounds = CGRectMake(0, 0, imgViewWidth, imgViewHeight);
    imgView.center = CGPointMake(sourceRect.size.width/2, sourceRect.size.height/2);
    
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    self.currentScrollView = scrollView;
    return [scrollView.subviews objectAtIndex:0];
}

//实现图片在缩放过程中居中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIImageView *imgView = [scrollView.subviews objectAtIndex:0];
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    imgView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}

- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

//#pragma mark - 旋转相关的处理
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    return (toInterfaceOrientation == (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight));
//}
//
//- (BOOL)shouldAutorotate
//{
//    return YES;
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAllButUpsideDown;//
//}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    [self.currentScrollView setZoomScale:1];
    [self.scrollView reloadData];
}


- (void)doubleClick:(XLCycleScrollView *)csView
{
    UIScrollView *tView = (UIScrollView *)[csView getCurrentShowView];
    if (tView.zoomScale < 3.0)
    {
        [tView setZoomScale:3.0 animated:YES];
    }
    else
    {
        [tView setZoomScale:1.0 animated:YES];
    }
}



@end
