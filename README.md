<div align="center">

**[English](#codexbarmenubar) | [简体中文](#codexbarmenubar中文)**

</div>

# CodexBarMenuBar 📊 — Your AI usage, always one glance away.

> Every AI provider's quota, right in your macOS menu bar.

[![Release](https://img.shields.io/github/v/release/Lobobodev/CodexBarMenuBar?label=release&color=blue)](https://github.com/Lobobodev/CodexBarMenuBar/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/Lobobodev/CodexBarMenuBar/total?label=downloads&color=brightgreen)](https://github.com/Lobobodev/CodexBarMenuBar/releases)
[![macOS](https://img.shields.io/badge/macOS-15%2B-blue)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)
[![brew](https://img.shields.io/badge/brew-Lobobodev%2Ftap%2Fcodexbarmenubar-orange)](https://github.com/Lobobodev/homebrew-tap)
[![Signed](https://img.shields.io/badge/signed-Developer%20ID%20%2B%20Notarized-success)](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)
[![License](https://img.shields.io/badge/license-MIT-purple)](LICENSE)

---

### ⚡ See your AI usage at a glance — right in the macOS menu bar.

**No need to open CodexBar.app. No clicks. No switching apps.** Just look up to the menu bar and instantly know how much Claude, Codex, ZAI, DeepSeek and 35+ other AI providers you've used today.

> ⚠️ **Requires [CodexBar CLI](https://github.com/steipete/CodexBar).** This app does NOT call AI provider APIs directly — all data is fetched through CodexBar CLI. Without CodexBar CLI, this app shows nothing.

![Menu Bar Screenshot](screenshots/menubar.png)

In the screenshot, three providers are shown side-by-side in the menu bar:
- **Claude**: green usage bar with `19% W:2%` (session and weekly)
- **ZAI**: usage bar with `0% W:1%`
- **DeepSeek**: balance `¥44.15`

That's it — your AI quota always visible, never hidden behind another window.

### Customizable in Settings

![Settings Screenshot](screenshots/settings.png)

Drag-to-reorder providers, toggle each metric independently (Bar, %, ⏱ Bar, ⏱ Text), enable/disable any provider with one click.

## Why this exists — and a note to CodexBar's maintainer 🙏

[**CodexBar**](https://github.com/steipete/CodexBar) already has a built-in "merged menu bar mode" that can display multiple providers side-by-side. **CodexBarMenuBar exists as a UI experiment**, adding finer visual controls on top of CodexBar's data:

| Feature | CodexBar (merged mode) | CodexBarMenuBar |
|---|---|---|
| Multiple providers in menu bar | ✅ | ✅ |
| Usage percentage text | ✅ | ✅ |
| **Color-coded progress bars** (green → yellow → orange → red) | ❌ text only | ✅ |
| **Countdown bar** for reset time | ❌ | ✅ |
| **Countdown text** ("1h 23m left") visible directly | ❌ click to view | ✅ |
| **Per-window display toggles** (4 independent checkboxes per metric) | ❌ global toggle | ✅ |
| Open source | ❌ | ✅ MIT |

> **Dear [@steipete](https://github.com/steipete) and CodexBar community** — these visualizations would be a wonderful addition to CodexBar itself. If they ever land upstream, **this project happily becomes obsolete** and we'd recommend everyone uninstall this in favor of CodexBar's native implementation. Until then, this app serves as a reference UI / playground for what those features could look like. CodexBarMenuBar uses the CodexBar CLI under the hood and would not exist without it — huge thanks. 🙏

If you're satisfied with CodexBar's built-in merged mode, **you don't need this app**.

## Versioning

**This app's version tracks [CodexBar CLI](https://github.com/steipete/CodexBar) version.** For example, CodexBarMenuBar `0.30.0` matches CodexBar CLI `0.30.0`. Always install the matching version of both.

## Features

- **Real-time usage bars** with color-coded progress (green -> yellow -> orange -> red)
- **48 AI providers** supported: Claude, Cursor, Gemini, Copilot, Windsurf, ZAI, DeepSeek, OpenAI, Grok, Bedrock, ElevenLabs, Deepgram, and many more
- **Per-window metrics**: session usage, weekly usage, and provider-specific extra windows (e.g., Claude Designs, Daily Routines)
- **Countdown timers**: optional countdown bar and text for reset times
- **Balance display**: credit-based providers show remaining balance (e.g., DeepSeek `¥44.15`)
- **Fully customizable**: toggle individual metrics (bar, percentage, countdown bar, countdown text) per window per provider
- **Drag-and-drop reordering** of providers in settings
- **Native macOS settings** with tabbed interface (General, Providers, About)
- **Account info display**: shows account organization and data source per provider
- **Launch at Login** support

## Prerequisites

1. macOS 15.0+
2. **[CodexBar](https://github.com/steipete/CodexBar) installed and configured with your AI provider accounts.** Install CodexBar (the CLI provider) via Homebrew:
   ```bash
   brew install --cask codexbar
   ```
   After installation, open CodexBar.app and log in to the AI providers you want to monitor.

## Installation

### Option A: Homebrew (recommended)
```bash
brew install --cask Lobobodev/tap/codexbarmenubar
```
Automatically installs CodexBar CLI too. Upgrade with `brew upgrade --cask codexbarmenubar`.

### Option B: Direct download via curl
```bash
curl -L -o CodexBarMenuBar.zip https://github.com/Lobobodev/CodexBarMenuBar/releases/latest/download/CodexBarMenuBar-v0.30.0.zip
unzip CodexBarMenuBar.zip -d /Applications/
open /Applications/CodexBarMenuBar.app
```

### Option C: Manual download
1. Download `CodexBarMenuBar-v0.30.0.zip` from [Releases](../../releases)
2. Unzip and drag `CodexBarMenuBar.app` to `/Applications`
3. Double-click — no Gatekeeper warnings (app is signed & notarized by Apple)

### Build from source
```bash
git clone https://github.com/Lobobodev/CodexBarMenuBar.git
cd CodexBarMenuBar
open CodexBarMenuBar.xcodeproj
```
Then build and run with `Cmd+R` in Xcode.

## Supported Providers (matches CodexBar CLI 0.30+)

| Type | Providers |
|------|-----------|
| **Usage Bar** | Claude, Codex, ZAI, Cursor, Gemini, Copilot, Windsurf, OpenCode, OC Go, Alibaba, Antigravity, Kiro, MiniMax, Kimi, Droid, Augment, JetBrains AI, Vertex AI, Mistral, Synthetic, Codebuff, Abacus AI, Perplexity, Amp, Ollama, Manus, MiMo, CmdCode, StepFun, ElevenLabs, Groq, LLM Proxy, Deepgram, Azure OpenAI, T3 Chat, Bailian (Alibaba Token Plan) |
| **Balance** | DeepSeek, OpenRouter, Warp, Kilo, KimiK2, OpenAI, Moonshot, Doubao, Crof, Venice, Bedrock, Grok |

## How It Works

```
CodexBarMenuBar  -->  codexbar CLI  -->  AI Provider APIs
     (display)        (data fetch)       (authentication)
```

The app periodically runs `codexbar usage --provider <name> --format json` and renders the results in the menu bar.

## License

[MIT](LICENSE)

---

# CodexBarMenuBar 📊（中文）— AI 用量一眼可见

> 所有 AI 提供商的额度，直接显示在你的 macOS 菜单栏。

[![Release](https://img.shields.io/github/v/release/Lobobodev/CodexBarMenuBar?label=最新版本&color=blue)](https://github.com/Lobobodev/CodexBarMenuBar/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/Lobobodev/CodexBarMenuBar/total?label=下载量&color=brightgreen)](https://github.com/Lobobodev/CodexBarMenuBar/releases)
[![macOS](https://img.shields.io/badge/macOS-15%2B-blue)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)
[![brew](https://img.shields.io/badge/brew-Lobobodev%2Ftap%2Fcodexbarmenubar-orange)](https://github.com/Lobobodev/homebrew-tap)
[![Signed](https://img.shields.io/badge/%E7%AD%BE%E5%90%8D-Developer%20ID%20%2B%20%E5%85%AC%E8%AF%81-success)](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)
[![License](https://img.shields.io/badge/%E8%AE%B8%E5%8F%AF%E8%AF%81-MIT-purple)](LICENSE)

---

### ⚡ AI 用量一眼可见 — 直接显示在 macOS 顶部菜单栏

**不用打开 CodexBar.app，不用点击，不用切换窗口。** 抬头看一眼菜单栏，立刻知道今天的 Claude、Codex、ZAI、DeepSeek 等 35+ 个 AI 用了多少。

> ⚠️ **需要先安装 [CodexBar CLI](https://github.com/steipete/CodexBar)。** 本应用**不直接调用任何 AI 提供商 API**，所有数据通过 CodexBar CLI 获取。没有 CodexBar CLI，本应用什么都不会显示。

![菜单栏截图](screenshots/menubar.png)

上图展示了菜单栏中并列显示的三个 AI 提供商：
- **Claude**：绿色进度条 `19% W:2%`（会话和周用量）
- **ZAI**：进度条 `0% W:1%`
- **DeepSeek**：余额 `¥44.15`

AI 用量始终在你眼前，再也不用埋在别的窗口里。

### 设置界面可自由定制

![设置界面截图](screenshots/settings.png)

拖拽调整 Provider 顺序，每项指标（进度条 / 百分比 / 倒计时条 / 倒计时文字）独立开关，一键启用/禁用任何 Provider。

## 这个项目存在的意义 —— 给 CodexBar 作者的一封信 🙏

[**CodexBar**](https://github.com/steipete/CodexBar) 自带"合并菜单栏模式"（merged menu bar mode），可以在菜单栏同时显示多个 Provider。**CodexBarMenuBar 是一个 UI 实验项目**，在 CodexBar 的数据之上提供更精细的可视化控制：

| 功能 | CodexBar（合并模式） | CodexBarMenuBar |
|---|---|---|
| 多 Provider 并排显示 | ✅ | ✅ |
| 百分比文字 | ✅ | ✅ |
| **彩色进度条**（绿 → 黄 → 橙 → 红） | ❌ 纯文字 | ✅ |
| **重置倒计时条** | ❌ | ✅ |
| **直接显示倒计时文字**（"还剩 1h 23m"） | ❌ 需要点开 | ✅ |
| **per-window 独立开关**（每个指标 4 个独立 checkbox） | ❌ 全局开关 | ✅ |
| 开源 | ❌ | ✅ MIT |

> **致 [@steipete](https://github.com/steipete) 和 CodexBar 社区** —— 如果上述这些可视化能直接进入 CodexBar 本体，那就太好了。一旦合并上去，**这个项目会愉快地停止维护**，并建议所有用户卸载它、改用 CodexBar 原生实现。在那之前，本项目作为一个参考 UI / 想法的"游乐场"存在。CodexBarMenuBar 完全依赖 CodexBar CLI 提供数据，没有它就没有本项目 —— 衷心感谢。🙏

如果你觉得 CodexBar 自带的合并模式已经够用，**那你不需要这个 app**。

## 版本号说明

**本应用的版本号跟随 [CodexBar CLI](https://github.com/steipete/CodexBar) 版本。** 例如 CodexBarMenuBar `0.30.0` 对应 CodexBar CLI `0.30.0`。请始终安装版本相匹配的两个程序。

## 功能

- **实时用量进度条**，颜色随用量变化（绿 -> 黄 -> 橙 -> 红）
- **支持 48 个 AI 提供商**：Claude、Cursor、Gemini、Copilot、Windsurf、ZAI、DeepSeek、OpenAI、Grok、Bedrock、ElevenLabs、Deepgram 等
- **多维度指标**：会话用量、周用量，以及提供商特有窗口（如 Claude 的 Designs、Daily Routines）
- **倒计时显示**：可选的倒计时进度条和文字，显示重置时间
- **余额显示**：按量付费的提供商直接显示余额（如 DeepSeek `¥44.15`）
- **完全可定制**：每个提供商的每个指标窗口可独立开关（进度条、百分比、倒计时条、倒计时文字）
- **拖拽排序**：在设置中拖拽调整提供商显示顺序
- **原生 macOS 设置界面**：标签式布局（通用、提供商、关于）
- **账号信息显示**：详情页显示账号所属组织和数据来源
- **开机自启**

## 前置条件

1. macOS 15.0+
2. **已安装并配置好 [CodexBar](https://github.com/steipete/CodexBar)**（数据提供方）。通过 Homebrew 安装：
   ```bash
   brew install --cask codexbar
   ```
   安装后打开 CodexBar.app，登录你想监控的 AI 提供商账号。

## 安装

### 方式 A：Homebrew（推荐）
```bash
brew install --cask Lobobodev/tap/codexbarmenubar
```
会自动一起装 CodexBar CLI。升级用 `brew upgrade --cask codexbarmenubar`。

### 方式 B：curl 直接下载
```bash
curl -L -o CodexBarMenuBar.zip https://github.com/Lobobodev/CodexBarMenuBar/releases/latest/download/CodexBarMenuBar-v0.30.0.zip
unzip CodexBarMenuBar.zip -d /Applications/
open /Applications/CodexBarMenuBar.app
```

### 方式 C：手动下载
1. 从 [Releases](../../releases) 下载 `CodexBarMenuBar-v0.30.0.zip`
2. 解压后将 `CodexBarMenuBar.app` 拖入 `/Applications`
3. 双击启动 — 无 Gatekeeper 警告（应用已签名 + Apple 公证）

### 从源码构建
```bash
git clone https://github.com/Lobobodev/CodexBarMenuBar.git
cd CodexBarMenuBar
open CodexBarMenuBar.xcodeproj
```
在 Xcode 中 `Cmd+R` 运行。

## 支持的 Provider（对应 CodexBar CLI 0.30+）

| 类型 | Provider |
|------|----------|
| **用量进度条** | Claude, Codex, ZAI, Cursor, Gemini, Copilot, Windsurf, OpenCode, OC Go, Alibaba, Antigravity, Kiro, MiniMax, Kimi, Droid, Augment, JetBrains AI, Vertex AI, Mistral, Synthetic, Codebuff, Abacus AI, Perplexity, Amp, Ollama, Manus, MiMo, CmdCode, StepFun, ElevenLabs, Groq, LLM Proxy, Deepgram, Azure OpenAI, T3 Chat, Bailian (Alibaba Token Plan) |
| **余额显示** | DeepSeek, OpenRouter, Warp, Kilo, KimiK2, OpenAI, Moonshot, Doubao, Crof, Venice, Bedrock, Grok |

## 工作原理

```
CodexBarMenuBar  -->  codexbar CLI  -->  AI 提供商 API
     (显示)           (数据获取)         (认证)
```

应用定期运行 `codexbar usage --provider <name> --format json`，将结果渲染到菜单栏。

## 许可证

[MIT](LICENSE)
