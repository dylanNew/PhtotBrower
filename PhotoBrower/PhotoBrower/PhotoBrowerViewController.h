//
//  PhotoBrowerViewController.h
//  RongYi
//
//  Created by udspj on 14-9-19.
//  Copyright (c) 2014年 bluemobi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PhotoBrowerViewController;

@protocol PhotoBrowerViewControllerDelegate <NSObject>

- (void)phototBrowerShareBtnDidClick:(PhotoBrowerViewController *)photoVC object:(NSString *)obj;

@end

/**
 *  图片浏览的VC
 */
@interface PhotoBrowerViewController : UIViewController
{
    NSArray *dataSource;//图片源
}

/**
 *  当前的页数
 */
@property (nonatomic, assign) int currentPage;
@property (nonatomic, weak) id<PhotoBrowerViewControllerDelegate> delegate;//一个委托，用于分享的回调。

- (instancetype)initWithDataSource:(NSArray *)theDataSource;
- (instancetype)initWIthDataSource:(NSArray *)theDataSource andCurrentPage:(int)page;


@end
