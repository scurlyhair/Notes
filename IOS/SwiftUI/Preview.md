# Preview

组织多个 Preview 有两种方式：

```swift
// Method A:
ForEach(["iPhone XS", "iPhone SE"], id: \.self) {
    ContentView()
        .previewDevice(PreviewDevice(rawValue: $0))
        .previewDisplayName($0)
}

// Method B:
Group {
    ContentView()
        .previewDevice(PreviewDevice(rawValue: "iPhone XS"))
        .previewDisplayName("iPhone XS")
    
    ContentView()
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("iPhone SE")
}
```

SwiftUI Preview Device Type

```
"Mac"
"iPhone 7"
"iPhone 7 Plus"
"iPhone 8"
"iPhone 8 Plus"
"iPhone SE"
"iPhone X"
"iPhone Xs"
"iPhone Xs Max"
"iPhone Xr"
"iPad mini 4"
"iPad Air 2"
"iPad Pro (9.7-inch)"
"iPad Pro (12.9-inch)"
"iPad (5th generation)"
"iPad Pro (12.9-inch) (2nd generation)"
"iPad Pro (10.5-inch)"
"iPad (6th generation)"
"iPad Pro (11-inch)"
"iPad Pro (12.9-inch) (3rd generation)"
"iPad mini (5th generation)"
"iPad Air (3rd generation)"
"Apple TV"
"Apple TV 4K"
"Apple TV 4K (at 1080p)"
"Apple Watch Series 2 - 38mm"
"Apple Watch Series 2 - 42mm"
"Apple Watch Series 3 - 38mm"
"Apple Watch Series 3 - 42mm"
"Apple Watch Series 4 - 40mm"
"Apple Watch Series 4 - 44mm"
```