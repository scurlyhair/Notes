# URLSessionConfiguration

URLSessionConfiguration 用于定义 URLSession 的行为和策略。

**URLSession 的 Configuration 一旦被指定就不能再做修改。**如果要修改 Configuration 需要创建新的 URLSession。

> 在某些情况下，Configuration 中配置的策略可能会被其中的某个任务重写，因为任务的策略的优先级更高。除非 Configuration 中的策略更加严格。比如 Configuration 中不允许使用蜂窝网络，那么即使任务策略允许，这个请求也不能使用蜂窝网络。

根据 Configuration 可以将 Session 配置为三种类型：

- .default 默认的配置。
- .ephemeral 跟 Default 相比它不会将缓存、cookies、凭据写入磁盘。
- .background 这种模式允许你的应用程序在未启动或者挂起的时候，在后台执行一些上传或者下载的任务。

## 基本属性

```swift
var identifier: String? { get }
```

只在 .background 模式下有效。它唯一标识一个后台 Session，当应用程序被重新启动的时候，会通过 identifier 创建相应的 session 来继续完成网络请求。

```swift
var httpAdditionalHeaders: [AnyHashable : Any]? { get set }
```

用于自定义 headers 信息。

URLSession 可以根据需要自动生成一些 headers 信息，比如：

- Authorization
- Connection
- Host
- Proxy-Authenticate
- Proxy-Authorization
- WWW-Authenticate

```swift
var networkServiceType: NSURLRequest.NetworkServiceType { get set }

public enum NetworkServiceType : UInt {
    case `default` = 0 // Standard internet traffic
    case video = 2 // Video traffic
    case background = 3 // Background traffic
    case voice = 4 // Voice data
    case responsiveData = 6 // Responsive data
    case avStreaming = 8 // Multimedia Audio/Video Streaming
    case responsiveAV = 9 // Responsive Multimedia Audio/Video
    case callSignaling = 11 // Call Signaling
}
```

通过准确设置此属性，可以帮助操作系统决定程序使用的流量的方式以及唤醒蜂窝网络或者 Wifi 的速率。从而在电池寿命、性能或其他指标之间取得平衡。

```swift
var allowsCellularAccess: Bool { get set }
```

允许使用蜂窝网络。默认 true。

```swift
var timeoutIntervalForRequest: TimeInterval { get set }
```

请求超时时间（秒）。如果超过指定时间没有接收到新的数据，则超时。如果中途收有新的数据进来，那么重置计时。默认 60 秒。

> Background 模式的 Session 在上传或者下载过程中如果超时，会自动重试。此时通过修改 timeoutIntervalForResource 来调整最大请求时长。

```swift
var timeoutIntervalForResource: TimeInterval { get set }
```

资源请求可以花费的最大总时长。默认是 7 天。

```swift
var sharedContainerIdentifier: String? { get set }
```

App Extension 和 主 APP 之间的 container 识别号。

```swift
var waitsForConnectivity: Bool { get set }
```

等待网络可用或直接返回失败。某些情况可能会导致网络暂时不可用，比如当前设备只有蜂窝网络，但网络任务的 allowsCellularAccess 被设置为 false。或者设备使用 vpn 但 vpn 服务器没有相应。在这些情况下，如果 waitsForConnectivity 设置为 true，Session 会调用 URLSessionTaskDelegate 的 `urlSession(_:taskIsWaitingForConnectivity:) ` 函数并等待重新连接。如果 waitsForConnectivity 是设置为 false，则会直接抛出诸如 NSURLErrorNotConnectedToInternet 错误。

这个属性只跟建立连接有关系，如果建立连接之后才发生网络请求中断，则会抛出 NSURLErrorNetworkConnectionLost 错误。

另外，此属性在 background Session 时失效，因为这种情况下，网络任务总是等待重新连接。

## Cookies 策略

```swift
var httpCookieAcceptPolicy: HTTPCookie.AcceptPolicy { get set }
public enum AcceptPolicy : UInt {
    case always = 0
    case never = 1
    case onlyFromMainDocumentDomain = 2
}
```

