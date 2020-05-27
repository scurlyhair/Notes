# xcodebuild


## 1 Command Line Tools

Command Line Tools 是一个命令行工具包。它由两部分组成：OS X SDK和类似Clang等安装在/usr/bin下的命令行工具。例如gcc/g++编译器、make、git、nasm、xcodebuild、xcrun等等。在从App Store上下载Xcode后，默认是不会安装command Line Tools的。

### xcode-select

macOS 系统提供了一个命令行工具 xcode-select。它可以执行以下指令：

- `xcode-select -p` 打印 active developer directory
- `xcode-select -s <path>` 切换 active developer directory
- `xcode-select -r` 重置 active developer directory 为默认值
- `xcode-select --install` **安装 Command Line Tools**

>  当系统中安装了不同版本的 Xcode 时，xcode-select 用于切换默认 Xcode 版本 active developer directory 是指当前有效的开发路径。

```shell
xcode-select -p 
// print: /Applications/Xcode.app/Contents/Developer
```

## 2 xcodebuild

xcodebuild 是 Command Line Tools 包含的一个命令行工具。提供了对 Xcode project或 workspace 进行构建、测试、归档、导出等功能。它可以让我们的项目更容易地完成持续集成和自动化测试等工作。

### 2.1 查询指令

```shell
// 查看使用方法
xcodebuild -usage

Usage: xcodebuild [-project <projectname>] [[-target <targetname>]...|-alltargets] [-configuration <configurationname>] [-arch <architecture>]... [-sdk [<sdkname>|<sdkpath>]] [-showBuildSettings [-json]] [<buildsetting>=<value>]... [<buildaction>]...
       xcodebuild [-project <projectname>] -scheme <schemeName> [-destination <destinationspecifier>]... [-configuration <configurationname>] [-arch <architecture>]... [-sdk [<sdkname>|<sdkpath>]] [-showBuildSettings [-json]] [-showdestinations] [<buildsetting>=<value>]... [<buildaction>]...
       xcodebuild -workspace <workspacename> -scheme <schemeName> [-destination <destinationspecifier>]... [-configuration <configurationname>] [-arch <architecture>]... [-sdk [<sdkname>|<sdkpath>]] [-showBuildSettings] [-showdestinations] [<buildsetting>=<value>]... [<buildaction>]...
       xcodebuild -version [-sdk [<sdkfullpath>|<sdkname>] [-json] [<infoitem>] ]
       xcodebuild -list [[-project <projectname>]|[-workspace <workspacename>]] [-json]
       xcodebuild -showsdks [-json]
       xcodebuild -exportArchive -archivePath <xcarchivepath> [-exportPath <destinationpath>] -exportOptionsPlist <plistpath>
       xcodebuild -exportNotarizedApp -archivePath <xcarchivepath> -exportPath <destinationpath>
       xcodebuild -exportLocalizations -localizationPath <path> -project <projectname> [-exportLanguage <targetlanguage>...[-includeScreenshots]]
       xcodebuild -importLocalizations -localizationPath <path> -project <projectname>
       xcodebuild -resolvePackageDependencies [-project <projectname>|-workspace <workspacename>] -clonedSourcePackagesDirPath <path>
       xcodebuild -create-xcframework [-help] [-framework <path>] [-library <path> [-headers <path>]] -output <path>
```

```shell
// 查看指定对象的版本信息。如果对象参数缺省则显示 Xcode 的版本信息
xcodebuild -version 
[-sdk [<sdkfullpath>|<sdkname>] [-json] [<infoitem>] ]

iPhoneOS13.4.sdk - iOS 13.4 (iphoneos13.4)
SDKVersion: 13.4
Path: /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk
PlatformVersion: 13.4
PlatformPath: /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform
BuildID: 7E149F44-7546-11EA-B633-5A063EDC175F
ProductBuildVersion: 17E8258
ProductCopyright: 1983-2020 Apple Inc.
ProductName: iPhone OS
ProductVersion: 13.4.1
```

```shell
// 查看已安装的 sdk 版本号
xcodebuild -showsdks
[-json]

iOS SDKs:
	iOS 13.4                      	-sdk iphoneos13.4

iOS Simulator SDKs:
	Simulator - iOS 13.4          	-sdk iphonesimulator13.4

macOS SDKs:
	DriverKit 19.0                	-sdk driverkit.macosx19.0
	macOS 10.15                   	-sdk macosx10.15

tvOS SDKs:
	tvOS 13.4                     	-sdk appletvos13.4

tvOS Simulator SDKs:
	Simulator - tvOS 13.4         	-sdk appletvsimulator13.4

watchOS SDKs:
	watchOS 6.2                   	-sdk watchos6.2

watchOS Simulator SDKs:
	Simulator - watchOS 6.2       	-sdk watchsimulator6.2
```

```shell
// 显示 project/worksapce 的相关信息
xcodebuild -list 
[[-project <projectname>]|[-workspace <workspacename>]] 
[-json]

Information about project "Example":
    Targets:
        Example
        ExampleTests

    Build Configurations:
        Debug
        Release

    If no build configuration is specified and -scheme is not passed then "Release" is used.

    Schemes:
        Example
```

