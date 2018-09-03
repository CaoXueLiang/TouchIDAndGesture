//
//  CLLockView.h
//  CoreLock
//
//  Created by 成林 on 15/4/21.
//  Copyright (c) 2015年 冯成林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLGestureViewController.h"

@interface CLLockView : UIView

@property (nonatomic,assign) CoreLockType type;
@property (nonatomic,assign) BOOL isOldPwdVerifySuccess;


/*
 *  设置密码
 */

/** 开始输入，第一次 */
@property (nonatomic,copy) void (^setPWBeginBlock)(void);

/** 开始输入，确认密码*/
@property (nonatomic,copy) void (^setPWConfirmlock)(void);


/** 设置密码出错：长度不够 */
@property (nonatomic,copy) void (^setPWSErrorLengthTooShortBlock)(NSUInteger currentCount);


/** 设置密码出错：再次密码不一致 */
@property (nonatomic,copy) void (^setPWSErrorTwiceDiffBlock)(NSString *pwd1,NSString *pwdNow);


/** 设置密码：第一次输入正确*/
@property (nonatomic,copy) void (^setPWFirstRightBlock)(void);


/** 再次密码输入一致 */
@property (nonatomic,copy) void (^setPWTwiceSameBlock)(NSString *pwd);


/*
 *  重设密码
 */
-(void)resetPwd;


/*
 *  验证密码
 */

/** 验证密码开始*/
@property (nonatomic,copy) void (^verifyPWBeginBlock)(void);

/** 验证密码 */
@property (nonatomic,copy) void (^verifyPwdBlock)(NSString *pwd);
/**网络验证结果*/
@property (nonatomic,copy) void (^isNetworkVerifyBlock)(BOOL isSuccess);


/*
 *  修改密码
 */
/** 再次密码输入一致 */
@property (nonatomic,copy) void (^modifyPwdBlock)(void);


/** 密码修改成功 */
@property (nonatomic,copy) void (^modifyPwdSuccessBlock)(void);

/** 屏幕锁4次输入错误*/
@property (nonatomic,copy) BOOL (^screenLoakerBlock)(NSString *pwd);




@end
