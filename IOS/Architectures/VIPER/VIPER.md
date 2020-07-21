# VIPER 架构分析

VIPER 是一种 IOS 架构模式，可以看做是 MVC 架构模式的拆解或优化探索。

[Architecting iOS Apps with VIPER](https://www.objc.io/issues/13-architecture/viper/) 给出了 VIPER 的设计原理和实践案例： [https://github.com/objcio/issue-13-viper](https://github.com/objcio/issue-13-viper) 。

译文： [使用 VIPER 构建 iOS 应用](https://objccn.io/issue-13-5/)

接下来我们会结合上面的文章以及案例对 VIPER 这个架构进行一些其他角度的分析和探索。

## 架构模型

VIPER 的五个字母分别指代 View、Interactor、Presenter、Eneity 以及 Router。

实际上 Router 是一个抽象概念， 它由 Presenter 和 Wireframe 协作实现：

 - Presenter 确定路由发生的时机、方式和目标
 - Wireframe 执行路由以及动画

> Wireframe（线框）负责展示组件（ViewController）的组织和呈现。

因此，一个业务模块实际上是由 ViewController、Interactor、Presenter、Entity、Wireframe 配合其他服务组件实现的。

VIPER 的架构与三层架构模型之间的关系是这样的：

![VIPER_01](VIPER_01.png)

## 协作逻辑

文章中给出的 VIPER 架构中各组件之间的结构关系如下：

![VIPER_02](VIPER_02.png)

那到底是不是这样子呢？

下面我们结合案例代码对它们之间的协作关系进行分析。

### Entity

Entity 是一个纯数据结构。用于 Interactor 跟数据服务组件进行数据交换。

```objc
@interface VTDTodoItem : NSObject

@property (nonatomic, strong)   NSDate*     dueDate;
@property (nonatomic, copy)     NSString*   name;

+ (instancetype)todoItemWithDueDate:(NSDate *)dueDate name:(NSString *)name;

@end
```

### Interactor 

Interactor 负责实现业务逻辑。它只与 Presenter 进行交互。

 - 响应 Presenter 的数据拉取消息，并向其提交数据
 - 响应 Presenter 的业务逻辑消息，并向其提交执行结果

```objc
@interface VTDListInteractor : NSObject <VTDListInteractorInput>

// Presenter
@property (nonatomic, weak)     id<VTDListInteractorOutput> output;

- (instancetype)initWithDataManager:(VTDListDataManager *)dataManager clock:(id<VTDClock>)clock;

@end
```

> 案例中模块的数据服务由一个叫 DataManager 的组件进行管理，直接跟 Interactor 交互。


### Presenter

Presenter 跟其它组件的交互最多，负责将视图、路由、业务整合在一起。

 - 向 View 派发数据
 - 处理 View 产生的用户操作事件
 - 告诉 Wireframe 执行路由
 - 向 Interactor 提交数据拉取消息，并处理返回值/回调
 - 向 Interactor 提交业务调用消息，并处理回调


```objc
@interface VTDListPresenter : NSObject <VTDListInteractorOutput, VTDListModuleInterface, VTDAddModuleDelegate>

// Interactor
@property (nonatomic, strong) id<VTDListInteractorInput>    listInteractor;

// Wireframe
@property (nonatomic, strong) VTDListWireframe*             listWireframe;

// ViewController
@property (nonatomic, strong) UIViewController<VTDListViewInterface> *userInterface;

@end
```




### View

View 包括 UIViewController 和 UIView 的派生类。主要是 ViewController 跟其他组件进行交互。

- 展示 Presenter 下发的数据
- 将用户发生的操作事件提交到 Presenter

```objc
@interface VTDListViewController : UITableViewController <VTDListViewInterface>

@property (nonatomic, strong) IBOutlet UIView*              noContentView;

// Presenter
@property (nonatomic, strong) id<VTDListModuleInterface>    eventHandler;

@end
```

### Wireframe

Wireframe 负责路由的具体实现和。

- 产生 ViewController 实例
- 为 ViewController 提供 Presenter 实例
- 为 Presenter 提供 ViewController 实例
- 完成页面呈现
- 完成页面呈现动画

```objc
@interface VTDListWireframe : NSObject

// 子 Wireframe
@property (nonatomic, strong) VTDAddWireframe *addWireframe;

// Presenter
@property (nonatomic, strong) VTDListPresenter *listPresenter;

// 根 Wireframe
@property (nonatomic, strong) VTDRootWireframe *rootWireframe;

- (void)presentListInterfaceFromWindow:(UIWindow *)window;
- (void)presentAddInterface;

@end
```

Wireframe 实际上还保存了 ViewController 的实例：

```objc
@interface VTDListWireframe ()

@property (nonatomic, strong) VTDListViewController *listViewController;

@end
```

### 初始化

在应用启动阶段会进行路由组件初始化：

```objc
// AppDelegate
@interface VTDAppDelegate ()

@property (nonatomic, strong) VTDAppDependencies *dependencies;

@end

@implementation VTDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 初始化路由组件
    VTDAppDependencies *dependencies = [[VTDAppDependencies alloc] init];
    self.dependencies = dependencies;
    
    [self.dependencies installRootViewControllerIntoWindow:self.window];
    
    return YES;
}

@end
```

这个过程对项目中所有模块的 Wireframe、Presenter、Interactor（以及DataManager）组件进行初始化，从而完成路由的注册。

```objc
// VTDAppDependencies 中的相关代码

// 初始化组件
VTDListWireframe *listWireframe = [[VTDListWireframe alloc] init];
VTDListPresenter *listPresenter = [[VTDListPresenter alloc] init];
VTDListDataManager *listDataManager = [[VTDListDataManager alloc] init];
VTDListInteractor *listInteractor = [[VTDListInteractor alloc] initWithDataManager:listDataManager clock:clock];

// 关系绑定
listInteractor.output = listPresenter;
listPresenter.listInteractor = listInteractor;
listPresenter.listWireframe = listWireframe;

listWireframe.addWireframe = addWireframe;
listWireframe.listPresenter = listPresenter;
listWireframe.rootWireframe = rootWireframe;

self.listWireframe = listWireframe;
```

> 而 View 是在真正进行路由跳转的时候才实例化。

### 小结

Presenter 和 Interactor 之间通过协议实现低耦合。

Presenter 和 View 之间也是通过协议实现低耦合。


通过上面的分析可以看到，VIPER 各组件之间的结构关系其实是这样的：

![VIPER_03](VIPER_03.png)

VIPER 架构的整体实现逻辑如下：

1. App 启动时初始化路由组件
	- 完成 Wireframe、Presenter、Interactor 的初始化
	- 进行 Presenter 和 Interactor 关系绑定
	- 进行 Presenter 和 Wireframe 关系绑定
	- 进行 Wireframe 之间的路由关系绑定
2. 呈现页面
	- 进行 View 的初始化
	- 进行 Presenter 和 View 之间的关系绑定
	- 完成路由跳转
3. 拉取展示数据
	- View 向 Presenter 索要数据
	- Presenter 向 Interactor 索要数据
	- Interactor 从 DataManager 获取到数据并提交给 Presenter
	- Presenter 将数据派发到 View 进行展示
4. 捕捉用户交互事件呈现指定页面
	- View 捕获到交互事件将其传递给 Presenter
	- Presenter 根据交互事件的内容决定让 Interactor 执行指定业务或者让 Wireframe 进行路由跳转


参考链接：

- [Architecting iOS Apps with VIPER](https://www.objc.io/issues/13-architecture/viper/)
- [使用 VIPER 构建 iOS 应用](https://objccn.io/issue-13-5/)