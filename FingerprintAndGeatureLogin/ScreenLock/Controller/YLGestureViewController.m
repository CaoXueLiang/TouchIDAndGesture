//
//  YLGestureViewController.m
//  CoreLock
//
//  Created by 成林 on 15/4/21.
//  Copyright (c) 2015年 冯成林. All rights reserved.
//

#import "YLGestureViewController.h"
#import "CoreLockConst.h"
#import "CLLockView.h"
#import "CoreConst.h"

@interface YLGestureViewController ()<UIAlertViewDelegate>

/** 操作成功：密码设置成功、密码验证成功 */
@property (nonatomic,copy) void (^successBlock)(YLGestureViewController *lockVC,NSString *pwd);
///手势设置引导跳过按钮时间
@property (nonatomic,copy) void (^skipBlock)(YLGestureViewController *lockVC);
///其他账号登录
@property (nonatomic,copy) void (^otherLoginBlock)(YLGestureViewController *lockVC);
@property (nonatomic,copy) void (^forgetPwdBlock)(void);
@property (nonatomic,copy) void (^backBtnBlock)(void);



@property (nonatomic,copy) NSString *msg;

@property (weak, nonatomic) IBOutlet CLLockView *lockView;

@property (nonatomic,weak) UIViewController *vc;

@property (nonatomic,strong) UIBarButtonItem *resetItem;
@property (nonatomic,strong) UIBarButtonItem *skipItem;


@property (nonatomic,copy) NSString *modifyCurrentTitle;


@property (weak, nonatomic) IBOutlet UIView *actionView;

@property (weak, nonatomic) IBOutlet UIButton *modifyBtn;

@property (nonatomic, assign)CoreLockShowType showType;


/** 直接进入修改页面的 */
@property (nonatomic,assign) BOOL isDirectModify;



@property (nonatomic, assign) NSInteger maxFailCount;


@end

@implementation YLGestureViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.maxFailCount = 4;
    
    //控制器准备
    [self vcPrepare];
    
    //数据传输
    [self dataTransfer];
    
    //事件
    [self event];
    [self createNavigationButton];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (self.hiddenBackButton) {
		if (self.navigationController) {
			self.navigationController.interactivePopGestureRecognizer.enabled = NO;
		}
	}
	
}

-(void)createNavigationButton
{
	if (!self.hiddenBackButton) {
//        @weakify(self);
//        [self setNavigationCommonLeftBtnWithBlock:^(id sender) {
//            if(weakSelf.backBtnBlock)
//            {
//                weakSelf.backBtnBlock();
//            }
//            if (weakSelf.navigationController) {
//                [weakSelf.navigationController popViewControllerAnimated:YES];
//            } else {
//                [weakSelf dismissViewControllerAnimated:YES completion:nil];
//            }
//        }];
//    } else {
//        [self setupNavLeftBtnWithTitle:@"" block:^(id sender) {
//
//        }];
	}
	
}
/*
 *  事件
 */