```shell
// 显示构建设置表的信息
xcodebuild -showBuildSettings
[-json]

Build settings for action build and target Example:
    ACTION = build
    AD_HOC_CODE_SIGNING_ALLOWED = NO
    ALTERNATE_GROUP = staff
    ALTERNATE_MODE = u+w,go-w,a+rX
    ALTERNATE_OWNER = xxx
    ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = NO
    ALWAYS_SEARCH_USER_PATHS = NO
    ALWAYS_USE_SEPARATE_HEADERMAPS = NO
    APPLE_INTERNAL_DEVELOPER_DIR = /AppleInternal/Developer
    APPLE_INTERNAL_DIR = /AppleInternal
    APPLE_INTERNAL_DOCUMENTATION_DIR = /AppleInternal/Documentation
    APPLE_INTERNAL_LIBRARY_DIR = /AppleInternal/Library
    APPLE_INTERNAL_TOOLS = /AppleInternal/Developer/Tools
    APPLICATION_EXTENSION_API_ONLY = NO
    APPLY_RULES_IN_COPY_FILES = NO
    APPLY_RULES_IN_COPY_HEADERS = NO
    ARCHS = arm64
    ARCHS_STANDARD = arm64
    ARCHS_STANDARD_32_64_BIT = armv7 arm64
    ARCHS_STANDARD_32_BIT = armv7
    ARCHS_STANDARD_64_BIT = arm64
    ARCHS_STANDARD_INCLUDING_64_BIT = arm64
    ARCHS_UNIVERSAL_IPHONE_OS = armv7 arm64
    ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon
    AVAILABLE_PLATFORMS = appletvos appletvsimulator iphoneos iphonesimulator macosx watchos watchsimulator
    BITCODE_GENERATION_MODE = marker
    BUILD_ACTIVE_RESOURCES_ONLY = NO
    BUILD_COMPONENTS = headers build
    BUILD_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Products
    BUILD_LIBRARY_FOR_DISTRIBUTION = NO
    BUILD_ROOT = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Products
    BUILD_STYLE = 
    BUILD_VARIANTS = normal
    BUILT_PRODUCTS_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Products/Release-iphoneos
    BUNDLE_CONTENTS_FOLDER_PATH_deep = Contents/
    BUNDLE_EXECUTABLE_FOLDER_NAME_deep = MacOS
    BUNDLE_FORMAT = shallow
    BUNDLE_FRAMEWORKS_FOLDER_PATH = Frameworks
    BUNDLE_PLUGINS_FOLDER_PATH = PlugIns
    BUNDLE_PRIVATE_HEADERS_FOLDER_PATH = PrivateHeaders
    BUNDLE_PUBLIC_HEADERS_FOLDER_PATH = Headers
    CACHE_ROOT = /var/folders/8z/hpvxx6851h50j84c826k72nc0000gp/C/com.apple.DeveloperTools/11.4.1-11E503a/Xcode
    CCHROOT = /var/folders/8z/hpvxx6851h50j84c826k72nc0000gp/C/com.apple.DeveloperTools/11.4.1-11E503a/Xcode
    CHMOD = /bin/chmod
    CHOWN = /usr/sbin/chown
    CLANG_ANALYZER_NONNULL = YES
    CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE
    CLANG_CXX_LANGUAGE_STANDARD = gnu++14
    CLANG_CXX_LIBRARY = libc++
    CLANG_ENABLE_MODULES = YES
    CLANG_ENABLE_OBJC_ARC = YES
    CLANG_ENABLE_OBJC_WEAK = YES
    CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES
    CLANG_WARN_BOOL_CONVERSION = YES
    CLANG_WARN_COMMA = YES
    CLANG_WARN_CONSTANT_CONVERSION = YES
    CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES
    CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR
    CLANG_WARN_DOCUMENTATION_COMMENTS = YES
    CLANG_WARN_EMPTY_BODY = YES
    CLANG_WARN_ENUM_CONVERSION = YES
    CLANG_WARN_INFINITE_RECURSION = YES
    CLANG_WARN_INT_CONVERSION = YES
    CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES
    CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES
    CLANG_WARN_OBJC_LITERAL_CONVERSION = YES
    CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR
    CLANG_WARN_RANGE_LOOP_ANALYSIS = YES
    CLANG_WARN_STRICT_PROTOTYPES = YES
    CLANG_WARN_SUSPICIOUS_MOVE = YES
    CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE
    CLANG_WARN_UNREACHABLE_CODE = YES
    CLANG_WARN__DUPLICATE_METHOD_MATCH = YES
    CLASS_FILE_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build/JavaClasses
    CLEAN_PRECOMPS = YES
    CLONE_HEADERS = NO
    CODESIGNING_FOLDER_PATH = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Products/Release-iphoneos/Example.app
    CODE_SIGNING_ALLOWED = YES
    CODE_SIGNING_REQUIRED = YES
    CODE_SIGN_CONTEXT_CLASS = XCiPhoneOSCodeSignContext
    CODE_SIGN_IDENTITY = Apple Development
    CODE_SIGN_INJECT_BASE_ENTITLEMENTS = YES
    CODE_SIGN_STYLE = Automatic
    COLOR_DIAGNOSTICS = YES
    COMBINE_HIDPI_IMAGES = NO
    COMPILER_INDEX_STORE_ENABLE = Default
    COMPOSITE_SDK_DIRS = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/CompositeSDKs
    COMPRESS_PNG_FILES = YES
    CONFIGURATION = Release
    CONFIGURATION_BUILD_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Products/Release-iphoneos
    CONFIGURATION_TEMP_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos
    CONTENTS_FOLDER_PATH = Example.app
    COPYING_PRESERVES_HFS_DATA = NO
    COPY_HEADERS_RUN_UNIFDEF = NO
    COPY_PHASE_STRIP = NO
    COPY_RESOURCES_FROM_STATIC_FRAMEWORKS = YES
    CORRESPONDING_SIMULATOR_PLATFORM_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform
    CORRESPONDING_SIMULATOR_PLATFORM_NAME = iphonesimulator
    CORRESPONDING_SIMULATOR_SDK_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk
    CORRESPONDING_SIMULATOR_SDK_NAME = iphonesimulator13.4
    CP = /bin/cp
    CREATE_INFOPLIST_SECTION_IN_BINARY = NO
    CURRENT_ARCH = arm64
    CURRENT_VARIANT = normal
    DEAD_CODE_STRIPPING = YES
    DEBUGGING_SYMBOLS = YES
    DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
    DEFAULT_COMPILER = com.apple.compilers.llvm.clang.1_0
    DEFAULT_DEXT_INSTALL_PATH = /System/Library/DriverExtensions
    DEFAULT_KEXT_INSTALL_PATH = /System/Library/Extensions
    DEFINES_MODULE = NO
    DEPLOYMENT_LOCATION = NO
    DEPLOYMENT_POSTPROCESSING = NO
    DEPLOYMENT_TARGET_CLANG_ENV_NAME = IPHONEOS_DEPLOYMENT_TARGET
    DEPLOYMENT_TARGET_CLANG_FLAG_NAME = miphoneos-version-min
    DEPLOYMENT_TARGET_CLANG_FLAG_PREFIX = -miphoneos-version-min=
    DEPLOYMENT_TARGET_LD_ENV_NAME = IPHONEOS_DEPLOYMENT_TARGET
    DEPLOYMENT_TARGET_LD_FLAG_NAME = ios_version_min
    DEPLOYMENT_TARGET_SETTING_NAME = IPHONEOS_DEPLOYMENT_TARGET
    DEPLOYMENT_TARGET_SUGGESTED_VALUES = 8.0 8.1 8.2 8.3 8.4 9.0 9.1 9.2 9.3 10.0 10.1 10.2 10.3 11.0 11.1 11.2 11.3 11.4 12.0 12.1 12.2 12.3 12.4 13.0 13.1 13.2 13.3 13.4
    DERIVED_FILES_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build/DerivedSources
    DERIVED_FILE_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build/DerivedSources
    DERIVED_SOURCES_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build/DerivedSources
    DEVELOPER_APPLICATIONS_DIR = /Applications/Xcode.app/Contents/Developer/Applications
    DEVELOPER_BIN_DIR = /Applications/Xcode.app/Contents/Developer/usr/bin
    DEVELOPER_DIR = /Applications/Xcode.app/Contents/Developer
    DEVELOPER_FRAMEWORKS_DIR = /Applications/Xcode.app/Contents/Developer/Library/Frameworks
    DEVELOPER_FRAMEWORKS_DIR_QUOTED = /Applications/Xcode.app/Contents/Developer/Library/Frameworks
    DEVELOPER_LIBRARY_DIR = /Applications/Xcode.app/Contents/Developer/Library
    DEVELOPER_SDK_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs
    DEVELOPER_TOOLS_DIR = /Applications/Xcode.app/Contents/Developer/Tools
    DEVELOPER_USR_DIR = /Applications/Xcode.app/Contents/Developer/usr
    DEVELOPMENT_LANGUAGE = en
    DEVELOPMENT_TEAM = 5TQJHMS252
    DOCUMENTATION_FOLDER_PATH = Example.app/en.lproj/Documentation
    DONT_GENERATE_INFOPLIST_FILE = NO
    DO_HEADER_SCANNING_IN_JAM = NO
    DSTROOT = /tmp/Example.dst
    DT_TOOLCHAIN_DIR = /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain
    DWARF_DSYM_FILE_NAME = Example.app.dSYM
    DWARF_DSYM_FILE_SHOULD_ACCOMPANY_PRODUCT = NO
    DWARF_DSYM_FOLDER_PATH = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Products/Release-iphoneos
    EFFECTIVE_PLATFORM_NAME = -iphoneos
    EMBEDDED_CONTENT_CONTAINS_SWIFT = NO
    EMBEDDED_PROFILE_NAME = embedded.mobileprovision
    EMBED_ASSET_PACKS_IN_PRODUCT_BUNDLE = NO
    ENABLE_BITCODE = YES
    ENABLE_DEFAULT_HEADER_SEARCH_PATHS = YES
    ENABLE_HARDENED_RUNTIME = NO
    ENABLE_HEADER_DEPENDENCIES = YES
    ENABLE_NS_ASSERTIONS = NO
    ENABLE_ON_DEMAND_RESOURCES = YES
    ENABLE_STRICT_OBJC_MSGSEND = YES
    ENABLE_TESTABILITY = NO
    ENABLE_TESTING_SEARCH_PATHS = NO
    ENTITLEMENTS_ALLOWED = YES
    ENTITLEMENTS_DESTINATION = Signature
    ENTITLEMENTS_REQUIRED = YES
    EXCLUDED_INSTALLSRC_SUBDIRECTORY_PATTERNS = .DS_Store .svn .git .hg CVS
    EXCLUDED_RECURSIVE_SEARCH_PATH_SUBDIRECTORIES = *.nib *.lproj *.framework *.gch *.xcode* *.xcassets (*) .DS_Store CVS .svn .git .hg *.pbproj *.pbxproj
    EXECUTABLES_FOLDER_PATH = Example.app/Executables
    EXECUTABLE_FOLDER_PATH = Example.app
    EXECUTABLE_NAME = Example
    EXECUTABLE_PATH = Example.app/Example
    EXPANDED_CODE_SIGN_IDENTITY = 
    EXPANDED_CODE_SIGN_IDENTITY_NAME = 
    EXPANDED_PROVISIONING_PROFILE = 
    FILE_LIST = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build/Objects/LinkFileList
    FIXED_FILES_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build/FixedFiles
    FRAMEWORKS_FOLDER_PATH = Example.app/Frameworks
    FRAMEWORK_FLAG_PREFIX = -framework
    FRAMEWORK_VERSION = A
    FULL_PRODUCT_NAME = Example.app
    GCC3_VERSION = 3.3
    GCC_C_LANGUAGE_STANDARD = gnu11
    GCC_INLINES_ARE_PRIVATE_EXTERN = YES
    GCC_NO_COMMON_BLOCKS = YES
    GCC_PFE_FILE_C_DIALECTS = c objective-c c++ objective-c++
    GCC_SYMBOLS_PRIVATE_EXTERN = YES
    GCC_THUMB_SUPPORT = YES
    GCC_TREAT_WARNINGS_AS_ERRORS = NO
    GCC_VERSION = com.apple.compilers.llvm.clang.1_0
    GCC_VERSION_IDENTIFIER = com_apple_compilers_llvm_clang_1_0
    GCC_WARN_64_TO_32_BIT_CONVERSION = YES
    GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR
    GCC_WARN_UNDECLARED_SELECTOR = YES
    GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE
    GCC_WARN_UNUSED_FUNCTION = YES
    GCC_WARN_UNUSED_VARIABLE = YES
    GENERATE_MASTER_OBJECT_FILE = NO
    GENERATE_PKGINFO_FILE = YES
    GENERATE_PROFILING_CODE = NO
    GENERATE_TEXT_BASED_STUBS = NO
    GID = 20
    GROUP = staff
    HEADERMAP_INCLUDES_FLAT_ENTRIES_FOR_TARGET_BEING_BUILT = YES
    HEADERMAP_INCLUDES_FRAMEWORK_ENTRIES_FOR_ALL_PRODUCT_TYPES = YES
    HEADERMAP_INCLUDES_NONPUBLIC_NONPRIVATE_HEADERS = YES
    HEADERMAP_INCLUDES_PROJECT_HEADERS = YES
    HEADERMAP_USES_FRAMEWORK_PREFIX_ENTRIES = YES
    HEADERMAP_USES_VFS = NO
    HIDE_BITCODE_SYMBOLS = YES
    HOME = /Users/xxx
    ICONV = /usr/bin/iconv
    INFOPLIST_EXPAND_BUILD_SETTINGS = YES
    INFOPLIST_FILE = Example/Info.plist
    INFOPLIST_OUTPUT_FORMAT = binary
    INFOPLIST_PATH = Example.app/Info.plist
    INFOPLIST_PREPROCESS = NO
    INFOSTRINGS_PATH = Example.app/en.lproj/InfoPlist.strings
    INLINE_PRIVATE_FRAMEWORKS = NO
    INSTALLHDRS_COPY_PHASE = NO
    INSTALLHDRS_SCRIPT_PHASE = NO
    INSTALL_DIR = /tmp/Example.dst/Applications
    INSTALL_GROUP = staff
    INSTALL_MODE_FLAG = u+w,go-w,a+rX
    INSTALL_OWNER = xxx
    INSTALL_PATH = /Applications
    INSTALL_ROOT = /tmp/Example.dst
    IPHONEOS_DEPLOYMENT_TARGET = 13.2
    JAVAC_DEFAULT_FLAGS = -J-Xms64m -J-XX:NewSize=4M -J-Dfile.encoding=UTF8
    JAVA_APP_STUB = /System/Library/Frameworks/JavaVM.framework/Resources/MacOS/JavaApplicationStub
    JAVA_ARCHIVE_CLASSES = YES
    JAVA_ARCHIVE_TYPE = JAR
    JAVA_COMPILER = /usr/bin/javac
    JAVA_FOLDER_PATH = Example.app/Java
    JAVA_FRAMEWORK_RESOURCES_DIRS = Resources
    JAVA_JAR_FLAGS = cv
    JAVA_SOURCE_SUBDIR = .
    JAVA_USE_DEPENDENCIES = YES
    JAVA_ZIP_FLAGS = -urg
    JIKES_DEFAULT_FLAGS = +E +OLDCSO
    KASAN_DEFAULT_CFLAGS = -DKASAN=1 -fsanitize=address -mllvm -asan-globals-live-support -mllvm -asan-force-dynamic-shadow
    KEEP_PRIVATE_EXTERNS = NO
    LD_DEPENDENCY_INFO_FILE = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build/Objects-normal/arm64/Example_dependency_info.dat
    LD_GENERATE_MAP_FILE = NO
    LD_MAP_FILE_PATH = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build/Example-LinkMap-normal-arm64.txt
    LD_NO_PIE = NO
    LD_QUOTE_LINKER_ARGUMENTS_FOR_COMPILER_DRIVER = YES
    LD_RUNPATH_SEARCH_PATHS =  @executable_path/Frameworks
    LEGACY_DEVELOPER_DIR = /Applications/Xcode.app/Contents/PlugIns/Xcode3Core.ideplugin/Contents/SharedSupport/Developer
    LEX = lex
    LIBRARY_DEXT_INSTALL_PATH = /Library/DriverExtensions
    LIBRARY_FLAG_NOSPACE = YES
    LIBRARY_FLAG_PREFIX = -l
    LIBRARY_KEXT_INSTALL_PATH = /Library/Extensions
    LINKER_DISPLAYS_MANGLED_NAMES = NO
    LINK_FILE_LIST_normal_arm64 = 
    LINK_WITH_STANDARD_LIBRARIES = YES
    LLVM_TARGET_TRIPLE_OS_VERSION = ios13.2
    LLVM_TARGET_TRIPLE_VENDOR = apple
    LOCALIZABLE_CONTENT_DIR = 
    LOCALIZED_RESOURCES_FOLDER_PATH = Example.app/en.lproj
    LOCALIZED_STRING_MACRO_NAMES = NSLocalizedString CFCopyLocalizedString
    LOCALIZED_STRING_SWIFTUI_SUPPORT = YES
    LOCAL_ADMIN_APPS_DIR = /Applications/Utilities
    LOCAL_APPS_DIR = /Applications
    LOCAL_DEVELOPER_DIR = /Library/Developer
    LOCAL_LIBRARY_DIR = /Library
    LOCROOT = 
    LOCSYMROOT = 
    MACH_O_TYPE = mh_execute
    MAC_OS_X_PRODUCT_BUILD_VERSION = 19E287
    MAC_OS_X_VERSION_ACTUAL = 101504
    MAC_OS_X_VERSION_MAJOR = 101500
    MAC_OS_X_VERSION_MINOR = 1504
    METAL_LIBRARY_FILE_BASE = default
    METAL_LIBRARY_OUTPUT_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Products/Release-iphoneos/Example.app
    MODULES_FOLDER_PATH = Example.app/Modules
    MODULE_CACHE_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
    MTL_ENABLE_DEBUG_INFO = NO
    MTL_FAST_MATH = YES
    NATIVE_ARCH = armv7
    NATIVE_ARCH_32_BIT = i386
    NATIVE_ARCH_64_BIT = x86_64
    NATIVE_ARCH_ACTUAL = x86_64
    NO_COMMON = YES
    OBJECT_FILE_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build/Objects
    OBJECT_FILE_DIR_normal = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build/Objects-normal
    OBJROOT = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex
    ONLY_ACTIVE_ARCH = NO
    OS = MACOS
    OSAC = /usr/bin/osacompile
    PACKAGE_TYPE = com.apple.package-type.wrapper.application
    PASCAL_STRINGS = YES
    PATH = /Applications/Xcode.app/Contents/Developer/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin
    PATH_PREFIXES_EXCLUDED_FROM_HEADER_DEPENDENCIES = /usr/include /usr/local/include /System/Library/Frameworks /System/Library/PrivateFrameworks /Applications/Xcode.app/Contents/Developer/Headers /Applications/Xcode.app/Contents/Developer/SDKs /Applications/Xcode.app/Contents/Developer/Platforms
    PBDEVELOPMENTPLIST_PATH = Example.app/pbdevelopment.plist
    PKGINFO_FILE_PATH = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build/PkgInfo
    PKGINFO_PATH = Example.app/PkgInfo
    PLATFORM_DEVELOPER_APPLICATIONS_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Applications
    PLATFORM_DEVELOPER_BIN_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin
    PLATFORM_DEVELOPER_LIBRARY_DIR = /Applications/Xcode.app/Contents/PlugIns/Xcode3Core.ideplugin/Contents/SharedSupport/Developer/Library
    PLATFORM_DEVELOPER_SDK_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs
    PLATFORM_DEVELOPER_TOOLS_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Tools
    PLATFORM_DEVELOPER_USR_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr
    PLATFORM_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform
    PLATFORM_DISPLAY_NAME = iOS
    PLATFORM_NAME = iphoneos
    PLATFORM_PREFERRED_ARCH = arm64
    PLATFORM_PRODUCT_BUILD_VERSION = 17E8258
    PLIST_FILE_OUTPUT_FORMAT = binary
    PLUGINS_FOLDER_PATH = Example.app/PlugIns
    PRECOMPS_INCLUDE_HEADERS_FROM_BUILT_PRODUCTS_DIR = YES
    PRECOMP_DESTINATION_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build/PrefixHeaders
    PRESERVE_DEAD_CODE_INITS_AND_TERMS = NO
    PRIVATE_HEADERS_FOLDER_PATH = Example.app/PrivateHeaders
    PRODUCT_BUNDLE_IDENTIFIER = com.scurly.Example
    PRODUCT_BUNDLE_PACKAGE_TYPE = APPL
    PRODUCT_MODULE_NAME = Example
    PRODUCT_NAME = Example
    PRODUCT_SETTINGS_PATH = /Users/xxx/Desktop/Example/Example/Info.plist
    PRODUCT_TYPE = com.apple.product-type.application
    PROFILING_CODE = NO
    PROJECT = Example
    PROJECT_DERIVED_FILE_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/DerivedSources
    PROJECT_DIR = /Users/xxx/Desktop/Example
    PROJECT_FILE_PATH = /Users/xxx/Desktop/Example/Example.xcodeproj
    PROJECT_NAME = Example
    PROJECT_TEMP_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build
    PROJECT_TEMP_ROOT = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex
    PROVISIONING_PROFILE_REQUIRED = YES
    PUBLIC_HEADERS_FOLDER_PATH = Example.app/Headers
    RECURSIVE_SEARCH_PATHS_FOLLOW_SYMLINKS = YES
    REMOVE_CVS_FROM_RESOURCES = YES
    REMOVE_GIT_FROM_RESOURCES = YES
    REMOVE_HEADERS_FROM_EMBEDDED_BUNDLES = YES
    REMOVE_HG_FROM_RESOURCES = YES
    REMOVE_SVN_FROM_RESOURCES = YES
    RESOURCE_RULES_REQUIRED = YES
    REZ_COLLECTOR_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build/ResourceManagerResources
    REZ_OBJECTS_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build/ResourceManagerResources/Objects
    SCAN_ALL_SOURCE_FILES_FOR_INCLUDES = NO
    SCRIPTS_FOLDER_PATH = Example.app/Scripts
    SDKROOT = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk
    SDK_DIR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk
    SDK_DIR_iphoneos13_4 = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk
    SDK_NAME = iphoneos13.4
    SDK_NAMES = iphoneos13.4
    SDK_PRODUCT_BUILD_VERSION = 17E8258
    SDK_VERSION = 13.4
    SDK_VERSION_ACTUAL = 130400
    SDK_VERSION_MAJOR = 130000
    SDK_VERSION_MINOR = 400
    SED = /usr/bin/sed
    SEPARATE_STRIP = NO
    SEPARATE_SYMBOL_EDIT = NO
    SET_DIR_MODE_OWNER_GROUP = YES
    SET_FILE_MODE_OWNER_GROUP = NO
    SHALLOW_BUNDLE = YES
    SHARED_DERIVED_FILE_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Products/Release-iphoneos/DerivedSources
    SHARED_FRAMEWORKS_FOLDER_PATH = Example.app/SharedFrameworks
    SHARED_PRECOMPS_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/PrecompiledHeaders
    SHARED_SUPPORT_FOLDER_PATH = Example.app/SharedSupport
    SKIP_INSTALL = NO
    SOURCE_ROOT = /Users/xxx/Desktop/Example
    SRCROOT = /Users/xxx/Desktop/Example
    STRINGS_FILE_OUTPUT_ENCODING = binary
    STRIP_BITCODE_FROM_COPIED_FILES = YES
    STRIP_INSTALLED_PRODUCT = YES
    STRIP_STYLE = all
    STRIP_SWIFT_SYMBOLS = YES
    SUPPORTED_DEVICE_FAMILIES = 1,2
    SUPPORTED_PLATFORMS = iphonesimulator iphoneos
    SUPPORTS_MACCATALYST = NO
    SUPPORTS_TEXT_BASED_API = NO
    SWIFT_COMPILATION_MODE = wholemodule
    SWIFT_OPTIMIZATION_LEVEL = -O
    SWIFT_PLATFORM_TARGET_PREFIX = ios
    SWIFT_VERSION = 5.0
    SYMROOT = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Products
    SYSTEM_ADMIN_APPS_DIR = /Applications/Utilities
    SYSTEM_APPS_DIR = /Applications
    SYSTEM_CORE_SERVICES_DIR = /System/Library/CoreServices
    SYSTEM_DEMOS_DIR = /Applications/Extras
    SYSTEM_DEVELOPER_APPS_DIR = /Applications/Xcode.app/Contents/Developer/Applications
    SYSTEM_DEVELOPER_BIN_DIR = /Applications/Xcode.app/Contents/Developer/usr/bin
    SYSTEM_DEVELOPER_DEMOS_DIR = /Applications/Xcode.app/Contents/Developer/Applications/Utilities/Built Examples
    SYSTEM_DEVELOPER_DIR = /Applications/Xcode.app/Contents/Developer
    SYSTEM_DEVELOPER_DOC_DIR = /Applications/Xcode.app/Contents/Developer/ADC Reference Library
    SYSTEM_DEVELOPER_GRAPHICS_TOOLS_DIR = /Applications/Xcode.app/Contents/Developer/Applications/Graphics Tools
    SYSTEM_DEVELOPER_JAVA_TOOLS_DIR = /Applications/Xcode.app/Contents/Developer/Applications/Java Tools
    SYSTEM_DEVELOPER_PERFORMANCE_TOOLS_DIR = /Applications/Xcode.app/Contents/Developer/Applications/Performance Tools
    SYSTEM_DEVELOPER_RELEASENOTES_DIR = /Applications/Xcode.app/Contents/Developer/ADC Reference Library/releasenotes
    SYSTEM_DEVELOPER_TOOLS = /Applications/Xcode.app/Contents/Developer/Tools
    SYSTEM_DEVELOPER_TOOLS_DOC_DIR = /Applications/Xcode.app/Contents/Developer/ADC Reference Library/documentation/DeveloperTools
    SYSTEM_DEVELOPER_TOOLS_RELEASENOTES_DIR = /Applications/Xcode.app/Contents/Developer/ADC Reference Library/releasenotes/DeveloperTools
    SYSTEM_DEVELOPER_USR_DIR = /Applications/Xcode.app/Contents/Developer/usr
    SYSTEM_DEVELOPER_UTILITIES_DIR = /Applications/Xcode.app/Contents/Developer/Applications/Utilities
    SYSTEM_DEXT_INSTALL_PATH = /System/Library/DriverExtensions
    SYSTEM_DOCUMENTATION_DIR = /Library/Documentation
    SYSTEM_KEXT_INSTALL_PATH = /System/Library/Extensions
    SYSTEM_LIBRARY_DIR = /System/Library
    TAPI_VERIFY_MODE = ErrorsOnly
    TARGETED_DEVICE_FAMILY = 1,2
    TARGETNAME = Example
    TARGET_BUILD_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Products/Release-iphoneos
    TARGET_NAME = Example
    TARGET_TEMP_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build
    TEMP_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build
    TEMP_FILES_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build
    TEMP_FILE_DIR = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex/Example.build/Release-iphoneos/Example.build
    TEMP_ROOT = /Users/xxx/Library/Developer/Xcode/DerivedData/Example-fqhrxlbzhnqgembxkpoltpsfcabj/Build/Intermediates.noindex
    TEST_FRAMEWORK_SEARCH_PATHS =  /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Frameworks
    TEST_LIBRARY_SEARCH_PATHS =  /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib
    TOOLCHAIN_DIR = /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain
    TREAT_MISSING_BASELINES_AS_TEST_FAILURES = NO
    UID = 502
    UNLOCALIZED_RESOURCES_FOLDER_PATH = Example.app
    UNSTRIPPED_PRODUCT = NO
    USER = xxx
    USER_APPS_DIR = /Users/xxx/Applications
    USER_LIBRARY_DIR = /Users/xxx/Library
    USE_DYNAMIC_NO_PIC = YES
    USE_HEADERMAP = YES
    USE_HEADER_SYMLINKS = NO
    USE_LLVM_TARGET_TRIPLES = YES
    USE_LLVM_TARGET_TRIPLES_FOR_CLANG = YES
    USE_LLVM_TARGET_TRIPLES_FOR_LD = YES
    USE_LLVM_TARGET_TRIPLES_FOR_TAPI = YES
    VALIDATE_PRODUCT = YES
    VALIDATE_WORKSPACE = NO
    VALID_ARCHS = arm64 arm64e armv7 armv7s
    VERBOSE_PBXCP = NO
    VERSIONPLIST_PATH = Example.app/version.plist
    VERSION_INFO_BUILDER = xxx
    VERSION_INFO_FILE = Example_vers.c
    VERSION_INFO_STRING = "@(#)PROGRAM:Example  PROJECT:Example-"
    WRAPPER_EXTENSION = app
    WRAPPER_NAME = Example.app
    WRAPPER_SUFFIX = .app
    WRAP_ASSET_PACKS_IN_SEPARATE_DIRECTORIES = NO
    XCODE_APP_SUPPORT_DIR = /Applications/Xcode.app/Contents/Developer/Library/Xcode
    XCODE_PRODUCT_BUILD_VERSION = 11E503a
    XCODE_VERSION_ACTUAL = 1141
    XCODE_VERSION_MAJOR = 1100
    XCODE_VERSION_MINOR = 1140
    XPCSERVICES_FOLDER_PATH = Example.app/XPCServices
    YACC = yacc
    arch = arm64
    diagnostic_message_length = 165
    variant = normal
```

