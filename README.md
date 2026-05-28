# 🧮 Calculator — iOS SwiftUI App

一个简洁优雅的 iOS 计算器应用，使用 SwiftUI 构建。

## 功能

- ➕➖✖️➗ 四则运算
- 小数点支持
- 正负号切换
- 百分比计算
- 连续运算
- 自适应字号显示
- 按压动画反馈

## 在 Mac 上运行

### 方式一：XcodeGen（推荐）

`ash
# 1. 安装 XcodeGen
brew install xcodegen

# 2. 生成 Xcode 项目
cd Calculator
xcodegen generate

# 3. 打开项目
open Calculator.xcodeproj
`

### 方式二：手动创建

1. 打开 Xcode → New Project → iOS → App
2. Product Name: Calculator, Interface: SwiftUI, Language: Swift
3. 将 Calculator/ 下的 4 个 .swift 文件拖入项目

### 需求

- Xcode 15+
- iOS 17.0+
