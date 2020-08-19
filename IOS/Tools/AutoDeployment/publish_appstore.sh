# iOS 使用 xcodebuild 自动打包发布

respository="" # 仓库地址
branch="" # 要构建的分支
project="" # git项目名称
name="" # 工程名称
scheme="" # scheme名称
configuration="" # 打包方式 AdHoc/Debug/Release
project_path=$(cd `dirname $0`; pwd) # 项目路径（当前文件夹）
build_path=${project_path}/build # build文件路径
plist_path=${project_path}/Resources/Appstore/ExportOptions.plist
ipa_path=${project_path}/IPADir/Appstore/${configuration}


if [ ! -d ./IPADir ];
then
mkdir -p IPADir;
fi

# 执行 jq 安装程序
installJq() {
    if command -v brew >/dev/null 2>&1
    then
        echo "___ jq 组件安装中 ___"
        sudo brew install jq
    else
        echo "___ Homebrew 安装中 ___"
        sudo /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        echo "___ jq 组件安装中 ___"
        sudo brew install jq
    fi
}

# 解析配置文件 config.json
readJsonValue() {
    jq ".$1" ./Resources/Appstore/config.json | sed 's/^.//' | sed 's/.$//'
}

readConfig() {
    echo "___ 开始解析配置文件 ___"

    respository=$(readJsonValue "respository")
    branch=$(readJsonValue "branch")
    project=$(readJsonValue "project")
    name=$(readJsonValue "name")
    scheme=$(readJsonValue "scheme")
    configuration=$(readJsonValue "configuration")
}
# 构建打包
build() {
    echo "___ 正在清理 ___"
    xcodebuild \
        clean \
        -quiet
    echo "___ 正在打包 ___"
    xcodebuild \
        archive -workspace ${project_path}/${name}.xcworkspace \
        -scheme ${scheme} \
        -configuration ${configuration} \
        -archivePath ${build_path}/${name}.xcarchive \
        -quiet
    echo "___ 正在导出ipa ___"
    xcodebuild \
        -exportArchive -archivePath ${build_path}/${name}.xcarchive \
        -configuration ${configuration} \
        -exportPath ${ipa_path} \
        -exportOptionsPlist ${plist_path} \
        -quiet
}

# 开始
checkJq() {
    if hash jq 2>/dev/null
    then
        echo "___ jq 已安装 ___"
    else
        installJq
    fi
}
# 设置路径
configPath() {
    project_path=${project_path}/${project}
}

checkRepository() {
if [ -d "${project_path}/.git/" ];
    then
        echo "___ git 仓库已存在 ___"
        cd ${project_path}
    else
        echo "___ 正在克隆仓库 ___"
        git clone ${respository}
        cd ${project_path}
    fi
}

# 开始运行
echo "___ 启动中 ___"
checkJq
readConfig
configPath
checkRepository
echo "___ 正在检出分支 ${branch} ___"
git checkout ${branch}
echo "___ 正在拉取云端数据 ___"
git pull
echo "___ 正在加载依赖 ___"
pod install --silent
build
terminal-notifier -message "打包完成"
echo "___ 完成 ___"

exit 0
