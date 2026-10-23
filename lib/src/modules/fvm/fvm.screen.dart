import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../components/mdi_icons.dart';
import '../releases/releases.provider.dart';
import 'components/fvm_cache_size.dart';
import 'components/fvm_empty_releases.dart';
import 'components/fvm_release_list_item.dart';
import 'dialogs/fvm_global_dialog.dart';
import 'fvm.provider.dart';
import 'fvm_queue.provider.dart';

/// 已安装的版本页。
///
/// 对应 design/index.html 的 `#page-installed`：页头 + 统计条 + 全局版本提示条
/// + 「所有已安装版本」列表。
class FVMScreen extends ConsumerWidget {
  /// 构造函数
  const FVMScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cachedVersions = ref.watch(releasesStateProvider);
    // 使用中 / 未使用 的判定与「清理未使用」共用同一份数据
    final unusedVersions = ref.watch(unusedVersionProvider);
    final unusedNames = unusedVersions.map((version) => version.name).toSet();
    final processing = ref.watch(fvmQueueProvider).activeItem != null;

    if (cachedVersions.fetching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cachedVersions.all.isEmpty) {
      return const EmptyVersions();
    }

    // 待更新：已安装渠道的 SDK 版本与频道最新发行版不一致
    final outdated = cachedVersions.channels
        .where((channel) =>
            channel.isCached &&
            channel.release?.version != null &&
            channel.sdkVersion != null &&
            channel.release!.version != channel.sdkVersion)
        .length;

    // 全局版本（取第一个标记为 global 的版本）
    final globalReleases =
        cachedVersions.all.where((release) => release.isGlobal);
    final global = globalReleases.isEmpty ? null : globalReleases.first;

    return SkPage(
      title: context.i18n('modules:fvm.installedVersions'),
      description: context.i18n('modules:fvm.installedVersionsDescription'),
      processing: processing,
      actions: SkIconButton(
        icon: Icons.refresh,
        tooltip: context.i18n('components:atoms.refresh'),
        // 整页刷新：重取远端发行版列表（用于判断渠道是否待更新）、重扫本地缓存
        onPressed: () {
          ref.invalidate(flutterReleasesProvider);
          ref.read(fvmCacheProvider.notifier).reloadState();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 统计条：已安装版本 / 占用空间 / 待更新 / 可清理
          _StatStrip(
            children: [
              _StatCell(
                label: context.i18n('modules:fvm.statsInstalled'),
                value: '${cachedVersions.all.length}',
              ),
              const FvmCacheSize(),
              _StatCell(
                label: context.i18n('modules:fvm.statsOutdated'),
                value: '$outdated',
              ),
              _StatCell(
                label: context.i18n('modules:fvm.statsUnused'),
                value: '${unusedVersions.length}',
              ),
            ],
          ),
          const SizedBox(height: SkTokens.sp6),

          // 全局版本提示条
          if (global != null) ...[
            SkNoteBar(
              tone: SkChipTone.info,
              icon: Icons.star_outline,
              title: context.i18n('modules:fvm.globalVersion'),
              description: context.i18n(
                'modules:fvm.globalVersionPathHint',
                variables: {
                  'path': shortenHomePath(fvmContext.globalCacheBinPath)
                },
              ),
              trailing: SkButton(
                label: context.i18n('modules:fvm.viewPath'),
                icon: MdiIcons.informationOutline,
                size: SkButtonSize.sm,
                onPressed: () => showGlobalInfoDialog(context),
              ),
            ),
            const SizedBox(height: SkTokens.sp6),
          ],

          // 小标题行
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  context.i18n(
                    'modules:fvm.allInstalledVersions',
                    variables: {'count': cachedVersions.all.length},
                  ),
                  style: SkText.overline(context),
                ),
              ),
              Text(
                context.i18n('modules:fvm.sortedByInstallTime'),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: SkTokens.sp3),

          // 列表即面板：无外框，行之间用细分隔线
          SkPanel(
            flush: true,
            child: Column(
              children: [
                for (var i = 0; i < cachedVersions.all.length; i++) ...[
                  if (i > 0) const SkDivider(),
                  FvmReleaseListItem(
                    cachedVersions.all[i],
                    isUnused: unusedNames.contains(cachedVersions.all[i].name),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 统计条（`.stat-strip`）：单框四格，格间以 1px 细线分隔。
class _StatStrip extends StatelessWidget {
  /// 构造函数
  const _StatStrip({required this.children});

  /// 各统计格
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.bgPanel,
        borderRadius: SkTokens.radiusLg,
        border: Border.all(color: c.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) Container(width: 1, color: c.lineSoft),
              Expanded(child: children[i]),
            ],
          ],
        ),
      ),
    );
  }
}

/// 单个统计格：大号等宽数值 + 下方小灰字标签。
class _StatCell extends StatelessWidget {
  /// 构造函数
  const _StatCell({required this.label, required this.value});

  /// 标签
  final String label;

  /// 数值
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SkTokens.sp5,
        vertical: SkTokens.sp4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: SkText.mono(context, fontSize: 18, color: c.ink1)),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(color: c.ink3),
          ),
        ],
      ),
    );
  }
}

/// 把用户主目录替换成 `~`，让路径在窄栏里也能完整显示。
String shortenHomePath(String path) {
  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
  if (home.isEmpty || !path.startsWith(home)) return path;
  return '~${path.substring(home.length)}';
}
