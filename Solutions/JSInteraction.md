# WKWebView中JS跟 Native通信

## 1. JS 调用 Native

基于 `ScriptMessageHandler` 实现：

```swift
// 1.约定业务的 handler 名称
let kHandlerNameTest = "business_test"

// 2.定义一个处理 Test 业务的类
class TestScriptMessageHandler: NSObject {
    
}

// 3.实现 WKScriptMessageHandler 协议
extension TestScriptMessageHandler: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 根据接收到的消息和参数进行原生业务处理
        let _ = message.name
        let _ = message.body
    }
}


// 4.实例化并将其注册到 webkit
let testHandler = TestScriptMessageHandler()
let webView = WKWebView()

// viewWillAppear 注册
webView.configuration.userContentController.add(testHandler, name: kHandlerNameTest)

// viewWillDisapear 移除
webView.configuration.userContentController.removeScriptMessageHandler(forName: kHandlerNameTest)
```

```js
// 5.js 进行调用
window.webkit.messageHandlers.kHandlerNameTest.postMessage(null);
```

> 注册跟移除ScriptMessageHandler 要成对使用，否则将造成内存泄漏。

## 2. Native 调用 JS

```swift
webView.evaluateJavaScript("alert('test');") { (result, error) in
        
}
```

## 3. JS 注入

```swift
// 要注入的 JavaScript 源码
let source = "function test(){ alert('test'); }"
/*
 注入时机
 atDocumentStart: Inject the script after the document element is created, but before any other content is loaded.
 atDocumentEnd: Inject the script after the document finishes loading, but before other subresources finish loading.
 */
let injectionTime = WKUserScriptInjectionTime.atDocumentEnd

// 是否只在主页面注入
let mainFrameOnly = false
// 创建 UserScript
let userScript = WKUserScript(source: source, injectionTime: injectionTime, forMainFrameOnly: mainFrameOnly)
// 进行注入
webView.configuration.userContentController.addUserScript(userScript)
// 移除所有已注入的js
webView.configuration.userContentController.removeAllUserScripts()
```

> 通过 JS 注入和 通信相结合，让WebView拥有更灵活的业务实现能力。
> 比如监测页面中按钮的点击事件、获取页面数据等。

## 4. WKWebView 加载本地资源

基于 `WKURLSchemeHandler` 实现（iOS 11.0 及以后支持）。

Web 加载 本地 `.png` 格式图片资源案例如下：

```swift
// 定义错误类型
enum URLSchemeError: Error {
    case NotSupport(url: URL?)
    case LackResource(url: URL?)
    
    var localizedDescription: String {
        switch self {
        case let .NotSupport(url):
            return "URLSchemeError: not supported url (\(url?.absoluteString ?? "unknowned"))"
        case let .LackResource(url):
            return "URLSchemeError: file not found (\(url?.absoluteString ?? "unknowned"))"
        }
    }
}

// 1. 约定资源的自定义 scheme
let kPngScheme = "ResourcePng"

// 2. 定义一个 handler 并实现 WKURLSchemeHandler 协议
class ImageURLSchemeHndler: NSObject {
    
}
extension ImageURLSchemeHndler: WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let url = urlSchemeTask.request.url
        // 获取资源路径
        guard let schemeRange = url?.absoluteString.range(of: "\(kPngScheme)://"), var path = url?.absoluteString else {
            return urlSchemeTask.didFailWithError(URLSchemeError.NotSupport(url: url))
        }
        
        path.removeSubrange(schemeRange)
        
        // 假设资源文件被下发到 Documents/Caches/ 目录
        guard let fileURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(path) else {
            return urlSchemeTask.didFailWithError(URLSchemeError.LackResource(url: url))
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let response = URLResponse(url: url!, mimeType: "image/png", expectedContentLength: data.count, textEncodingName: nil)
            
            // 将资源发送给 webkit
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        } catch let err {
            urlSchemeTask.didFailWithError(err)
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        
    }
}

// 3. 注册 handler 到 webkit
let imgHandler = ImageURLSchemeHndler()
let webView = WKWebView()
webView.configuration.setURLSchemeHandler(imgHandler, forURLScheme: kPngScheme)
```
HTML 页面：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
</head>
<body>
    <h3 > 本地图片 </h3>
    <img style="width: 200px;height:200px;" id="image1" src="ResourcePng://path/test.png" />
</body>
</html>
```
> TODO:
> 
>  iOS 11.0 之前 需要使用其他方案。 


参考链接：

- [iOS中WebKit框架应用与解析](https://www.cnblogs.com/fengmin/p/5737355.html)
- [WWDC2017-Customized Loading in WKWebView](https://www.jianshu.com/p/7f01b9038999)

