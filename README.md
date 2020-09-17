# KScrollViewFramework
分页滚动展示视图

特点：
     
     Swift语言封装，使用链式编程思想进行创建，使代码更加优雅！
  
     你可以根据需要对其样式进行自定义设置。
  
     OC和Swift都可使用，OC使用时候需要进行桥接。
  
cocoapod使用：

    platform :ios, '13.0'
    target 'xxxx-DemoName' do
      use_frameworks!
      pod 'KScrollViewFramework'
    end
  
公共接口API：

    1⃣️实例化接口
    K_ShareInitView(_ blcokView:(KScrollview) -> Void) -> KScrollview     // 返回值可有可无，链式编程的一种特性

    2⃣️获取数据接口
    getData(_ dataArray: [UIImage]) -> KScrollview                        // 返回值可有可无，链式编程的一种特性

    3⃣️代理方法接口
    didSelectItem(index:Int) -> Void                                      // 选中时响应对应item

配置属性接口：
    
    K_MakeDelegate                        // 代理
    K_MakeFrame                           // 设置坐标位置
    K_MakeSuperView                       // 添加到父视图上
    K_MakeItem_heiht                      // 图片高度
    K_MakeMarginDistanDce_LeftAndRight    // 边缘左右距离
    K_MakeMarginDistanDce_TopAndBottom    // 边缘上下距离
    K_MakeMargin_BGColor                  // 边缘背景颜色
    K_MakeBorder_width                    // 边框宽度
    K_MakeBorder_color                    // 边框颜色
    K_MakePage_Tintcolor                  // 标点背景颜色
    K_MakePage_CurrentTintColor           // 当前标点显示颜色
    K_MakePage_BottomMarginDistanDce      // 标点视图距离下边沿的距离
    K_MakeSAnimation                      // 是否有动画
    K_MakeAnimationEstimate               // 动画幅度系数 0~1之间
    K_MakeIsAutoScroll                    // 是否自动滚动
    K_MakeTimeInterval                    // 滚动间隔时间（秒:s）

swift语言调用【现实例化并配置属性，再进行绑定数据】
    
    // 导入头文件
    import KScrollViewFramework               

    // 实例化对象（及其设置属性）
    let kScrollview = KScrollview.K_ShareInitView { (make) in
                           make.K_MakeFrame(CGRect(x: 0, y: kScaleWidth(100), width: KScreen_Width, height: kScaleWidth(220)))
                           .K_MakeSuperView(self.view)
                           .K_MakeItem_heiht(160)                      // 视图内容（图片）高度
                           .K_MakeMarginDistanDce_LeftAndRight(10)     // 左右边距
                           .K_MakeMarginDistanDce_TopAndBottom(5)      // 上下边距
                           .K_MakeBorder_color(.black)                 // 边框颜色
                           .K_MakeMargin_BGColor(.yellow)              // 边沿背景颜色
                           .K_MakeIsAnimation(true)                    // 滚动视图动画：fales无动画，true有动画
                           .K_MakeDelegate(self)                       // 代理方法
                           .K_MakeAnimationEstimate(0.3)               // 动画幅度系数0～1
                   }
        
    // 获取绑定数据源
    kScrollview.getData(imgArray)
  
OC语言调用【现实例化并配置属性，再进行绑定数据】
    
    // 导入头文件
    #import <KScrollViewFramework-Swift.h>

    // 实例化对象（及其设置属性）
    KScrollview *kScrollview = [KScrollview K_ShareInitView:^(KScrollview * _Nonnull make) {
        [make K_MakeFrame:CGRectMake(0, 180, self.view.frame.size.width, 160)];
        [make K_MakeSuperView:self.view];
        [make K_MakeIsAnimation:false];
        [make K_MakeItem_heiht:150];
        [make K_MakeMarginDistanDce_TopAndBottom:5];
        [make K_MakeMargin_BGColor:[UIColor whiteColor]];
        [make K_MakeMarginDistanDce_LeftAndRight:10];
    }];

    // 获取绑定数据源
    [kScrollview getData:dataArray];
  
  OC使用Swift第三方库的桥接的三个步骤：

    1、创建.h文件，名为“工程名-Bridging-Header.h”；

    2、在Build Setting配置两个值： 

           1⃣️设置Defines Module 为Yes； 
       
           2⃣️设置Product Module Name 为当前工程名 (有时系统会自动为我们设置好)；

    3、导入一个头文件“工程名-Swift.h”就可以使用了，如：#import <KProgressFramework-Swift.h>。
