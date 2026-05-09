# CodexBarMenuBar

A macOS Menu Bar Extra that visualizes your AI provider usage at a glance. Powered by [CodexBar](https://github.com/steipete/CodexBar) CLI.

## Features

- **Real-time usage bars** with color-coded progress (green -> yellow -> orange -> red)
- **30+ AI providers** supported: Claude, Cursor, Gemini, Copilot, Windsurf, ZAI, DeepSeek, and many more
- **Per-window metrics**: session usage, weekly usage, and provider-specific extra windows (e.g., Claude Designs, Daily Routines)
- **Countdown timers**: optional countdown bar and text for reset times
- **Balance display**: credit-based providers show remaining balance (e.g., DeepSeek `$44.15`)
- **Fully customizable**: toggle individual metrics (bar, percentage, countdown bar, countdown text) per window per provider
- **Drag-and-drop reordering** of providers in settings
- **Native macOS settings** with tabbed interface (General, Providers, About)
- **Launch at Login** support

## Prerequisites

- macOS 15.0+
- [CodexBar CLI](https://github.com/steipete/CodexBar) installed at `/opt/homebrew/bin/codexbar`

Install CodexBar:
```bash
brew install steipete/tap/codexbar
```

## Installation

1. Download `CodexBarMenuBar.zip` from [Releases](../../releases)
2. Unzip and drag `CodexBarMenuBar.app` to `/Applications`
3. Launch the app — it appears in the menu bar, no Dock icon

Or build from source:
```bash
git clone https://github.com/user/CodexBarMenuBar.git
cd CodexBarMenuBar
open CodexBarMenuBar.xcodeproj
```
Then build and run with `Cmd+R` in Xcode.

## Supported Providers

| Type | Providers |
|------|-----------|
| **Usage Bar** | Claude, Codex, ZAI, Cursor, Gemini, Copilot, Windsurf, OpenCode, OC Go, Alibaba, Antigravity, Kiro, MiniMax, Kimi, Droid, Augment, JetBrains AI, Vertex AI, Mistral, Synthetic, Codebuff, Abacus AI, Perplexity, Amp, Ollama |
| **Balance** | DeepSeek, OpenRouter, Warp, Kilo, KimiK2 |

## How It Works

CodexBarMenuBar does **not** call any AI provider APIs directly. All data is fetched through the CodexBar CLI:

```
CodexBarMenuBar  -->  codexbar CLI  -->  AI Provider APIs
     (display)        (data fetch)       (authentication)
```

The app periodically runs `codexbar usage --provider <name> --format json` and renders the results in the menu bar.

## License

[MIT](LICENSE)

---

# CodexBarMenuBar

macOS 菜单栏扩展，实时可视化 AI 服务用量。基于 [CodexBar](https://github.com/steipete/CodexBar) CLI。

## 功能

- **实时用量进度条**，颜色随用量变化（绿 -> 黄 -> 橙 -> 红）
- **支持 30+ AI 提供商**：Claude、Cursor、Gemini、Copilot、Windsurf、ZAI、DeepSeek 等
- **多维度指标**：会话用量、周用量，以及提供商特有窗口（如 Claude 的 Designs、Daily Routines）
- **倒计时显示**：可选的倒计时进度条和文字，显示重置时间
- **余额显示**：按量付费的提供商直接显示余额（如 DeepSeek `$44.15`）
- **完全可定制**：每个提供商的每个指标窗口可独立开关（进度条、百分比、倒计时条、倒计时文字）
- **拖拽排序**：在设置中拖拽调整提供商显示顺序
- **原生 macOS 设置界面**：标签式布局（通用、提供商、关于）
- **开机自启**

## 前置条件

- macOS 15.0+
- 已安装 [CodexBar CLI](https://github.com/steipete/CodexBar)（路径 `/opt/homebrew/bin/codexbar`）

安装 CodexBar：
```bash
brew install steipete/tap/codexbar
```

## 安装

1. 从 [Releases](../../releases) 下载 `CodexBarMenuBar.zip`
2. 解压后将 `CodexBarMenuBar.app` 拖入 `/Applications`
3. 启动应用 — 直接出现在菜单栏，无 Dock 图标

或从源码构建：
```bash
git clone https://github.com/user/CodexBarMenuBar.git
cd CodexBarMenuBar
open CodexBarMenuBar.xcodeproj
```
在 Xcode 中 `Cmd+R` 运行。

## 工作原理

CodexBarMenuBar **不直接调用任何 AI 提供商 API**。所有数据通过 CodexBar CLI 获取：

```
CodexBarMenuBar  -->  codexbar CLI  -->  AI 提供商 API
     (显示)           (数据获取)         (认证)
```

应用定期运行 `codexbar usage --provider <name> --format json`，将结果渲染到菜单栏。

## 许可证

[MIT](LICENSE)
