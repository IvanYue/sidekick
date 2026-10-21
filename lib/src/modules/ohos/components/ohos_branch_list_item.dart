import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../components/mdi_icons.dart';
import '../../fvm/components/fvm_release_actions.dart';
import '../../fvm/components/fvm_setup_button.dart';
import '../../fvm/dialogs/fvm_global_dialog.dart';
import '../../fvm/fvm_queue.provider.dart';
import '../../selected_detail/selected_detail.provider.dart';
import '../ohos.dto.dart';
import '../ohos.service.dart';

/// OHOS 分支列表行：安装、更新与后续管理。
///
/// 对应 design/index.html `#page-ohos` 的 `.list-item`：等宽分支名 +
/// 类型 chip + 已安装 / 待更新状态 + 右侧操作按钮。
class OhosBranchListItem extends ConsumerWidget {
  /// 构造函数
  const OhosBranchListItem(
    this.item, {
    super.key,
  });

  /// 分支与本地安装状态
  final OhosBranchItem item;

  // 队列匹配按名称：provider 重建会重新创建 DTO 实例，
  // 对象标识（VersionInstallButton 用的方式）会丢掉 spinner。
  bool _isInQueue(WidgetRef ref, String name) {
    final queue = ref.watch(fvmQueueProvider);
    if (queue.activeItem?.version.name == name) return true;

    return queue.queue.any((i) => i.version.name == name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    final dto = item.toVersionDto();
    final isQueued = _isInQueue(ref, dto.name);
    final branch = item.branch;
    final isDev = branch?.type == OhosBranchType.dev;

    return SkListRow(
      leading: Container(
        width: SkTokens.tileSize,
        height: SkTokens.tileSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDev ? c.infoSoft : c.okSoft,
          borderRadius: SkTokens.radiusLg,
          border: Border.all(color: isDev ? c.infoLine : c.okLine),
        ),
        child: Icon(
          isDev ? Icons.bolt : Icons.phone_android,
          size: 18,
          color: isDev ? c.info : c.ok,
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              ohosDisplayName(branch?.name ?? item.cache!.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SkText.monoLg(context, color: c.ink1),
            ),
          ),
          const SizedBox(width: SkTokens.sp3),
          // 类型徽章：远端分支才有；孤立安装没有类型可标
          if (branch != null)
            SkChip(
              label: branch.type == OhosBranchType.release
                  ? context.i18n('modules:ohos.release')
                  : context.i18n('modules:ohos.dev'),
              tone: isDev ? SkChipTone.info : SkChipTone.ok,
              mono: true,
            ),
          const SizedBox(width: SkTokens.sp3),
          if (item.isGlobal)
            Tooltip(
              message: context.i18n('modules:fvm.components.global'),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => showGlobalInfoDialog(context),
                  borderRadius: SkTokens.radiusSm,
                  child: SkChip(
                    label: context.i18n('modules:fvm.components.global'),
                    tone: SkChipTone.accent,
                    icon: MdiIcons.earth,
                  ),
                ),
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              branch != null
                  ? '${branch.sha.substring(0, 7)}'
                      '${branch.extra != null ? ' · ${branch.extra}' : ''}'
                  : context.i18n('modules:ohos.orphanBranch'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
          ),
          if (item.updateAvailable) ...[
            const SizedBox(width: SkTokens.sp4),
            Text(
              context.i18n('modules:ohos.updateAvailable'),
              style: theme.textTheme.labelSmall?.copyWith(color: c.warn),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.isInstalled) ...[
            if (item.cache!.isNotSetup) SetupButton(release: dto),
            SkIconButton(
              icon: MdiIcons.update,
              tooltip: branch != null
                  ? context.i18n('modules:ohos.updateOhosVersion')
                  : context.i18n('modules:ohos.orphanBranch'),
              // 孤立安装没有可拉取的远端分支
              onPressed: branch == null
                  ? null
                  : () => ref
                      .read(fvmQueueProvider.notifier)
                      .ohosUpdate(context, dto),
            ),
            FvmReleaseActions(dto),
          ] else if (isQueued)
            SizedBox(
              width: 20,
              height: 20,
              child: SpinKitFadingFour(size: 15, color: c.accent),
            )
          else
            SkIconButton(
              icon: Icons.arrow_downward,
              tooltip: context.i18n('modules:ohos.installOhosVersion'),
              onPressed: () =>
                  ref.read(fvmQueueProvider.notifier).install(context, dto),
            ),
        ],
      ),
      onTap: () {
        ref.read(selectedDetailProvider.notifier).state = SelectedDetail(
          release: dto,
        );
      },
    );
  }
}
