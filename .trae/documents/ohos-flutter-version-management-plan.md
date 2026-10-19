# OHOS Flutter 版本管理功能实现计划

## Context

用户需要 Sidekick 支持 OpenHarmony Flutter fork 的版本管理（浏览/安装/更新/删除），与官方 Flutter 版本同等功能。OHOS 仓库：`https://gitcode.com/CPF-Flutter/flutter_flutter.git`，版本以 `oh-<版本>-release` / `oh-<版本>-dev` 分支维护（实测 ls-remote：3.41.9、3.44.9、3.35.7 等均有 release/dev 分支）。

**已确认决策**：侧边栏独立第 4 页面入口「OHOS」；release + dev 分支都显示；安装 clone 分支；更新 = `git pull --ff-only` 到分支最新。约束：不动 `/Users/jdny/fvm` 下已装内容和本机旧版 fvm CLI 的配置。

## 核心机制结论（已逐行核实 fvm 4.3.2 源码）

### 复用 fvm 原生 fork 机制（不自造轮子）
- **fork 注册**：`AppConfig.forks`（`FlutterFork{name, url}`）持久化于 `~/Library/Application Support/fvm/.fvmrc`（fvm 包常量 `kAppConfigFile`，本机不存在该文件 → 全新创建，与旧 CLI 的 `~/fvm/.settings` 互不干扰）。写入方式照抄 `ForkAddCommand`（`LocalAppConfig.read(path:)..forks.add(..)..save(path:)`，read-modify-write 保留已有 forks）
- **安装链路 100% 复用**：`fvmQueueProvider.install` → `EnsureCacheWorkflow` → `FlutterService.install` → `_resolveRepositoryUrl`（`version.fromFork` 时 `context.getForkUrl('ohos')`）→ clone + checkout 分支到 `~/fvm/versions/ohos/<分支名>`。clone 输出经 sidekick 的 `_ConsoleProcessService` 流入 AppBottomBar 控制台
- **枚举**：`CacheService.getAllVersions` 原生扫描 fork 子目录；`unknownRef` 类型绕过"目录名 vs SDK version"的 mismatch 校验（OHOS version 文件是 `3.41.9+ohos-1.0.2` 格式，校验必挂，unknownRef 是唯一可行路径）
- **删除**：`CacheService.remove` 原生支持 fork 目录并自动清理空 fork 目录

### 关键纠偏：name 前缀规则（本轮最大发现，必守契约）
- `FlutterVersion.parse('ohos/oh-3.41.9-release')` → `.name = 'oh-3.41.9-release'`（**不带前缀**）、`.fork = 'ohos'`、`.nameWithAlias = 'ohos/oh-3.41.9-release'`（带前缀 getter）
- `CacheFlutterVersion.name` 同样不带前缀；`getGlobalVersion()` 返回**带前缀**的 `'ohos/<分支名>'`
- **契约**：入队 `VersionDto.name` 一律用带前缀的 `'ohos/<分支名>'`（runQueue 里 `FlutterVersion.parse(name)` 靠前缀解析 fork）；已装匹配一律 `cache.fork == 'ohos' && cache.name == 分支名`（即 `nameWithAlias`）

### 上轮遗留缺陷修复（必须先做）
`releases.provider.dart` 的 `addUntrackedCachedVersions`（L116-135）用 `cached.name`（不带前缀）合成 `VersionDto.name` → fork 版本在 FVM 首页执行 remove/setup 时 `FlutterVersion.parse('oh-3.41.9-release')` 得 `fork=null` → 定位到不存在的顶层目录 → 静默失败；`isGlobal` 判断也因前缀分裂永远 false。**修法**：合成 name 与 isGlobal 判断改用 `cached.nameWithAlias`（官方版本 nameWithAlias==name，不影响现有测试）。

## 文件清单