### 2.2 参数指令

参数指令用于配合 action 使用

```shell
// 指定project
-project <projectname>

// 指定 target
[-target <targetname>]...|-alltargets

// 指定 scheme
-scheme <schemeName>

// 指定构建方式 Debug/Release
-configuration <configurationname>

// 指定 architecture
[-arch <architecture>]... 

// 指定 sdk
-sdk [<sdkname>|<sdkpath>]

//允许xcodebuild与Apple Developer网站进行通信。 对于自动签名的目标，xcodebuild将创建并更新配置文件，应用程序ID和证书。 对于手动签名的目标，xcodebuild将下载缺失或更新的供应配置文件， 需要在Xcode的帐户首选项窗格中添加开发者帐户。
-allowProvisioningUpdates

// 如有必要，允许xcodebuild在Apple Developer网站上注册您的目标设备。需要-allowProvisioningUpdates。
-allowProvisioningDeviceRegistration

// 指定 BuildSetting
[<buildsetting>=<value>]...  

// 指定archive操作生成归档的路径。或者在使用-exportArchive时指定归档的路径。
-archivePath

// 指定导出IPA文件到哪个路径，其中在最后要包括IPA文件的名称。
-exportPath	

// 导出IPA文件时，需要指定一个ExportOptions.plist文件，如果不知道怎么填写这个文件，可以先用Xcode手动打包一次，导出文件中会有ExportOptions.plist，然后手动copy就好。
-exportOptionsPlist

// 指定生产DerivedData的文件路径
-derivedDataPath

// 指定生产result的文件路径，其中会包含一个info.plist
-resultBundlePath

// .xcconfig文件的路径。构建target时使用自定义的设置。这些设置将覆盖所有其他设置，包括在命令行上的设置。
-xcconfig


// YES/NO 控制是否生成代码覆盖率
-enableCodeCoverage

// 使用 ISO 639-1 语种名称来指定 test 时的APP语言
-testLanguage

// 使用使用 ISO 3166-1 地区名称来指定 test 时的APP地区
-testRegion

// 通过destination描述来指定设备，例如'platform=iOS Simulator,name=iPhone 6s,OS=11.2'
-destination

// 指定搜索目标设备的超时时间，默认值是30秒
-destination-timeout

// 限制最多多少台并发测试
-maximum-concurrent-test-simulator-destinations

// 限制最多多少台真实设备并发测试
-maximum-concurrent-test-device-destinations


// 指定目录或单个XLIFF本地化文件的路径。
-localizationPath	
// 指定包含在本地化导出中的可选ISO 639-1语言，可以重复指定多种语言，可能被排除以指定导出仅包含开发语言字符串。
-exportLanguage


// .xctestrun文件的路径。只能在test-without-building操作中存在
-xctestrun

// 跳过指定的测试单元，然后test剩下的测试单元，测试单元可以是一个测试类或者测试方法。
-skip-testing

// 只test指定的测试单元，-only-testing优先于-skip-testing
-only-testing

// 限制并发测试，只能在指定的设备上串行测试
-disable-concurrent-testing

// 使用identifier或name指定的toolchain
-toolchain

// 打印将执行的命令，但不执行它们。
-dry-run, -n	

// 除了警告和错误外，不打印任何输出。
-quiet

// 显示Xcode和SDK许可协议。 允许接受许可协议，而无需启动Xcode本身。
-license

// 检查是否需要执行首次启动任务。
-checkFirstLaunchStatus

// 安装软件包并同意许可证。
-runFirstLaunch
```


