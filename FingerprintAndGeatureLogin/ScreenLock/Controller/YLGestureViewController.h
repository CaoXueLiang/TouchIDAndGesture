//
//  CLLockVC.h
//  CoreLock
//
//  Created by 成林 on 15/4/21.
//  Copyright (c) 2015年 冯成林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLLockLabel.h"

typedef enum{
    CoreLockTypeSetPwd=0,//设置密码
    CoreLockTypeVeryfiPwd,//输入并验证密码
    CoreLockTypeModifyPwd,//修改密码
    CoreLockTypeScreenLoaker,//首页解锁
}CoreLockType;

typedef enum {
    CoreLockTypeNone = 0, //none
    CoreLockTypePush = 1, //psuh
    CoreLockTypePresent = 2,//present
}CoreLockShowType;



@interface YLGestureViewController : UIViewController

@property (nonatomic,assign) CoreLockType type;
@property (nonatomic,assign) BOOL isFirstLogin;
@property (nonatomic,strong) NSString *mobileNoStr;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet CLLockLabel *label;
@property (nonatomic, assign) BOOL hiddenBackButton;
/*
 *  是否有本地密码缓存？即用户是否设置过初始密码？
 */
+(BOOL)hasPwd;

/*
 *  展示设置密码控制器
 */
+(instancetype)showSettingLockVCInVC:(UIViewController *)vc showType:(CoreLockShowType)showType successBlock:(void(^)(YLGestureViewController *lockVC,NSString *pwd))successBlock backBtnActBlock:(void(^)(void)) backBtnAct;

/*
 *  展示验证密码输入框
 */
+(instancetype)showVerifyLockVCInVC:(UIViewController *)vc showType:(CoreLockShowType)showType  forgetPwdBlock:(void(^)(void))forgetPwdBlock successBlock:(void(^)(YLGestureViewController *lockVC, NSString *pwd))successBlock;

/*
 *  展示修改密码输入框
 */
+(instancetype)showModifyLockVCInVC:(UIViewController *)vc showType:(CoreLockShowType)showType successBlock:(void(^)(YLGestureViewController *lockVC, NSString *pwd))successBlock;

/*
 *  展示应用启动屏幕锁
 */
+(instancetype)showScreenLockVCInVC:(UIViewController *)vc showType:(CoreLockShowType)showType successBlock:(void(^)(YLGestureViewController *lockVC, NSString *pwd))successBlock otherLoginBlcok:(void(^)(YLGestureViewController *lockVC))otherLoginBlock;


/*
 *  消失
 */
-(void)dismiss:(NSTimeInterval)interval;

//手势密码设置
-(void)setGesturePassword:(NSString *)pwd resultBlock:(void(^)(BOOL isSuccess,NSError *error)) resBlock;
//手势密码登录验证
-(void)varifyGesturePwd:(NSString *)gesPwd resultBlock:(void(^)(BOOL isSuccess,NSString *errorMsg)) block;
@end
