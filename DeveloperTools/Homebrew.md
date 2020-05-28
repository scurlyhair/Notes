# Homebrew

安装方法见官网：[https://brew.sh/](https://brew.sh/)

GitHub地址：[https://github.com/Homebrew/brew](https://github.com/Homebrew/brew)


## 更换源

以下内容转载自：[macos brew 源管理替换为国内源还原官方源](https://www.32e.top/system/mac/article-137.html)

### 替换为国内源:

这里我用的是中科大的，因为其他的源好像都缺少homebrew-cask

替换brew.git

```shell
cd "$(brew --repo)"
git remote set-url origin https://mirrors.ustc.edu.cn/brew.git
```

替换homebrew-core.git

```shell
cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git
```

替换homebrew-cask默认源

```shell
cd "$(brew --repo)/Library/Taps/homebrew/homebrew-cask"
git remote set-url origin git://mirrors.ustc.edu.cn/homebrew-cask.git
```

替换homebrew-bottle默认源

```shell
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bashrc
source ~/.bashrc
```

然后就是更新: verbose可以显示更新详情

```shell
brew update --verbose
```

到此就已经替换为国内的源，但是我不知道国内的源更新是否及时，所以有可能会还原为官方源。


### 还原为官方源

其实操作就是逆向操作一次就好了。

这里我就不写步骤了直接写命令了。

```shell
// 还原 brew.git
cd "$(brew --repo)"
git remote set-url origin https://github.com/Homebrew/brew.git

// 还原 homebrew-core.git
cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
git remote set-url origin https://github.com/Homebrew/homebrew-core.git

// 还原 homebrew-cask.git
cd "$(brew --repo)/Library/Taps/homebrew/homebrew-cask"
git remote set-url origin  git://github.com/Homebrew/homebrew-cask.git

// 还原 homebrew-bottle
vim ~/.bashrc
// 然后把 .bashrc 文件中之前写入的那行删掉: 
// export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles'

brew update
brew doctor
```




