//
//  ViewController.m
//  FingerprintAndGeatureLogin
//
//  Created by 曹学亮 on 2018/9/3.
//  Copyright © 2018年 Cao Xueliang. All rights reserved.
//

#import "ViewController.h"
#import "CXLTouchID.h"
#import "YLGestureViewController.h"

@interface ViewController ()
@property (nonatomic,strong) UIButton *touchButton;
@property (nonatomic,strong) UIButton *gestureButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.touchButton.frame = CGRectMake(100, 100, 100, 40);
    [self.view addSubview:self.touchButton];
    self.gestureButton.frame = CGRectMake(100, 180, 100, 40);
    [self.view addSubview:self.gestureButton];
}


- (void)touchButtonClicked{
    [[CXLTouchID shareInstancetype] openTouchID:^(BOOL sucess, NSString *errorMessage) {
        NSLog(@"========%@",errorMessage);
    }];
}


- (void)gestureButtonClicked{
    //设置手势密码
    [YLGestureViewController showSettingLockVCInVC:self showType:CoreLockTypePresent successBlock:^(YLGestureViewController *lockVC, NSString *pwd) {
        [lockVC dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"%@",pwd);
    } backBtnActBlock:^{

    }];
    
    
    //手势解锁
//    [YLGestureViewController showVerifyLockVCInVC:self showType:CoreLockTypePresent forgetPwdBlock:^{
//
//    } successBlock:^(YLGestureViewController *lockVC, NSString *pwd) {
//        [lockVC dismissViewControllerAnimated:YES completion:nil];
//        NSLog(@"========%@",pwd);
//    }];
    
    
    //修改密码
//    [YLGestureViewController showModifyLockVCInVC:self showType:CoreLockTypePresent successBlock:^(YLGestureViewController *lockVC, NSString *pwd) {
//        NSLog(@"----------%@",pwd);
//    }];

    //应用启动屏幕锁
//    [YLGestureViewController showScreenLockVCInVC:self showType:CoreLockTypePresent successBlock:^(YLGestureViewController *lockVC, NSString *pwd) {
//        NSLog(@"%@",pwd);
//    } otherLoginBlcok:^(YLGestureViewController *lockVC) {
//
//    }];
}

#pragma mark - Setter && Getter
- (UIButton *)touchButton{
    if (!_touchButton) {
        _touchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_touchButton setTitle:@"验证指纹" forState:UIControlStateNormal];
        [_touchButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _touchButton.backgroundColor = [UIColor lightGrayColor];
        [_touchButton addTarget:self action:@selector(touchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _touchButton;
}

- (UIButton *)gestureButton{
    if (!_gestureButton) {
        _gestureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_gestureButton setTitle:@"验证手势" forState:UIControlStateNormal];
        [_gestureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _gestureButton.backgroundColor = [UIColor lightGrayColor];
        [_gestureButton addTarget:self action:@selector(gestureButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _gestureButton;
}

@end