-(void)event{
    
    __weak typeof(self) weakSelf = self;
    /*
     *  设置密码
     */
    
    /** 开始输入：第一次 */
    self.lockView.setPWBeginBlock = ^(){
        
        [weakSelf.label showNormalMsg:CoreLockPWDTitleFirst];
    };
    
    /** 开始输入：确认 */
    self.lockView.setPWConfirmlock = ^(){
        
        [weakSelf.label showNormalMsg:CoreLockPWDTitleConfirm];
    };
    
    
    /** 密码长度不够 */
    self.lockView.setPWSErrorLengthTooShortBlock = ^(NSUInteger currentCount){
      
        [weakSelf.label showWarnMsg:[NSString stringWithFormat:@"请连接至少%@个点，请重新绘制",@(CoreLockMinItemCount)]];

    };
    
    /** 两次密码不一致 */
    self.lockView.setPWSErrorTwiceDiffBlock = ^(NSString *pwd1,NSString *pwdNow){
        
        [weakSelf.label showWarnMsg:CoreLockPWDDiffTitle];
        
        weakSelf.navigationItem.rightBarButtonItem = weakSelf.resetItem;
    };
    
    /** 第一次输入密码：正确 */
    self.lockView.setPWFirstRightBlock = ^(){
      
        [weakSelf.label showNormalMsg:CoreLockPWDTitleConfirm];

    };
    
    /** 再次输入密码一致 */
    self.lockView.setPWTwiceSameBlock = ^(NSString *pwd){
      
        [weakSelf.label showNormalMsg:CoreLockPWSuccessTitle];
        
        //禁用交互
        weakSelf.view.userInteractionEnabled = NO;
        
        if(_successBlock != nil) {
            _successBlock(weakSelf,pwd);
        }
        
        if(CoreLockTypeModifyPwd == _type){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
    };
    
    
    
    /*
     *  验证密码
     */
    
    /** 开始 */
    self.lockView.verifyPWBeginBlock = ^(){
        
        [weakSelf.label showNormalMsg:CoreLockVerifyNormalTitle];
    };
    
    /** 验证 */
    self.lockView.verifyPwdBlock = ^(NSString *pwd){
    
        if (!weakSelf.lockView.isOldPwdVerifySuccess)
        {
            [weakSelf verifyGesturePassword:pwd withBlock:^(BOOL isSuccess) {
                if (isSuccess)
                {
                    [weakSelf.label showNormalMsg:CoreLockVerifySuccesslTitle];
                    
                    if(CoreLockTypeVeryfiPwd == _type){
                        
                        //禁用交互
                        weakSelf.view.userInteractionEnabled = NO;
                        
                    }else if (CoreLockTypeModifyPwd == _type){//修改密码
                        
                        [weakSelf.label showNormalMsg:CoreLockPWDTitleFirst];
                        
                        weakSelf.modifyCurrentTitle = CoreLockPWDTitleFirst;
                    }
                    
                    if(CoreLockTypeVeryfiPwd == _type || CoreLockTypeScreenLoaker == _type) {
                        if(_successBlock != nil) {
                            _successBlock(weakSelf,pwd);
                        }
                    }
                    
                }
                else
                {
                    [weakSelf.label showWarnMsg:CoreLockVerifyErrorPwdTitle];
                }
                
                weakSelf.lockView.isOldPwdVerifySuccess = isSuccess;
            }];
        }
        else
        {
            //触发状态判断，调用设置密码
            weakSelf.lockView.isOldPwdVerifySuccess = YES;
        }
        //取出本地密码
//        NSString *pwdLocal = CurrentUser.userModel.gesturePassword;
//
//        BOOL res = [pwdLocal isEqualToString:pwd];
//
//        if(res){//密码一致
//
//
//        }else{//密码不一致
//
//        }
        
//        return res;
    };
    
    /** 验证 */
    self.lockView.screenLoakerBlock = ^(NSString *pwd){
        
        //取出本地密码
        NSString *pwdLocal = @"";
        //CurrentUser.gesturePassword;
        
        BOOL res = [pwdLocal isEqualToString:pwd];
        
        if(res){//密码一致
            
            [weakSelf.label showNormalMsg:CoreLockVerifySuccesslTitle];
            
            if(CoreLockTypeVeryfiPwd == _type){
                
                //禁用交互
                weakSelf.view.userInteractionEnabled = NO;
                
            }else if (CoreLockTypeModifyPwd == _type){//修改密码
                
                [weakSelf.label showNormalMsg:CoreLockPWDTitleFirst];
                
                weakSelf.modifyCurrentTitle = CoreLockPWDTitleFirst;
            }
            
            if(CoreLockTypeVeryfiPwd == _type || CoreLockTypeScreenLoaker == _type) {
                if(_successBlock != nil) {
                    _successBlock(weakSelf,pwd);
                }
            }
            
        }else{//密码不一致
            if(CoreLockTypeScreenLoaker == _type)
            {
                if (_successBlock)
                {
                    _successBlock(weakSelf,pwd);
                }
            }
            else
            {
                self.maxFailCount--;
                
                if (self.maxFailCount == 0) {
//                    // 直接登出
//                    [[NSNotificationCenter defaultCenter] postNotificationName:kYLLogoutNotification object:nil];
//
                    [weakSelf dismiss:1];
                } else {
                    [weakSelf.label showWarnMsg:[NSString stringWithFormat:@"您还有%ld次机会",(long)self.maxFailCount]];
                }
            }
        }
        
        return res;
    };
    
    
    /*
     *  修改
     */
    
    /** 开始 */
    self.lockView.modifyPwdBlock =^(){
      
        [weakSelf.label showNormalMsg:weakSelf.modifyCurrentTitle];
    };
    
    
}

/*
 *  数据传输
 */
-(void)dataTransfer{
    
    [self.label showNormalMsg:self.msg];
    //传递类型
    self.lockView.type = self.type;
}

/*
 *  控制器准备
 */
-(void)vcPrepare{

    //设置背景色
    self.view.backgroundColor = CoreLockViewBgColor;
    
    //默认标题
    self.modifyCurrentTitle = CoreLockModifyNormalTitle;
    
    _actionView.hidden = YES;//暂时先隐藏底部菜单
    
    if(CoreLockTypeModifyPwd == _type) {
        _actionView.hidden = NO;
    }
    
    if(CoreLockTypeScreenLoaker == _type) {
        _loginBtn.hidden = NO;
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
//        self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    }
    
    if (self.showType == CoreLockTypePresent) {
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    }

    
    if (_isFirstLogin){
        _loginBtn.hidden = NO;
	 	[_loginBtn setTitle:@"跳过此步骤" forState:UIControlStateNormal];
    }
}

-(void)dismiss{
    [self dismiss:0];
}
-(void)skipAct
{
    if (_skipBlock)
    {
        _skipBlock(self);
    }
}

/*
 *  密码重设
 */
-(void)setPwdReset{
    
    [self.label showNormalMsg:CoreLockPWDTitleFirst];

    //隐藏
    self.navigationItem.rightBarButtonItem = nil;
    
    //通知视图重设
    [self.lockView resetPwd];
}

/*
 *  忘记密码
 */
-(void)forgetPwd{
    
}

/*
 *  修改密码
 */
-(void)modiftyPwd{
    
}

/*
 *  是否有本地密码缓存？即用户是否设置过初始密码？
 */
+(BOOL)hasPwd{
    return YES;
    //CurrentUser.gestureEnable;
}

/*
 *  展示设置密码控制器
 */
+(instancetype)showSettingLockVCInVC:(UIViewController *)vc showType:(CoreLockShowType)showType successBlock:(void(^)(YLGestureViewController *lockVC,NSString *pwd))successBlock backBtnActBlock:(void(^)(void)) backBtnAct
{
    
    YLGestureViewController *lockVC = [self lockVC:vc showType:showType];
    lockVC.showType = showType;
    lockVC.title = @"设置手势密码";
    
    //设置类型
    lockVC.type = CoreLockTypeSetPwd;
    
    //保存block
    lockVC.successBlock = successBlock;
    lockVC.backBtnBlock = backBtnAct;
    return lockVC;
}

/*
 *  展示验证密码输入框
 */
+(instancetype)showVerifyLockVCInVC:(UIViewController *)vc showType:(CoreLockShowType)showType forgetPwdBlock:(void(^)(void))forgetPwdBlock successBlock:(void(^)(YLGestureViewController *lockVC, NSString *pwd))successBlock{
    
    
    YLGestureViewController *lockVC = [self lockVC:vc showType:showType];
    lockVC.showType = showType;

    lockVC.title = @"手势解锁";
    
    //设置类型
    lockVC.type = CoreLockTypeVeryfiPwd;
    
    //保存block
    lockVC.successBlock = successBlock;
    lockVC.forgetPwdBlock = forgetPwdBlock;
    
    return lockVC;
}

/*
 *  展示验证密码输入框
 */
+(instancetype)showModifyLockVCInVC:(UIViewController *)vc showType:(CoreLockShowType)showType successBlock:(void(^)(YLGestureViewController *lockVC, NSString *pwd))successBlock{
    
    YLGestureViewController *lockVC = [self lockVC:vc showType:showType];
    lockVC.showType = showType;

    lockVC.title = @"修改密码";
    
    //设置类型
    lockVC.type = CoreLockTypeModifyPwd;
    
    //记录
    lockVC.successBlock = successBlock;
    
    return lockVC;
}

/*
 *  展示应用启动屏幕锁
 */
+(instancetype)showScreenLockVCInVC:(UIViewController *)vc showType:(CoreLockShowType)showType successBlock:(void(^)(YLGestureViewController *lockVC, NSString *pwd))successBlock  otherLoginBlcok:(void(^)(YLGestureViewController *lockVC))otherLoginBlock
{
    
    
    __block YLGestureViewController *lockVC = [self lockVC:vc showType:showType];
//    [lockVC setupNavLeftBtnWithTitle:@"取消" block:^(id sender) {
//        [lockVC.navigationController dismissViewControllerAnimated:YES
//                                                          completion:nil];
//    }];
    
    lockVC.showType = showType;
    lockVC.title = @"手势密码登录";
    
    //设置类型
    lockVC.type = CoreLockTypeScreenLoaker;
    //记录
    lockVC.successBlock = successBlock;
    lockVC.otherLoginBlock = otherLoginBlock;
    
    return lockVC;
}


+ (instancetype)lockVC:(UIViewController *)vc showType:(CoreLockShowType)showType hiddenBackButton:(BOOL)hidden{
	
	YLGestureViewController *lockVC = [[YLGestureViewController alloc] init];
	lockVC.showType = showType;
	lockVC.hiddenBackButton = hidden;
	
	lockVC.vc = vc;
	
	
	switch (showType) {
		case CoreLockTypePush: {
			[vc.navigationController pushViewController:lockVC animated:YES];
			break;
		}
		case CoreLockTypePresent: {
			UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:lockVC];
			[vc presentViewController:navVC animated:NO completion:nil];
			break;
		}
			
		default:
			break;
	}
	return lockVC;
}


+(instancetype)lockVC:(UIViewController *)vc showType:(CoreLockShowType)showType{
  return [self lockVC:vc showType:showType hiddenBackButton:NO];
}

-(void)setType:(CoreLockType)type{
    
    _type = type;
    
    //根据type自动调整label文字
    [self labelWithType];
}

/*
 *  根据type自动调整label文字
 */
-(void)labelWithType{
    
    if(CoreLockTypeSetPwd == _type){//设置密码
        
        self.msg = CoreLockPWDTitleFirst;
        
    }else if (CoreLockTypeVeryfiPwd == _type){//验证密码
        
        self.msg = CoreLockVerifyNormalTitle;
        
    }else if (CoreLockTypeModifyPwd == _type){//修改密码
        
        self.msg = CoreLockModifyNormalTitle;
    }else if (CoreLockTypeScreenLoaker == _type){//修改密码
        self.msg = CoreLockVerifyNormalTitle;
    }
}

/*
 *  消失
 */
-(void)dismiss:(NSTimeInterval)interval{
    
    switch (self.showType) {
        case CoreLockTypePush: {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case CoreLockTypePresent: {
            [self dismissViewControllerAnimated:NO completion:nil];
            break;
        }
            
        default:
            break;
    }
}

/*
 *  重置
 */
-(UIBarButtonItem *)resetItem{
    
    if(_resetItem == nil){
        //添加右按钮
        _resetItem= [[UIBarButtonItem alloc] initWithTitle:@"重设" style:UIBarButtonItemStylePlain target:self action:@selector(setPwdReset)];
        [_resetItem setTintColor:[UIColor whiteColor]];
    }
    
    return _resetItem;
}
-(UIBarButtonItem *)skipItem
{
    if(_skipItem == nil){
        //添加跳过按钮
        _skipItem= [[UIBarButtonItem alloc] initWithTitle:@"跳过" style:UIBarButtonItemStylePlain target:self action:@selector(skipAct)];
        [_skipItem setTintColor:[UIColor whiteColor]];
    }
    
    return _skipItem;
}

- (IBAction)modifyPwdAction:(id)sender {
    
    YLGestureViewController *lockVC = [[YLGestureViewController alloc] init];
    
    lockVC.title = @"修改密码";
    
    lockVC.isDirectModify = YES;
    
    //设置类型
    lockVC.type = CoreLockTypeModifyPwd;
    
    [self.navigationController pushViewController:lockVC animated:YES];
}
- (IBAction)loginByAccount:(id)sender {
    if (_isFirstLogin)
    {
        [self skipAct];
    }
    else
    {
        [self dismiss];
        if (_otherLoginBlock)
        {
            _otherLoginBlock(self);
        }
    }
    
    
}

#pragma mark- delegate alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex != alertView.cancelButtonIndex) {
//        //清空手势
//        CurrentUser.gestureEnable = NO;
//        CurrentUser.gesturePassword = @"";
//        
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.label.text = @"已登出";
//        [hud hideAnimated:YES afterDelay:0.5];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kYLLogoutNotification object:nil];
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
}

#pragma mark - 手势密码设置
-(void)setGesturePassword:(NSString *)pwd resultBlock:(void(^)(BOOL isSuccess,NSError *error)) resBlock
{
    resBlock(YES,nil);
}

#pragma mark - 手势密码登录验证
-(void)varifyGesturePwd:(NSString *)gesPwd resultBlock:(void(^)(BOOL isSuccess,NSString *errorMsg)) block
{
    block(YES,nil);
    
}
//手势密码修改时验证
- (void)verifyGesturePassword:(NSString *)pwd withBlock:(void(^)(BOOL isSuccess)) block
{
    block(YES);
}


@end
