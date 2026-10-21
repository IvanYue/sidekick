# Changelog

## 1.2.0 - 2026-10-21

### Changed

重做整套界面（设计稿见 `design/`）。业务逻辑、riverpod 状态与 i18n key 全部保持不变，只重写视觉层。

**新增设计系统层 `lib/src/design/`**

- `tokens.dart`：间距刻度（`sp1`–`sp10`）、圆角、结构尺寸、动效曲线，与 `design/tokens.css` 的 CSS 变量一一对应。
- `colors.dart`：`SkColors`（`ThemeExtension`）——暖中性石墨底 + 三色强调（陶土橙 / 灰蓝 / 橄榄绿），深色为默认、浅色为覆盖。改配色只需改这一处。
- `theme.dart`：按上述令牌构建 `ThemeData`（字阶、按钮、输入框、对话框、菜单、滚动条等），旧版 deepOrange / cyan 主题已废弃。
- `kit/`：可复用组件库 —— `SkButton` / `SkIconButton` / `SkChip` / `SkSegmented` / `SkSwitch` / `SkSelect` / `SkSearchField` / `SkKbd`、`SkPanel` / `SkPanelHeader` / `SkListRow` / `SkNoteBar` / `SkEmptyState` / `SkStatTile` / `SkDivider`、`SkTitleBar` / `SkSidebar` / `SkPage` / `SkPageHeader` / `SkBrandMark`。

**应用外壳**

- 标题栏改为三段式（`SkTitleBar`）：左侧品牌 + 版本号、居中 300px 搜索框、右侧更新/设置按钮；保留窗口拖拽与 macOS 原生交通灯。
- 侧边栏改为 232px 固定宽度（`SkSidebar`），替换原 `NavigationRail`：工作区分组 + 计数徽章、底部设置入口 + FVM 缓存目录 + 环境状态 chip。
- 「探索」更名为「发行版」，并在 22 个语言包中同步更新；发行版页内重复的 OHOS 渠道卡已移除（左侧独立 OHOS 入口保留）。

**页面与组件**

- 已安装版本页：统计条（已安装 / 占用空间 / 待更新 / 可清理）+ 全局版本提示条 + 版本列表。
- 项目页：页头操作区 + 响应式卡片网格；项目详情页保留原生 tab 结构，改为设计系统样式。
- 发行版页：渠道展示卡 + 筛选栏 + 版本列表；OHOS 页：fork 说明 hero + 筛选栏 + 分支列表。
- 版本详情抽屉：键值对分区布局 + 分区标题 + 复制按钮；设置页：左侧分区导航 + 右侧面板式设置项。
- 搜索浮层、兼容性检查页、Terminal Playground、各对话框与下拉菜单统一到设计系统。

**清理**

- 删除已被设计系统取代的旧原子组件：`components/atoms/typography.dart`、`components/molecules/list_tile.dart`、`components/organisms/screen.dart`。
- 「检查更新」按钮改为图标按钮，点击可手动重新检测最新版本。

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
