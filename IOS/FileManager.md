# 文件管理

## 沙盒

### 目录结构

- **Documents** 保存应用运行时生成的需要持久化的数据，iTunes会自动备份该目录。
- **Library**
	- **Caches** 一般存储的是缓存文件，例如图片视频等，iTunes不会备份该目录。
	- **Preferences** 保存应用程序的所有偏好设置iOS的Settings(设置)。iTunes会自动备份该文件目录下的内容。

- **tmp** 临时文件目录，在程序重新运行的时候，和开机的时候，会清空tmp文件夹。

## FileManager

可以对路径和文件进行操作

### 常用操作

**1. 获取沙盒路径**

```swift
let fm = FileManager.default
// 取得 tmp 路径
let tmpDir = fm.temporaryDirectory
// 取得 Library/Caches 路径
let cachesDir = fm.urls(for: .cachesDirectory, in: .userDomainMask)[0]
// 取得 Library/Preferences 路径
let preferencesDir = fm.urls(for: .preferencePanesDirectory, in: .userDomainMask)[0]
```

**2. 创建一个路径**

```swift
let newDirectory = tmpDir.appendingPathComponent("newPath").path
	do {
            try fm.createDirectory(atPath: newDirectory, withIntermediateDirectories: true, attributes: nil)
	} catch let err {
            print("Error: " + err.localizedDescription)
	}
```

**3. 创建一个文件**

```swift
let data = "TEST".data(using: .utf8)
let filePath = tmpDir.appendingPathComponent("test").appendingPathExtension("txt").path
let result = fm.createFile(atPath: filePath, contents: data, attributes: nil)
```

**4. 获取指定路径下的所有文件夹和文件列表**

```swift
do {
	let contents = try fm.contentsOfDirectory(atPath: tmpDir.path) // 注意这里要用.path 
} catch let err {
	print("Error: " + err.localizedDescription)
}
```

**5. 检查文件是否存在**

```swift
let filePath = tmpDir.appendingPathComponent("test").appendingPathExtension("txt").path
let exist = fs.fileExists(atPath: filePath)
```

