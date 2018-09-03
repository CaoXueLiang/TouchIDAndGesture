//
//  CXLTouchID.h
//  FingerprintAndGeatureLogin
//
//  Created by 曹学亮 on 2018/9/3.
//  Copyright © 2018年 Cao Xueliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>


/**
 指纹密码回调block
 @param sucess 指纹是否验证成功
 @param errorMessage 验证结果提示信息
 */
typedef void (^CXLTouchIDOpenBlock)(BOOL sucess,NSString *errorMessage);


@interface CXLTouchID : LAContext
/**
 单例初始化
 @return CXLTouchID单例
 */
+ (instancetype)shareInstancetype;


/**
 进行指纹验证
 @param block 验证结果回调
 */
- (void)openTouchID:(CXLTouchIDOpenBlock)block;
@end
