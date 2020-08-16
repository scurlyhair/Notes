# URLSession

URLSession 用于进行网络请求中请求任务和数据传输的管理。

## URLSession 类型

我们使用 URLSessionConfiguration 来初始化一个 session。

根据 Configuration 可以将 Session 配置为三种类型：

- .default 默认的配置。
- .ephemeral 跟 Default 相比它不会将缓存、cookies、凭据写入磁盘。
- .background 这种模式允许你的应用程序在未启动或者挂起的时候，在后台执行一些上传或者下载的任务。

对于自定义需求不高的网络请求，可以直接使用系统提供的 URLSession.shared 单例来完成。

## URLSessionTask 类型

每一个网络请求都对应于 session 中的一个 Task。URLSession 支持以下任务类型：

- 基于请求-响应模式的网络请求，比如普通的服务端 API 交互。
- 大文件上传下载任务。
- 基于 TCP 和 TLS 的 WebSocket 任务。

## Session Delegate

在 URLSession 初始化的方法中，我们可以传入一个 Delegate 以实现在网络请求不同时机的自定义处理。比如：

- 认证失败时
- 从服务端接收到信息时
- 当数据可以进行缓存时

> session 会强引用 Delegate。当一个 session 已经不再使用时需要进行手动释放，以避免内存泄露。
> 
> ```swift
> // 完成当前在进行的任务并释放 session。
> func finishTasksAndInvalidate()
> // 取消当前在进行的任务并释放 session
> func invalidateAndCancel()
> // 取消 session 会触发其 Delegate 调用以下函数
> optional func urlSession(_ session: URLSession,  didBecomeInvalidWithError error: Error?)
> ```
> 
> 取消函数在 URLSession.shared 单例中无效。


##  线程安全

URLSession 的 API 是线程安全的。session 和 task 可以在创建于任何线程的执行上下文。其代理会在正确的 DelegateQueue 中被执行。

参考链接：

- [https://developer.apple.com/documentation/foundation/urlsession](https://developer.apple.com/documentation/foundation/urlsession)

