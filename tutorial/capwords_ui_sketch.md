# CapWords UI 设计简图

## 📱 整体应用布局结构

```
iPhone 屏幕比例 (375x812pt)
┌─────────────────────────────────────┐
│              Status Bar              │ 44pt
├─────────────────────────────────────┤
│                                     │
│            核心功能区域              │ 724pt
│                                     │
├─────────────────────────────────────┤
│            Home Indicator            │ 34pt
└─────────────────────────────────────┘
```

## 🎯 Onboarding 模块 UI 设计

### 页面 1: 欢迎页面
```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│                                     │
│         [Logo: HackWords]           │
│                                     │
│                                     │
│         字体: 48pt Bold             │
│         颜色: 深蓝色                │
│                                     │
│                                     │
│                                     │
│      [Continue 按钮]                │
│      高度: 56pt                     │
│      背景: 蓝色                     │
│      文字: 白色 18pt                │
│      圆角: 28pt                     │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

### 页面 2: 年龄选择
```
┌─────────────────────────────────────┐
│            ← Back                   │
│                                     │
│     How old are you?                │
│     字体: 28pt Bold                 │
│                                     │
│     Select your age group           │
│     字体: 16pt Regular              │
│                                     │
│                                     │
│  ┌─────────────────────────────┐    │
│  │        Under 18             │    │
│  │        高度: 80pt           │    │
│  │        背景: 浅灰色         │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │        18-25                │    │
│  │        高度: 80pt           │    │
│  │        背景: 蓝色(选中)     │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │        26+                  │    │
│  │        高度: 80pt           │    │
│  │        背景: 浅灰色         │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

### 页面 3: 语言选择
```
┌─────────────────────────────────────┐
│            ← Back                   │
│                                     │
│     Choose your language           │
│     字体: 28pt Bold                 │
│                                     │
│     Select preferred language      │
│     字体: 16pt Regular              │
│                                     │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  🇺🇸  English               │    │
│  │      Learn words in English │    │
│  │      高度: 100pt            │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  🇨🇳  中文                  │    │
│  │      用中文学习单词         │    │
│  │      高度: 100pt            │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  🇯🇵  日本語                │    │
│  │      日本語で単語を学習     │    │
│  │      高度: 100pt            │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

## 📚 WordBook 模块 UI 设计

### 主应用页面
```
┌─────────────────────────────────────┐
│                                     │
│  ☰             ⚙️                  │
│                                     │
│  Good morning! 👋                   │
│  字体: 24pt Bold                    │
│                                     │
│  You've learned 15 words today      │
│  字体: 16pt Regular                 │
│                                     │
│                                     │
│                                     │
│       ┌─────────────┐               │
│       │             │               │
│       │   📷        │               │
│       │  Camera     │               │
│       │   Button    │               │
│       │   120pt     │               │
│       │   直径      │               │
│       └─────────────┘               │
│                                     │
│       Tap to capture word           │
│       字体: 14pt Regular            │
│                                     │
│                                     │
│  Today's Words                     │
│  字体: 18pt Bold                    │
│                                     │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐    │
│  │ 🖼️  │ │ 🖼️  │ │ 🖼️  │ │ 🖼️  │    │
│  │     │ │     │ │     │ │     │    │
│  └─────┘ └─────┘ └─────┘ └─────┘    │
│                                     │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐    │
│  │ 🖼️  │ │ 🖼️  │ │ 🖼️  │ │ 🖼️  │    │
│  │     │ │     │ │     │ │     │    │
│  └─────┘ └─────┘ └─────┘ └─────┘    │
│                                     │
└─────────────────────────────────────┘
```

### 相机页面
```
┌─────────────────────────────────────┐
│            × Cancel                 │
│                                     │
│                                     │
│                                     │
│                                     │
│         [Camera Preview]           │
│         占满大部分屏幕              │
│                                     │
│                                     │
│                                     │
│                                     │
│       ┌─────────────┐               │
│       │             │               │
│       │   📷        │               │
│       │  Capture    │               │
│       │   Button    │               │
│       │   120pt     │               │
│       │   直径      │               │
│       └─────────────┘               │
│                                     │
│       Take photo of word            │
│       字体: 14pt Regular            │
│                                     │
└─────────────────────────────────────┘
```

## 💰 VipConversion 模块 UI 设计

### 付费转化页面
```
┌─────────────────────────────────────┐
│            × Close                  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │     [渐变背景]               │    │
│  │                             │    │
│  │    [Premium Logo]           │    │
│  │                             │    │
│  │    Unlock Premium           │    │
│  │    Features                 │    │
│  │                             │    │
│  │    字体: 32pt Bold          │    │
│  │    颜色: 白色                │    │
│  └─────────────────────────────┘    │
│                                     │
│  ✅ Unlimited word captures         │
│  ✅ Advanced AI analysis            │
│  ✅ Offline learning mode          │
│  ✅ Priority support               │
│                                     │
│  字体: 16pt Regular                 │
│  颜色: 深灰色                       │
│                                     │
│                                     │
│  ┌─────────┐  ┌─────────┐           │
│  │  Monthly │  │  Yearly │           │
│  │  $9.99   │  │  $59.99 │           │
│  │  Save 50%│  │         │           │
│  └─────────┘  └─────────┘           │
│  高度: 60pt                         │
│  背景: 浅灰色                       │
│  选中: 蓝色边框                     │
│                                     │
│                                     │
│       [Start Free Trial]           │
│       高度: 56pt                   │
│       背景: 蓝色                   │
│       文字: 白色                   │
│       圆角: 28pt                   │
│                                     │
│       7 days free, then $9.99/month│
│       字体: 12pt Regular           │
│                                     │
│  🔔 Remind me before trial ends    │
│                                     │
│  Terms & Privacy Policy            │
│  字体: 12pt Regular                 │
│  颜色: 浅蓝色                       │
│                                     │
└─────────────────────────────────────┘
```

## 🎨 设计系统规范

### 颜色方案
```
主色调:
- Primary Blue: #007AFF
- Background: #FFFFFF (Light) / #000000 (Dark)
- Text Primary: #000000 (Light) / #FFFFFF (Dark)
- Text Secondary: #8E8E93 (Light) / #636366 (Dark)

转化页:
- Dark Background: #000D1A
- Gradient: Blue to Purple
- Accent Gold: #FFD700
```

### 字体层级
```
- Large Title: 48pt Bold
- Title 1: 28pt Bold
- Title 2: 24pt Bold
- Headline: 18pt Semibold
- Body: 16pt Regular
- Caption: 14pt Regular
- Footnote: 12pt Regular
```

### 间距系统
```
- Page Padding: 24pt
- Component Spacing: 16pt
- Card Padding: 20pt
- Button Height: 56pt
- Corner Radius: 12pt (Cards), 28pt (Buttons)
```

### 交互状态
```
按钮状态:
- Normal: 100% opacity
- Pressed: 98% scale + 0.1s animation
- Disabled: 30% opacity
- Loading: ProgressView + disabled state
```

## 📐 布局原则

### 屏幕适配
```
iPhone SE (375x667): 基础布局
iPhone 12/13 (390x844): 标准布局
iPhone 12/13 Pro Max (428x926): 大屏布局
iPad: 150pt 边距, 更大字体
```

### 安全区域
```
Top: Status Bar + 16pt
Bottom: Home Indicator + 16pt
Left/Right: 16pt (Standard), 24pt (Premium)
```

这个 UI 设计简图展示了 CapWords 应用的核心界面结构，适合用于现场演示和教学。每个界面都遵循了现代 iOS 设计规范，具有良好的视觉层次和用户体验。