### 新增 `lib/src/modules/ohos/`（遵循项目 service/provider/screen 分层）
| 文件 | 职责 |
|---|---|
| `ohos.constants.dart` | `kOhosForkName='ohos'`、`kOhosRepoUrl`、分支正则 `^oh-(?<version>\d+\.\d+\.\d+(?:\.\w+)*)(?<type>release\|dev)(?:-(?<extra>[\w.]+))?$`（兼容 `oh-3.7.12-dev-6.0` 变体；分支名原样保留用于 git 操作） |
| `ohos.dto.dart` | `OhosBranchType{release,dev}`、`OhosBranchDto{name原始分支名, type, version, extra?, sha, qualifiedName}`、`OhosBranchItem{branch?, cache?, localSha?, isGlobal}`（`isInstalled`/`updateAvailable` getter、`toVersionDto()` 构造入队契约） |
| `ohos.service.dart` | `ensureOhosForkRegistered({String? appConfigPath})`（幂等：name 匹配即跳过、不覆盖 url、try-catch 不阻断启动、**绝不引用 fvmContext**——它是 lazy final，引用即提前触发 `FvmContext.create` 读 .fvmrc；只用 `kAppConfigFile` 常量）；`fetchOhosBranches()`（`git ls-remote --heads` 经 `fvmContext.get<ProcessService>()`、60s 超时）；`parseOhosLsRemote(String)` 纯函数（单测主战场）；`getLocalHeadSha(directory)`（git rev-parse HEAD，失败 null）；`pullOhosBranch({directory, branch})`（`git pull --ff-only origin <branch>`，`echoOutput: true` 走控制台） |
| `ohos.provider.dart` | `ohosRemoteBranchesProvider`（FutureProvider，仅网络层，RefreshButton invalidate 它）+ `ohosBranchesProvider`（合并层：watch `fvmCacheProvider` 与远端结果，调 `mergeOhosBranches` 纯函数；缓存变化自动重算不重拉网络）+ `ohosFilterProvider`/`ohosFilterableProvider`（照抄 releases.provider 的 filter 模式） |
| `ohos.screen.dart` | SkScreen + CustomScrollView：说明条 + release/dev/all 筛选下拉（参考 releases.screen.dart L123-140）+ SliverList；loading→SkLoadingIndicator；error→EmptyDataset+重试按钮；空态→EmptyDataset |
| `components/ohos_branch_list_item.dart` | SkListTile：leading 按 release/dev 用 alphaR/alphaD 圆圈图标；title=分支名+类型 Chip+global 徽章；subtitle=sha 前 7 位+更新可用标记；trailing=未装→安装按钮（**队列 spinner 用 name 相等匹配**，勿复用 VersionInstallButton——它按对象 identity 判断会丢 spinner）/ 已装→更新按钮+`FvmReleaseActions(dto)` 整体复用（remove/detail/global 对带前缀 name 全部正确）；onTap 打开 SelectedDetail 抽屉 |

### 修改
| 文件 | 改动 |
|---|---|
| `lib/main.dart` | `runApp` 前 `await ensureOhosForkRegistered()`（容错吞异常） |
| `lib/src/modules/navigation/navigation.provider.dart` | `NavigationRoutes` 在 exploreScreen 与 settingsScreen 之间插入 `ohosScreen`（已核实：settingsScreen 无 UI 引用、searchScreen 仅 search_bar.dart L32 相等比较，插位安全） |
| `lib/src/modules/common/app_shell.dart` | pages 数组与枚举声明顺序对齐处插入 `OhosScreen()`；NavigationRail destinations 加第 4 个 `renderNavButton` |
| `lib/src/modules/fvm/fvm_queue.provider.dart` | `QueueAction` 加 `ohosUpdate`；`FvmQueueState.ohosUpdate(context, version)` 入队方法；`runQueue` switch 加 case：取 `item.version.cache!.directory`、`branch = name.split('/').last`、调 `pullOhosBranch`、成功 notify（`modules:ohos.ohosUpdated`）。失败被 runQueue 外层 catch → notifyError 显示 git 原始 stderr；完成后尾部统一 `reloadState()` 天然生效 |
| `lib/src/modules/releases/releases.provider.dart` | **修复 addUntrackedCachedVersions**：`VersionDto.name` 用 `cached.nameWithAlias`、isGlobal 用 `globalVersion == cached.nameWithAlias` |
| `localizations/*/modules.json` ×21 | 顶层加 `"ohos"` namespace（key 清单见下） |

