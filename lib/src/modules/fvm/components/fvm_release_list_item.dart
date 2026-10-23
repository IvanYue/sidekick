import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../components/mdi_icons.dart';
import '../../../components/molecules/sdk_version_meta.dart';
import '../../../modules/common/dto/release.dto.dart';
import '../../common/utils/open_link.dart';
import '../../ohos/components/ohos_badge.dart';
import '../../ohos/ohos.service.dart';
import '../../selected_detail/selected_detail.provider.dart';
import '../dialogs/fvm_delete_dialog.dart';
import '../dialogs/fvm_global_dialog.dart';
import '../fvm_queue.provider.dart';
import 'fvm_release_actions.dart';
import 'fvm_setup_button.dart';

/// 已安装版本列表行。
///
/// 对应 design/index.html 的 `.list-item`：
/// 左侧 32px 图标瓦片，中间版本号 + 徽章 + 渠道 / Dart 版本元信息，
/// 右侧「更新 / 删除 / 更多」图标操作。
class FvmReleaseListItem extends ConsumerWidget {
  /// 构造函数
  const FvmReleaseListItem(
    this.release, {
    this.isUnused = false,
    super.key,
  });

  /// 版本
  final ReleaseDto release;

  /// 是否未被任何项目使用（由页面级 provider 计算后传入）
  final bool isUnused;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    final isOhos = release.isOhosSdk;
    final isGlobal = release.isGlobal;

    // 渠道名：频道自身就是渠道，其它从发行元数据或缓存元数据取
    final channelName =
        release.release?.channelName ?? release.cache?.releaseChannel?.name;

    // 渠道名片段：非等宽字体的普通说明文字，排在版本号之前
    final channelLabel = channelName == null
        ? null
        : Text(
            channelName,
            style: theme.textTheme.labelSmall?.copyWith(color: c.ink3),
          );

    // 图标瓦片语义：OHOS > 全局 > 普通
    final (tileTone, tileIcon) = isOhos
        ? (SkChipTone.ok, Icons.phone_android)
        : isGlobal
            ? (SkChipTone.accent, Icons.inventory_2_outlined)
            : (SkChipTone.neutral, Icons.flutter_dash);

    return SkListRow(
      dense: true,
      leading: _ReleaseTile(icon: tileIcon, tone: tileTone),
      title: Row(
        children: [
          Flexible(
            child: Text(
              // OHOS 版本显示短名，语义由旁边的徽章承载
              isOhos ? ohosDisplayName(release.name) : release.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SkText.monoLg(context, color: c.ink1),
            ),
          ),
          if (isGlobal) ...[
            const SizedBox(width: SkTokens.sp3),
            Tooltip(
              message: context.i18n('modules:fvm.dialogs.globalConfiguration'),
              child: GestureDetector(
                onTap: () => showGlobalInfoDialog(context),
                child: SkChip(
                  label: context.i18n('modules:fvm.components.global'),
                  tone: SkChipTone.info,
                  icon: Icons.star_outline,
                ),
              ),
            ),
          ],
          if (isOhos) ...[
            const SizedBox(width: SkTokens.sp3),
            // OHOS 徽章打开该版本的 OHOS 发布页
            OhosBadge(
              tooltip: context.i18n('modules:ohos.openOhosRelease'),
              onPressed: () => openLink(ohosReleasePageUrl(release.cache)),
            ),
          ],
          const SizedBox(width: SkTokens.sp3),
          SkChip(
            label: isUnused
                ? context.i18n('modules:fvm.components.unused')
                : context.i18n('modules:fvm.components.inUse'),
            tone: isUnused ? SkChipTone.neutral : SkChipTone.ok,
            icon: isUnused ? null : Icons.check,
          ),
        ],
      ),
      // 次行：渠道 · Flutter 版本 · Dart 版本
      subtitle: SdkVersionMeta(
        flutterVersion: release.sdkFlutterVersion ?? release.name,
        dartVersion: release.sdkDartVersion,
        leading: [if (channelLabel != null) channelLabel],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SDK 未完成 setup：保留原有 setup 入口
          if (release.needSetup) SetupButton(release: release),
          if (isOhos && release.isCached)
            SkIconButton(
              icon: Icons.refresh,
              tooltip: context.i18n('modules:ohos.updateOhosVersion'),
              onPressed: () => ref
                  .read(fvmQueueProvider.notifier)
                  .ohosUpdate(context, release),
            )
          else if (release.isChannel && release.isCached)
            SkIconButton(
              icon: Icons.refresh,
              tooltip: context.i18n('modules:fvm.components.upgrade'),
              onPressed: () =>
                  ref.read(fvmQueueProvider.notifier).upgrade(context, release),
            ),
          // 未使用的版本可直接删除
          if (isUnused)
            SkIconButton(
              icon: MdiIcons.delete,
              tooltip: context.i18n('modules:projects.components.remove'),
              onPressed: () => showDeleteDialog(
                context,
                item: release,
                onDelete: () {
                  ref.read(fvmQueueProvider.notifier).remove(context, release);
                },
              ),
            ),
          FvmReleaseActions(release),
        ],
      ),
      onTap: () {
        ref.read(selectedDetailProvider.notifier).state = SelectedDetail(
          release: release,
        );
      },
    );
  }
}

/// 列表行左侧的方形图标瓦片（`.tile`，32px）。
class _ReleaseTile extends StatelessWidget {
  /// 构造函数
  const _ReleaseTile({required this.icon, required this.tone});

  /// 图标
  final IconData icon;

  /// 语义色
  final SkChipTone tone;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final palette = _tilePalette(c, tone);

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: SkTokens.radiusMd,
        border: Border.all(color: palette.border),
      ),
      child: Icon(icon, size: 18, color: palette.fg),
    );
  }
}

/// 语义色到瓦片三色的映射（前景 / 底色 / 描边）。
({Color fg, Color bg, Color border}) _tilePalette(
  SkColors c,
  SkChipTone tone,
) {
  switch (tone) {
    case SkChipTone.accent:
      return (fg: c.accent, bg: c.accentSoft, border: c.accentLine);
    case SkChipTone.ok:
      return (fg: c.ok, bg: c.okSoft, border: c.okLine);
    case SkChipTone.info:
      return (fg: c.info, bg: c.infoSoft, border: c.infoLine);
    case SkChipTone.warn:
      return (fg: c.warn, bg: c.warnSoft, border: c.warnLine);
    case SkChipTone.danger:
      return (fg: c.danger, bg: c.dangerSoft, border: c.dangerLine);
    case SkChipTone.neutral:
      return (fg: c.ink2, bg: c.bgRaised, border: c.lineSoft);
  }
}