### 2.3 actions

**clean**

```shell
xcodebuild clean
-workspace <xxx.workspace>
-scheme <schemeName>
-configuration <Debug|Release>
-sdk<sdkName>
```

**build**

```shell
xcodebuild build
-workspace <xxx.workspace>
-scheme <schemeName>
-configuration <Debug|Release>
-sdk<sdkName>
```

**build-for-testing**

在根目录执行build操作,要求指定一个scheme，然后会在derivedDataPath/Build/Products目录下生成一个.xctestrun文件，这个文件包含执行测试的必要信息。对于每个测试目标，它都包含测试主机路径的条目，一些环境变量，命令行参数等待

**test**

```shell
// 单元测试
xcodebuild test 
-project <projectName>
-scheme <schemeName>
-destination 'platform=iOS Simulator,name=iPhone 6s,OS=11.2' 
-configuration <Debug/Release>
-derivedDataPath <derivedDataPath>

// 针对某个target/类/方法进行测试
xcodebuild test 
-project <projectName>
-scheme <schemeName>
-destination 'platform=iOS Simulator,name=iPhone 6s,OS=11.2' 
-only-testing:TARGET_NAME/CLASS_NAME/FUNC_NAME 
-quiet

```

**test-without-build**

UI测试/单元测试，不进行代码编译，利用上次编译的缓存（包括工程编译+测试用例编译），进行重新跑测试。

