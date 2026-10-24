# Changelog

## 2.0.0 - 2026-10-21

### Changed

重做整套界面（设计稿见 `design/`）。业务逻辑、riverpod 状态与 i18n key 全部保持不变，只重写视觉层。

**新增设计系统层 `lib/src/design/`**

- `tokens.dart`：间距刻度（`sp1`–`sp10`）、圆角、结构尺寸、动效曲线，与 `design/tokens.css` 的 CSS 变量一一对应。
- `colors.dart`：`SkColors`（`ThemeExtension`）——暖中性石墨底 + 三色强调（陶土橙 / 灰蓝 / 橄榄绿），深色为默认、浅色为覆盖。改配色只需改这一处。
- `theme.dart`：按上述令牌构建 `ThemeData`（字阶、按钮、输入框、对话框、菜单、滚动条等），旧版 deepOrange / cyan 主题已废弃。
- `kit/`：可复用组件库 —— `SkButton` / `SkIconButton` / `SkChip` / `SkSegmented` / `SkSwitch` / `SkSelect` / `SkSearchField` / `SkKbd`、`SkPanel` / `SkPanelHeader` / `SkListRow` / `SkNoteBar` / `SkEmptyState` / `SkStatTile` / `SkDivider`、`SkTitleBar` / `SkSidebar` / `SkPage` / `SkPageHeader` / `SkBrandMark`。

**应用外壳**

- 标题栏（`SkTitleBar`）：左侧窗口按钮，中间放品牌区（标记 + 软件名 + 版本号），右侧不再放任何操作（非 macOS 只剩自绘窗口按钮）。
- 移除标题栏右上角的设置按钮 —— 设置入口统一由侧边栏底部提供，不再重复。
- 移除标题栏中间的搜索框 —— 全局搜索仍可通过 `⌘K` / `⌘F` 快捷键唤出，标题栏不再占用这段空间。
- 移除标题栏右上角的「检查更新」按钮 —— 它检查的是 Sidekick 自身版本、与页面数据刷新无关，容易和页面刷新混淆；已挪到设置页「通用」面板的版本号那一行（`UpdateCheckButton`，有更新时才高亮为「立即更新」）。
- 侧边栏改为 232px 固定宽度（`SkSidebar`），替换原 `NavigationRail`：工作区分组 + 计数徽章、底部设置入口 + FVM 缓存目录 + 环境状态 chip。
- 「探索」更名为「发行版」，并在 22 个语言包中同步更新；发行版页内重复的 OHOS 渠道卡已移除（左侧独立 OHOS 入口保留）。

**离线与容错**

- 远端数据落盘缓存（`common/utils/remote_cache.dart`）：发行版列表与 OHOS 分支列表每次成功拉取后都会把响应原文写到 `<应用支持目录>/remote_cache/`，网络不可用时回落到上一次的结果。缓存读写是尽力而为，失败即降级为「没有缓存」，不中断流程。
- 发行版列表改为永不抛错（`releases.service.dart`，取数顺序仍为 GitHub raw → Google storage → 磁盘缓存）：以前一发网络请求失败，整个 `releasesStateProvider` 就进入 error 态直接返回空状态，导致渠道卡（stable / beta / master / OHOS）整排消失、项目卡片里的版本选择器没有任何可选项、点了没反应。现在远端不可用时渠道卡与已安装版本照常渲染（它们只依赖本地缓存），只有「版本库」列表为空，并显示「发行版列表暂不可用」的说明。
- OHOS 分支列表同样带缓存回落（`fetchOhosBranches`）：只有「网络失败且从未成功过」才显示失败态与重试入口。
- 已安装版本页与发行版页的刷新按钮现在会同时重取远端列表并重扫本地缓存（`ref.invalidate(flutterReleasesProvider)` + `reloadState()`）。

**页面与组件**