使用的 Cookies 策略。默认 onlyFromMainDocumentDomain。

如果需要更精确地去控制哪些 cookies 被接受的话，将这个属性设置为 never，然后使用 allHeaderFields 和 cookies(withResponseHeaderFields:for:) 方法来从指定的 URL response 中检出 cookies。

```swift
var httpShouldSetCookies: Bool { get set }
```

否自动包含 cookies 共享储存中心提供的 cookies。默认 true。

如果要使用自定义的 Cookies 的话可以将此属性设置为 false，并通过以下两种方式来实现：

- 在 httpAdditionalHeaders 中额皮质
- 自定义 URLRequest 

```swift
var httpCookieStorage: HTTPCookieStorage? { get set }
```

此属性中存放了使用当前 Session 的发起请求的 Cookies，如果要禁用 Cookies 储存，将此属性设置为 nil。

- 对于 Default 和 Background 类型的 Session，默认值是共享Cookies 储存对象。
- 对于 Ephemeral 类型的 Session，是默认储存在内存空间中的私有 Cookies 储存对象，当 session 销毁的时候，也一并销毁。

## 安全策略

```swift
var tlsMinimumSupportedProtocolVersion: tls_protocol_version_t { get set }
```

支持的最小 TLS 协议版本

```swift
var tlsMaximumSupportedProtocolVersion: tls_protocol_version_t { get set }
```

支持的最大 TLS 协议版本

```swift
var urlCredentialStorage: URLCredentialStorage? { get set }
```

凭证储存对象。 如果要禁用凭证储存，将此属性设置为 nil。

同 httpCookieStorage 一样。

- 对于 Default 和 Background 类型的 Session，默认值是共享Credential 储存对象。
- 对于 Ephemeral 类型的 Session，是默认储存在内存空间中的私有 Credential 储存对象，当 session 销毁的时候，也一并销毁。

## 缓存

```swift
var urlCache: URLCache? { get set }
```

Cache 储存对象。如果要禁用缓存，将此属性设置为 nil。

- 对于 Default 类型的 Session 默认值是共享 URL 缓存
- 对于 Background 类型的 Session，默认值是 nil
- 对于 Ephemeral 类型的 Session 默认值是储存在内存空间中的私有 Cache 储存对象，当 session 销毁时，也一并销毁。

```swift
var requestCachePolicy: NSURLRequest.CachePolicy { get set }
public enum CachePolicy : UInt {
    case useProtocolCachePolicy = 0 // 使用协议中定义的缓存逻辑
    case reloadIgnoringLocalCacheData = 1 // 忽略本地缓存，只从远端拉取内容
    case reloadIgnoringLocalAndRemoteCacheData = 4 // 在协议允许的范围内，忽略本地缓存数据，并指示代理和其他中间产品忽略其缓存。
    case returnCacheDataElseLoad = 2 // 如果有缓存则使用缓存，即是已经过期，否则从远端拉取数据
    case returnCacheDataDontLoad = 3 // 如果有缓存则使用缓存，即使已经过期，没有缓存也不从远端拉取数据
    case reloadRevalidatingCacheData = 5 // 如果本地缓存通过远端验证，则加载缓存，否则从远端拉取数据
}
```

用来决定何时使用 Cache 来返回相应的 Response。默认值是 useProtocolCachePolicy。

## 后台传输支持

```swift
var sessionSendsLaunchEvents: Bool { get set }
```

当后台下载任务完成时，是否在后台启动或者唤醒 APP。默认值是 true。

当此属性被设置为 true 时，如果后台下载任务完成，系统会在后台自动唤醒或者启动 APP。此时 系统会调用应用程序 APPDelegate中的 application(_:handleEventsForBackgroundURLSession:completionHandler:) 函数。如果应用是被重新启动，你可以使用此函数中提供的 indentifier 创建新的 Session 对象来完成后续任务。

参考链接：

- [https://developer.apple.com/documentation/foundation/urlsessionconfiguration#1660412](https://developer.apple.com/documentation/foundation/urlsessionconfiguration#1660412)