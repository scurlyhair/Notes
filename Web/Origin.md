# 同源和跨域

## 1. 同源

### 1.1 什么是源

源 （origin）就是协议、域名、端口号三者组成的地址结构。

### 1.2 什么是同源

若地址里面的协议、域名和端口号均相同则属于同源。

如下是相对于 http://www.a.com/test/index.html 的同源检测：

- http://www.a.com/dir/page.html ----成功
- http://www.child.a.com/test/index.html ----失败，域名不同
- https://www.a.com/test/index.html ----失败，协议不同
- http://www.a.com:8080/test/index.html ----失败，端口号不同

### 1.3 什么是同源策略

同源策略是浏览器的一个安全功能，不同源的客户端脚本在没有明确授权的情况下，不能读写对方资源。同源政策的目的，是为了保证用户信息的安全，防止恶意的网站窃取数据。

> 设想这样一种情况：A网站是一家银行，用户登录以后，又去浏览其他网站。如果其他网站可以读取A网站的 Cookie，会发生什么？
> 
> 很显然，如果 Cookie 包含隐私（比如存款总额），这些信息就会泄漏。更可怕的是，Cookie 往往用来保存用户的登录状态，如果用户没有退出登录，其他网站就可以冒充用户，为所欲为。因为浏览器同时还规定，提交表单不受同源政策的限制。
> 
>由此可见，"同源政策"是必需的，否则 Cookie 可以共享，互联网就毫无安全可言了。

如果“非同源”，一下三种操作将会被限制：

- Cookie、LocalStorage 和 IndexDB 无法读取。
- DOM 无法获得。
- AJAX 请求不能发送。

## 2. 跨域

### 2.1 什么是跨域

由于浏览器同源策略的影响，不是同源的脚本不能操作其他源下面的对象。想要操作另一个源下的对象是就需要进行跨域。

### 2.2 跨域的实现

#### 2.2.1 Cross-document messaging

H5 引入的跨文档通信 API，用以处理跨窗口通信问题。

这个API为window对象新增了一个 `window.postMessage` 方法，允许跨窗口通信，不论这两个窗口是否同源。

```js
// 父窗口 http://aaa.com 向子窗口 http://bbb.com 发消息
var popup = window.open('http://bbb.com', 'title');
popup.postMessage('Hello World!', 'http://bbb.com');
// 子窗口向父窗口发消息
window.opener.postMessage('Nice to see you', 'http://aaa.com');

// 父窗口和子窗口都可以通过message事件，监听对方的消息。
window.addEventListener('message', function(event) {
  console.log(event.data);
},false);
/* 
	message事件的事件对象event，提供以下三个属性
	event.source：发送消息的窗口
	event.origin: 消息发向的网址
	event.data: 消息内容
*/
```

`postMessage` 方法的第一个参数是具体的信息内容，第二个参数是接收消息的窗口的源（`origin`），即"协议 + 域名 + 端口"。也可以设为`*`，表示不限制域名，向所有窗口发送。

#### 2.2.2 父子域名直接的 Cookies 共享

**1. documen.damain**

两个页面都设置相同的`documen.damain='example.com'`之后，Cookies 可以共享。

**2. 服务器设置Cookies**

服务器在设置Cookie的时候，指定Cookie的所属域名为一级域名。这样的话，二级域名和三级域名不用做任何设置，都可以读取这个Cookie。`Set-Cookie: key=value; domain=.example.com; path=/`

#### 2.2.2 iframe 数据通信

**1. 片段标识符**

片段标识符（fragment identifier）指的是，URL的`#`号后面的部分，比如`http://example.com/x.html#fragment`的`#fragment`。如果只是改变片段标识符，页面不会重新刷新。

```js
// 父窗口可以把信息，写入子窗口的片段标识符。
var src = originURL + '#' + data;
document.getElementById('myIFrame').src = src;
// 子窗口通过监听hashchange事件得到通知
window.onhashchange = checkMessage;

function checkMessage() {
  var message = window.location.hash;
  // ...
}

// 同样的，子窗口也可以改变父窗口的片段标识符。
parent.location.href= target + "#" + hash;
```
**2. window.name**

无论是否同源，只要在同一个窗口里，前一个网页设置了这个属性，后一个网页可以读取它。这种方法的优点是，`window.name`容量很大，可以放置非常长的字符串；缺点是必须监听子窗口`window.name`属性的变化，影响网页性能。

```js
// 同一个窗口的一个页面设置
window.name = data;
// 另一个页面获取
var data = document.getElementById('myFrame').contentWindow.name;
```

#### 2.2.3 AJAX

**1. 架设服务器代理**（浏览器请求同源服务器，再由后者请求外部服务）

**2. JSONP**

JSONP是服务器与客户端跨源通信的常用方法。最大特点就是简单适用，老式浏览器全部支持，服务器改造非常小。

它的基本思想是，网页通过添加一个`<script>`元素，向服务器请求JSON数据，这种做法不受同源政策限制；服务器收到请求后，将数据放在一个指定名字的回调函数里传回来。

```js
// 首先，网页动态插入<script>元素，由它向跨源网址发出请求。
function addScriptTag(src) {
  var script = document.createElement('script');
  script.setAttribute("type","text/javascript");
  script.src = src;
  document.body.appendChild(script);
}

// 该请求的查询字符串有一个callback参数，用来指定回调函数的名字，这对于JSONP是必需的。
window.onload = function () {
  addScriptTag('http://example.com/ip?callback=foo');
}

function foo(data) {
  console.log('Your public IP address is: ' + data.ip);
};

// 服务器收到这个请求以后，会将数据放在回调函数的参数位置返回。
foo({
  "ip": "8.8.8.8"
});
```

**3. WebSocket**

WebSocket是一种通信协议，使用`ws://`（非加密）和`wss://`（加密）作为协议前缀。该协议不实行同源政策，只要服务器支持，就可以通过它进行跨源通信。

```js
// 浏览器发出的WebSocket请求的头信息
GET /chat HTTP/1.1
Host: server.example.com
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==
Sec-WebSocket-Protocol: chat, superchat
Sec-WebSocket-Version: 13
Origin: http://example.com
```
上面代码中，有一个字段是Origin，表示该请求的请求源（origin），即发自哪个域名。

正是因为有了Origin这个字段，所以WebSocket才没有实行同源政策。因为服务器可以根据这个字段，判断是否许可本次通信。如果该域名在白名单内，服务器就会做出如下回应。

```js
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: HSmrc0sMlYUkAGmm5OPpG2HaGWk=
Sec-WebSocket-Protocol: chat
```

**4.CORS**

CORS是跨源资源分享（Cross-Origin Resource Sharing）的缩写。它是W3C标准，是跨源AJAX请求的**根本解决方法**。相比JSONP只能发GET请求，CORS允许任何类型的请求。

实现CORS通信的关键是服务器。只要服务器实现了CORS接口，就可以跨源通信。

详见：阮一峰老师的[跨域资源共享 CORS 详解](https://www.ruanyifeng.com/blog/2016/04/cors.html)

参考链接：

- [同源策略、跨域解决方案](https://www.cnblogs.com/rockmadman/p/6836834.html)
- [浏览器同源政策及其规避方法](https://www.ruanyifeng.com/blog/2016/04/same-origin-policy.html)