- 已安装版本页：统计条（已安装 / 占用空间 / 待更新 / 可清理）+ 全局版本提示条 + 版本列表；页头由「清理未使用版本」按钮换成整页刷新按钮（清理入口已移除，未使用版本仍可在列表行里单独删除）。
- **每个版本都显示 Flutter 与 Dart 版本**：已安装版本列表、发行版版本库、OHOS 分支列表、发行版页渠道卡四处统一渲染 `Flutter x.y.z · Dart a.b.c`。新增 `ReleaseDto` 上的 `sdkFlutterVersion` / `sdkDartVersion` 作为唯一取值路径（本地缓存优先，缺失回落远端发行元数据），UI 侧共用 `SdkVersionMeta` 组件；详情抽屉也切到同一路径。远端元数据缺失 `dart_sdk_version`、缓存未 setup 或 OHOS 远端分支这类拿不到 Dart 版本的情况显示 `—` 占位，行结构不塌陷。渠道卡与 OHOS 卡因列宽较窄，两个版本号上下两行排布，下沿仍与同排卡片对齐。
- 项目页：页头操作区 + 响应式卡片网格；项目详情页保留原生 tab 结构，改为设计系统样式。
- 项目卡片：底部操作栏固定贴在卡片下沿（卡片等高 + 内部 `Spacer`），描述区占固定两行高度，卡片之间不再因内容长短而错位；不可用项目卡片同样贴底。
- 项目卡片的版本选择器：去掉外层再包一层的「胶囊套矩形」，只保留单一描边控件；去掉选择器前面的安装状态对号，版本号改为等宽字体，下沿只留版本号与展开箭头。
- 发行版页：渠道卡（stable / beta / master / OHOS）的说明区固定三行高度，底部版本号与安装按钮用 `Spacer` 顶到卡片下沿，同一行卡片的下沿对齐。
- OHOS 页：fork 说明 hero + 筛选栏 + 分支列表；hero 右侧的统计项与「打开仓库」按钮固定在提示条右边缘，不随窗口变宽而漂移；分支列表每行末尾加分割线，与发行版列表一致。
- 版本详情抽屉：键值对分区布局 + 分区标题 + 复制按钮；设置页：左侧分区导航 + 右侧面板式设置项。
- 搜索浮层、兼容性检查页、Terminal Playground、各对话框与下拉菜单统一到设计系统。

**清理**

- 删除已被设计系统取代的旧原子组件：`components/atoms/typography.dart`、`components/molecules/list_tile.dart`、`components/organisms/screen.dart`。
- 删除「清理未使用版本」对话框（`fvm/dialogs/cleanup_unused_dialog.dart`）与它的 6 个 i18n key；未使用版本仍可在列表行里通过删除按钮单独移除。

**构建与发布**

- 重写 `.github/workflows/release.yml`：推一个 `v*` tag 即自动出齐三平台产物并创建 Release，不再依赖上游的 `cider` / `svenstaro/upload-release-action` / 上游证书 secret。
  - Linux：`sidekick-linux-<ver>-x86_64.tar.gz`（解压即用）+ AppImage
  - macOS：`sidekick-macos-<ver>.zip`（含 .app）+ DMG
  - Windows：`sidekick-windows-<ver>-x64.zip`（免安装 exe）+ MSIX
- 新增 `tool/ci_stamp.dart`：打包前把 tag 版本号写进 `pubspec.yaml` 与 `lib/src/version.dart`，避免手工改版本号漏改一处。
- 三平台统一锁定 Flutter `3.47.7`（workflow 里的 `FLUTTER_VERSION`）。
- `appimage-builder` / `create-dmg` 两步设为 `continue-on-error`：这两个工具偶发失败时不再让整个 release 挂掉，tar.gz 与 zip 已覆盖同一平台。
- Windows 签名改为每次生成一次性自签名证书（上游 `SIDEKICK-CERT.pfx` 的密码在别人的 secret 里）：产物可装可跑，但用户首次安装需手动信任，或改成自有 `.pfx`。

## 0.1.1 - 2021-06-19

### Added

- Github trending repos
- Flutter favorites

## 0.1.0 - 2021-06-16

### Fixed

- Issue when theme brightness does not match platform brightness

## 0.0.9 - 2021-06-15

### Changed

- Updated releases endpoint

## 0.0.8 - 2021-06-03

### Fixed

- master channel not showing in installed releases

## 0.0.7 - 2021-06-02

### Changed

- Projects are now added explicitly