```shell
xcodebuild test-without-building 
-project <projectName>
-scheme <schemeName>
-destination 'platform=iOS Simulator,name=iPhone 6s,OS=12.0' 
-only-testing:TARGET_NAME/CLASS_NAME/FUNC_NAME
```

UI测试,使用选项-xctestrun生产测试文件，进行测试调试。

```shell
//1.产生xctestrun文件
xcodebuild build-for-testing -project PROJECT_NAME.xcodeproj -scheme SCHEME_NAME 
-destination 'platform=iOS Simulator,name=iPhone 6s,OS=11.2' -
configuration Debug -derivedDataPath output

-derivedDataPath: derivedDataPath/Build/Products目录下生成一个.xctestrun文件,包含测试信息

//2.使用xctestrun文件（不带-workspace/-project/-scheme参数）
xcodebuild test-without-building -destination 'platform=iOS Simulator,name=iPhone 6s,OS=12.0' 
-xctestrun DerivedDataPath.xctestrun -only-testing:TARGET_NAME/CLASS_NAME/FUNC_NAME

-xctestrun：有这个选项就从指定的路径下寻找bundle，没有这个选项在derivedDataPath下寻找bundle
-only-testing:TARGET_NAME/CLASS_NAME/FUNC_NAME
```

> test 操作需要指定 destination，其他操作默认 Generic iOS Device

