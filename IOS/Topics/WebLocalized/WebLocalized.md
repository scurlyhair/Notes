# Web资源本地化

## 1. 前言

此项技术应用于加速APP内嵌WebView页面渲染，减少等待时间，为用户提供更好的 web 体验。

当打开一个 H5 页面时做了很多事情：

> 初始化 webview -> 请求页面 -> 下载数据 -> 解析HTML -> 请求 js/css 资源 -> dom 渲染 -> 解析 JS 执行 -> JS 请求数据 -> 解析渲染 -> 下载渲染图片

![WebLocalized_01](WebLocalized_01.jpg)

一般情况下页面在 dom 渲染后才能展示，可以发现，H5 首屏渲染白屏问题的原因关键在于，如何优化减少从请求下载页面到渲染之间这段时间的耗时。

实现思路：将 H5 离线资源下发到 APP 中，在需要的时候拦截请求并返回本地资源文件。

## 2. 实现

我们需要维护一个【更新策略】来完成客户端跟服务器之间资源文件的比对和同步。以及一个【拦截策略】确定哪些 URL 需要进行拦截和进行资源返回。

### 2.1 更新

在app启动的时候，开启线程下载资源，注意不要影响app的启动。

根据【更新策略】中的 主version 判断是否有更新，如果有的话去比较 modules 列表，实现增量更新和删除。

```js
{
	// 【更新策略】 
	version: "xxx", // 离线资源包版本号
	modules: [ // 离线资源模块
		{
			moduleId: "xxx", // 模块ID
			version: "xxx", // 模块版本号
			zipUrl: "xxx.com/download/xxx.zip", // 模块资源下载路径
			md5: "MD5MD5MD5" // 模块资源 md5 校验码
		}
	]
}
```
将离线资源解压到: `/Library/Caches/WebResources` 目录下，解压后的文件目录结构如下：

> Zip 包里有和客户端同学约定好了 zip 包的具体内容和目录结构，对应页面的页面入口文件（index.html）和其他包含了页面依赖资源，页面资源目录结构和线上保持一致，这样可以方便客户端匹配查找，简化客户端处理逻辑。

### 2.2 拦截

拦截策略将**webURL** 做为 key，**moduleId**作为 value。有拦截需求的时候根据 moduleId 来找到本地资源目录进行加载。

```js
//【拦截配置】
{
	"xxx.com/xxx/xxx.html":  "xxx"
	...
}
```

当 APP 在 Webview 发起页面请求时，我们会先拦截当前页面请求，获取到页面的 URL 地址，根据离线管理器中配置，进行查找有无匹配的本地页面入口文件，有则直接返回入口文件，否则放行请求线上资源。

页面的加载会伴随着依赖资源的加载，获取请求 URL，如果在静态资源拦截域名内，则替换域名的 origin 为本地的静态资源目录进行查找。如果找到，获取文件扩展名，设置返回的文件类型直接返回。

## 3. 加载离线资源

### 3.1 推荐方案

基于 WKURLSchemeHandler 实现离线资源的加载。

拦截到URLScheme为customScheme的请求后，读取本地资源，并返回给WKWebView显示；若找不到本地资源，要将自定义 Scheme 的请求转换成 http 或 https 直接构建request对象访问服务器，收到回包后再将数据返回给WKWebView。

> 由于 WKURLSchemeHandler 在 iOS11 才推出，所以iOS11 之前的版本直接去加载网络资源。


### 3.2 其他方案

- 在使用 UIWebView 的时候可以考虑基于 NSURLProtocol 进行请求拦截
	- 缺点：UIWebView 性能方面不如WKWebView 且已经逐步被WKWebView 替换
- 使用 WKWebView 的情况推荐使用 WKURLSchemeHandler 进行拦截
	- 缺点： 对前端造成了入侵需要修改 scheme，而安卓端不需要，造成安卓、iOS 差异化严重
- 启动本地服务加载本地资源
	- 缺点：开发、管理、维护成本较高，耗电及性能影响


## 4. 其他

### 4.1 公共资源包

每个包都会使用相同的 JS 框架和 CSS 全局样式，这些资源重复在每一个离线包出现太浪费，可以做一个公共资源包提供这些全局文件。

### 4.2 预加载WebView

在一个进程内首次初始化 Webview 与第二次初始化不同，首次会比第二次慢很多。原因预计是 Webview 首次初始化后，即使 Webview 已经释放，但一些多 Webview 共用的全局服务或资源对象仍没有释放，第二次初始化时不需要再生成这些对象从而变快。我们可以在 APP 启动时预先初始化一个 Webview 然后释放，这样等用户真正走到 H5 模块去加载 Webview时就变快了。




参考链接：

- [web离线技术原理](https://juejin.im/post/5cd4fda8f265da03a00febe1)
- [WKWebview 加载过程中的性能指标图解](https://www.jianshu.com/p/d7e79b58979c)
- [InfoQ：70%以上业务由H5开发，手机QQ Hybrid 的架构如何优化演进？](https://mp.weixin.qq.com/s/evzDnTsHrAr2b9jcevwBzA)
- [腾讯Bugly：移动端本地 H5 秒开方案探索与实现](https://mp.weixin.qq.com/s/0OR4HJQSDq7nEFUAaX1x5A)
- [网易传媒技术团队：网易新闻客户端 H5 秒开优化](https://mp.weixin.qq.com/s/AV2SwFfwwJH7xyrIBJemgw)
- [掘金：iOS app秒开H5优化探索](https://juejin.im/post/5c9c664ff265da611624764d)
