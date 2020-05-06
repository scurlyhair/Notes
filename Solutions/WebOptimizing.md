# WKWebView性能优化

## 1. 加载过程

1. 捕捉到`navigation`，触发回调

```swift
// Decides whether to allow or cancel a navigation
optional func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
```
 
2. 开始加载

```swift
// Called when web content begins to load in a web view.
optional func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
```

<!--![webOptimizing_0](webOptimizing_0.jpg)-->


- [WKWebview 加载过程中的性能指标图解](https://www.jianshu.com/p/d7e79b58979c)
- [InfoQ：70%以上业务由H5开发，手机QQ Hybrid 的架构如何优化演进？](https://mp.weixin.qq.com/s/evzDnTsHrAr2b9jcevwBzA)
- [腾讯Bugly：移动端本地 H5 秒开方案探索与实现](https://mp.weixin.qq.com/s/0OR4HJQSDq7nEFUAaX1x5A)
- [网易传媒技术团队：网易新闻客户端 H5 秒开优化](https://mp.weixin.qq.com/s/AV2SwFfwwJH7xyrIBJemgw)
- [掘金：iOS app秒开H5优化探索](https://juejin.im/post/5c9c664ff265da611624764d)