### 安装数据流契约（核心）
`OhosBranchItem.toVersionDto()` → `VersionDto(name: 'ohos/oh-3.41.9-release', release: null, cache: item.cache, needSetup: ..., isGlobal: ...)` → `fvmQueueProvider.notifier.install(context, dto)`（不传 skipSetup，与官方页一致由设置决定 install vs installAndSetup）。**禁止**构造不带 `ohos/` 前缀的 OHOS VersionDto（会把 clone 打向官方仓库）。

### 合并逻辑（可测纯函数）
`mergeOhosBranches(remote, cached, localShaOf, globalVersion)`：远端↔已装按 `cache.name == branch.name` 配对；localSha 仅对已装项取；`updateAvailable = localSha != null && != branch.sha`（失败保守 false）；**孤儿分支**（本地已装但远端已删）保留展示（branch=null、更新禁用），否则已装版本从 OHOS 页凭空消失；`isGlobal = globalVersion == 'ohos/${cache.name}'`。

## i18n key 清单（`modules:ohos` namespace，21 个语言文件全加）
`navButtonOhos`(OHOS)、`title`、`ohosDescription`、`branches`、`release`、`dev`、`all`、`installedCount`、`noBranches`、`noBranchesMessage`、`fetchFailed`、`fetchFailedMessage`、`retry`、`installOhosVersion`、`updateOhosVersion`、`updateAvailable`、`upToDate`、`ohosUpdated`("{{itemVersionName}} has been updated")、`orphanBranch`。zh-CN/zh-TW 中文、en-US/en-GB 英文、其余 17 语言英文兜底。

## 实施顺序（依赖链）
1. `ohos.constants.dart` + `ohos.dto.dart` + `ohos.service.dart`（解析纯函数+fork 注册）→ 同步写 parser/registration 单测
2. `main.dart` 接入 ensureOhosForkRegistered
3. **修复 `releases.provider.dart` nameWithAlias** + 补 untracked 测试守护用例（fork 版本合成 name 必须带前缀）——先修好 FVM 首页菜单对 fork 版本才生效
4. `fvm_queue.provider.dart` 加 ohosUpdate
5. `ohos.provider.dart` + merge 单测
6. `ohos_branch_list_item.dart` + `ohos.screen.dart`
7. i18n 21 文件（在第 8 步前完成避免 key 缺失）
8. `navigation.provider.dart` + `app_shell.dart` 接线（最后接线，缩短编译不完整期）

## 测试计划
- `test/ohos/ohos_branch_parser_test.dart`：真实 ls-remote 格式解析、dev 变体、非 oh- 分支过滤、容错、排序（版本降序+release 优先）
- `test/ohos/ohos_fork_registration_test.dart`：appConfigPath 注入临时目录；全新注册/已存在跳过不覆盖 url/保留其他 forks/失败不抛/幂等
- `test/ohos/ohos_merge_test.dart`：sha 注入假实现；装配对、updateAvailable、孤儿分支、isGlobal
- `test/releases/untracked_versions_test.dart` 补充：fork 版本（`CacheFlutterVersion('oh-3.41.9-release', type: unknownRef, fork: 'ohos')`）→ 合成 name 必须为 `'ohos/oh-3.41.9-release'`
- 手动验证：启动生成 .fvmrc（二次启动不重复）→ OHOS 页列表/筛选 → 安装（控制台 clone 输出→列表翻已装、FVM 首页出现且 remove/detail/global 可用）→ `git reset --hard HEAD~1` 制造落后→更新按钮→pull 输出→标记消失 → 删除→目录清理 → 断网错误态+重试 → 确认 `/Users/jdny/fvm/versions/3.41.9`（用户手动 clone 的顶层目录）全程未动

## 风险与对策
| 风险 | 对策 |
|---|---|
| name 前缀分裂（最大坑） | 全链路单一契约 + 单测守护 |
| ls-remote 失败/超时 | FutureProvider error 态+重试按钮，60s 超时，不影响官方 Releases 页 |
| clone 半成品残留 | fvm 自带 `_handleNonExecutable` 自动检测重装（最多 2 次），无需额外处理 |
| pull 失败（本地漂移） | notifyError 显示 git stderr；不提供 force（防丢本地修改） |
| 队列 spinner 对象 identity | OHOS 列表项用 name 相等判断 |
| fork clone 不走 git cache（fvm 设计如此） | 接受；控制台流式输出缓解 |
