# WebKit

WebKit 是 Safari 浏览器的内核。由苹果公司开源，Chrome 浏览器的内核 Blink 也是基于 WebKit 开发的。


WebKit 的组成结构如下图:

![WebKit组成](WebKit_01.png)

从图中可以看到，WebKit 就是一个页面渲染以及逻辑处理的引擎。他把接收到的 HTML、JavaScript、CSS 渲染成浏览器页面，并为用户的交互提供支撑。

- **Webkit Embedding API** 是browser UI与webpage进行交互的api接口
- **Platform API** 提供与底层驱动的交互， 如网络， 字体渲染， 影音文件解码， 渲染引擎等。
- **WebCore** 实现了对文档的模型化，包括了CSS, DOM, Render等的实现。
- **JSCore** 是专门处理JavaScript脚本的引擎。


