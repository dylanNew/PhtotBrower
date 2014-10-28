//
//  XLCycleScrollView.m
//  CycleScrollViewDemo
//
//  Created by xie liang on 9/14/12.
//  Copyright (c) 2012 xie liang. All rights reserved.
//

#import "XLCycleScrollView.h"

@implementation XLCycleScrollView

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize currentPage = _curPage;
@synthesize datasource = _datasource;
@synthesize delegate = _delegate;

- (void)dealloc
{
    [_scrollView setDelegate:nil];
    [_scrollView release];
    [_pageControl release];
    [_curViews release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame andIsNeedPageController:(BOOL)isNeedController
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [_scrollView setAutoresizesSubviews:YES];
        
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        
        if (isNeedController)
        {
            CGRect rect = self.bounds;
            rect.origin.y = rect.size.height - 30;
            rect.size.height = 30;
            _pageControl = [[UIPageControl alloc] initWithFrame:rect];
            _pageControl.userInteractionEnabled = NO;
            
            [self addSubview:_pageControl];
        }
        _curPage = 0;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andIsNeedPageController:NO];
}

- (void)setDataource:(id<XLCycleScrollViewDatasource>)datasource
{
    _datasource = datasource;
    [self reloadData];
}

- (void)reloadData
{
    _totalPages = [_datasource numberOfPages];
    if (_totalPages == 0) {
        return;
    }
    
    if (_curPage >= _totalPages)
    {
        _curPage = 0;
    }
    _pageControl.numberOfPages = _totalPages;
    [self loadData];
}

- (void)loadData
{
    
    _pageControl.currentPage = _curPage;
    
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0)
    {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:_curPage];

    
    for (int i = 0; i < 3; i++)
    {
        UIView *v = [_curViews objectAtIndex:i];
        v.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTap:)];
        singleTap.numberOfTapsRequired = 1;
        [v addGestureRecognizer:singleTap];
        [singleTap release];
        
        UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleRecognizer.numberOfTapsRequired = 2;
        [v addGestureRecognizer:doubleRecognizer];
        [doubleRecognizer release];
        
        [singleTap requireGestureRecognizerToFail:doubleRecognizer];
        
        v.frame = CGRectOffset(v.bounds, v.bounds.size.width * i, 0);
        [_scrollView addSubview:v];
    }
    
    [self customAutoMask];
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width*3,_scrollView.bounds.size.height)];
    [_scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width, 0)];
}

- (void)getDisplayImagesWithCurpage:(int)page {
    
    int pre = [self validPageValue:_curPage-1];
    int last = [self validPageValue:_curPage+1];
    
    if (!_curViews)
    {
        _curViews = [[NSMutableArray alloc] init];
    }
    
    [_curViews removeAllObjects];
    
    [_curViews addObject:[_datasource pageAtIndex:pre]];
    [_curViews addObject:[_datasource pageAtIndex:page]];
    [_curViews addObject:[_datasource pageAtIndex:last]];
    
    // 当前ScrollView滚动到第几页
    if ( [_delegate respondsToSelector:@selector(currentScrollPage:)] )
    {
        [_delegate currentScrollPage:page];
    }
}

- (int)validPageValue:(NSInteger)value
{
    if(value == -1) value = _totalPages - 1;
    if(value == _totalPages) value = 0;
    
    return value;
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([_delegate respondsToSelector:@selector(didClickPage:atIndex:)])
    {
        [_delegate didClickPage:self atIndex:_curPage];
    }
    
}

- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index
{
    if (index == _curPage)
    {
        [_curViews replaceObjectAtIndex:1 withObject:view];
        for (int i = 0; i < 3; i++)
        {
            UIView *v = [_curViews objectAtIndex:i];
            v.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(handleTap:)];
            [v addGestureRecognizer:singleTap];
            [singleTap release];
            
            UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
            doubleRecognizer.numberOfTapsRequired = 2;
            [v addGestureRecognizer:doubleRecognizer];
            [doubleRecognizer release];
            
            [singleTap requireGestureRecognizerToFail:doubleRecognizer];
            
            v.frame = CGRectOffset(v.bounds, v.bounds.size.width * i, 0);
            [_scrollView addSubview:v];
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    int x = aScrollView.contentOffset.x;
    
    //往下翻一张
    if(x >= (2*self.frame.size.width)) {
        _curPage = [self validPageValue:_curPage+1];
        [self loadData];
    }
    
    //往上翻
    if(x <= 0) {
        _curPage = [self validPageValue:_curPage-1];
        [self loadData];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
    if ([_delegate respondsToSelector:@selector(CycScrollViewDidScroll:andCurrentIndex:)])
    {
        [_delegate CycScrollViewDidScroll:self andCurrentIndex:_curPage];
    }
    
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ( [_delegate respondsToSelector:@selector(CycScrollViewBeginScroll:andCurrentIndex:)] )
    {
        [_delegate CycScrollViewBeginScroll:self andCurrentIndex:_curPage];
    }
    
}


-(void)customAutoMask
{
    if (_curViews.count)
    {
        UIView *perView = [_curViews objectAtIndex:0];
        [perView setAutoresizingMask:UIViewAutoresizingNone];
        [perView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        
        UIView *curView = [_curViews objectAtIndex:1];
        [curView setAutoresizingMask:UIViewAutoresizingNone];
        [curView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        
        
        UIView *nexView = [_curViews objectAtIndex:2];
        [nexView setAutoresizingMask:UIViewAutoresizingNone];
        [nexView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    }
}

-(void)layoutSubviews
{
    [self.scrollView setFrame:self.bounds];
    [self.scrollView setContentSize:CGSizeMake(3*self.bounds.size.width, self.bounds.size.height)];
    
    [[self.scrollView subviews]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         UIView *subView =obj;
         CGRect frame = self.scrollView.bounds;
         frame.origin = CGPointZero;
         CGRect rect = CGRectOffset(frame, self.scrollView.frame.size.width*idx, 0);
         [subView setFrame:rect];
    }];
    _scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width, 0);
}

- (void)doubleTap:(UITapGestureRecognizer *)tap
{
    if ([_delegate respondsToSelector:@selector(doubleClick:)])
    {
        [_delegate performSelector:@selector(doubleClick:) withObject:self];
    }
}

- (UIView *)getCurrentShowView
{
    if (_curViews.count == 3)
    {
        return [_curViews objectAtIndex:1];
    }
    else
    {
        return nil;
    }
}

@end
