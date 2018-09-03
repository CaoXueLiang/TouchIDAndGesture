//
//  CXLTouchID.m
//  FingerprintAndGeatureLogin
//
//  Created by 曹学亮 on 2018/9/3.
//  Copyright © 2018年 Cao Xueliang. All rights reserved.
//

#import "CXLTouchID.h"

@interface CXLTouchID()
@property (nonatomic,strong) LAContext *context;
@property (nonatomic,copy) CXLTouchIDOpenBlock doneBlock;
@end

@implementation CXLTouchID
+ (instancetype)shareInstancetype{
    static CXLTouchID *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CXLTouchID alloc] init];
    });
    return instance;
}


- (void)openTouchID:(CXLTouchIDOpenBlock)block{
    self.doneBlock = block;
    if (![self p_isSupportTouchID]) {
        self.doneBlock(NO, @"不支持TouchID");
        return;
    }
    [self openTouchIDWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics touchIDBlock:self.doneBlock];
}


//进行指纹扫描
- (void)openTouchIDWithPolicy:(LAPolicy )policy touchIDBlock:(CXLTouchIDOpenBlock)block{
    [self.context evaluatePolicy:policy localizedReason:@"通过Home键验证已有手机指纹" reply:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            //指纹验证成功
            block(YES,@"通过了 TouchID 指纹验证");
        }else{
            //指纹验证失败
            LAError errorCode = error.code;
            NSString *errorMessage = @"";
            switch (errorCode) {
                case LAErrorAuthenticationFailed:{
                    //连续三次指纹识别错误
                    errorMessage = @"授权失败";
                }break;
                case LAErrorUserCancel:{
                    //在TouchID对话框中点击了取消按钮或者Home键
                    errorMessage = @"用户取消验证Touch ID";
                }break;
                case LAErrorUserFallback:{
                    //在TouchID对话框中点击了输入密码按钮，在这里可以做一些自定义操作
                    errorMessage = @"用户选择输入密码";
                }break;
                case LAErrorSystemCancel:{
                    //TouchID对话框被系统取消，例如按下电源键
                    errorMessage = @"取消授权，如其他应用切入，用户自主";
                }break;
                case LAErrorPasscodeNotSet:{
                    errorMessage = @"取消授权，如其他应用切入，用户自主";
                }break;
                case LAErrorTouchIDNotAvailable:{
                    errorMessage = @"设备未设置Touch ID";
                }break;
                case LAErrorTouchIDNotEnrolled:{
                    errorMessage = @"用户未录入指纹";
                }break;
                case LAErrorTouchIDLockout:{
                    errorMessage = @"Touch ID被锁，需要用户输入系统密码解锁";
                    // 往本地用户偏好设置里把touchIdIsLocked标识设置为yes，表示指纹识别被锁
                    [[NSUserDefaults standardUserDefaults] setObject:@(YES)forKey:@"touchIdIsLocked"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self p_touchIdIsLocked];
                }break;
                case LAErrorAppCancel:{
                    errorMessage = @"用户不能控制情况下，app被挂起";
                }break;
                case LAErrorInvalidContext:{
                    errorMessage = @"LAContext传递给这个调用之前已经失效";
                }break;
                default:
                    break;
            }
            block(NO,errorMessage);
        }
    }];
}

#pragma mark - Private Menthod
- (BOOL)p_isSupportTouchID{
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"系统版本不支持TouchID (必须高于iOS 8.0才能使用)");
        });
        return NO;
    }
    
    LAContext *context = [[LAContext alloc]init];
    NSError *error = nil;
    return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
}

- (void)p_touchIdIsLocked{
    [_context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"验证密码" reply:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"验证成功");
            // 把本地标识改为NO，表示指纹解锁解除锁定
            [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"touchIdIsLocked"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
            NSLog(@"验证失败");
        }
    }];
}


#pragma mark - Setter && Getter
- (LAContext *)context{
    if (!_context) {
        _context = [[LAContext alloc]init];
        _context.localizedFallbackTitle = @"";
    }
    return _context;
}

@end