**archive**

```shell
xcodebuild
archive -archivePath <archivePath>
-project <projectName>
-scheme <schemeName> #从-list命令中获取
-configuration < Debug|Release>
-sdk <sdkName> #sdkName可从showsdks命令中获取
```

**export**

```shell
xcodebuild
-exportArchive
-archivePath <xcarchivepath>
-exportPath <destinationpath>
-exportOptionsPlist <plistpath>#这个plist文件可以通过打一次ipa包里面去获取，然后根据需求修改
```

**archive & export**

```shell
xcodebuild  -exportArchive
-archivePath <archivePath> #.archive文件的全路径 eg: .../.../XXX.xcarchive
-exportPath <exportPath> #ipa文件导出路径
-exportOptionsPlist <exportOptionsPlistPath> #exportOptionsPlist文件全路径 eg: .../.../XXX.plist
```

**analyze**

> TODO

**install**

build项目，会在.dst目录下生成一个.app文件,例如这路径。/tmp/UnitTest.dst/Applications/UnitTest.app

**本地化**

```shell
// 将本地化导出到XLIFF文件。 需要-project和-localizationPath。 不能与action一起使用。
-exportLocalizations

// 从XLIFF文件导入本地化。 需要-project和-localizationPath。 不能与action一起使用。
-importLocalizations
```

**create framework**




