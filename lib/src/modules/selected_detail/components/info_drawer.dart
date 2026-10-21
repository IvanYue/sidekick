import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../../components/molecules/version_install_button.dart';
import '../../common/dto/release.dto.dart';
import '../../common/utils/helpers.dart';
import '../../common/utils/layout_size.dart';
import '../../fvm/fvm_queue.provider.dart';
import '../../ohos/ohos.constants.dart';
import '../selected_detail.provider.dart';
import 'cache_info_tile.dart';
import 'reference_info_tile.dart';
import 'release_info_section.dart';

/// 版本详情抽屉。
///
/// 对应 design/index.html 的 `.drawer`：372 宽的右侧抽屉，
/// 顶部是版本号与渠道，下面是键值对分区，底部是主操作按钮。
class SelectedDetailDrawer extends HookConsumerWidget {
  /// 构造函数
  const SelectedDetailDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(selectedDetailProvider);
    final selected = detail?.release;
    final detailScrollController = useScrollController();

    void onClose() {
      // Close drawer if its not large layout
      if (!LayoutSize.isLarge) {
        Navigator.pop(context);
      }
      // Clear selected detail provider
      ref.read(selectedDetailProvider.notifier).state = null;
    }

    if (selected == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: SkColors.of(context).line)),
        ),
        child: Drawer(
          elevation: 0,
          backgroundColor: SkColors.of(context).bgPanel,
          child: Padding(
            padding: const EdgeInsets.all(SkTokens.sp5),
            child: SkEmptyState(
              icon: Icons.inventory_2_outlined,
              title: context
                  .i18n('modules:selectedDetail.components.nothingSelected'),
            ),
          ),
        ),
      );
    }

    final c = SkColors.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: c.line)),
      ),
      child: Drawer(
        elevation: 0,
        width: LayoutSize.isLarge ? SkTokens.drawerWidth : null,
        backgroundColor: c.bgPanel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(release: selected, onClose: onClose),
            Expanded(
              child: ListView(
                controller: detailScrollController,
                primary: false,
                padding: const EdgeInsets.only(bottom: SkTokens.sp5),
                children: [
                  ReferenceInfoTile(selected),
                  FvmInfoTile(selected),
                  ReleaseInfoSection(selected),
                ],
              ),
            ),
            _DrawerFooter(release: selected),
          ],
        ),
      ),
    );
  }
}

/// 抽屉头部：版本号 + 渠道 chip + 关闭按钮。
class _DrawerHeader extends StatelessWidget {
  /// 构造函数
  const _DrawerHeader({required this.release, required this.onClose});

  /// 版本
  final ReleaseDto release;

  /// 关闭回调
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    final channelName = release.isChannel
        ? release.name
        : release.isOhosSdk
            ? kOhosForkName
            : release.release?.channelName ?? '';

    final flutterVersion = release.release?.version ?? release.name;
    final dartVersion = release.release?.dartSdkVersion;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        SkTokens.sp5,
        SkTokens.sp5,
        SkTokens.sp5,
        SkTokens.sp4,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.lineSoft)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        release.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SkText.mono(
                          context,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: c.ink1,
                        ),
                      ),
                    ),
                    const SizedBox(width: SkTokens.sp2),
                    SkChip(label: channelName, outline: true),
                  ],
                ),
                const SizedBox(height: SkTokens.sp1),
                Text(
                  dartVersion == null
                      ? 'Flutter $flutterVersion'
                      : 'Flutter $flutterVersion · Dart $dartVersion',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: SkTokens.sp3),
          SkIconButton(
            icon: Icons.close,
            iconSize: 18,
            color: c.ink3,
            tooltip: context.i18n('modules:selectedDetail.components.close'),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

/// 抽屉底部的主操作区。
class _DrawerFooter extends ConsumerWidget {
  /// 构造函数
  const _DrawerFooter({required this.release});

  /// 版本
  final ReleaseDto release;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = SkColors.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        SkTokens.sp5,
        SkTokens.sp4,
        SkTokens.sp5,
        SkTokens.sp5,
      ),
      decoration: BoxDecoration(
        color: c.bgSidebar,
        border: Border(top: BorderSide(color: c.lineSoft)),
      ),
      child: release.isCached
          ? Row(
              children: [
                SkButton(
                  label: context.i18n('modules:fvm.components.setAsGlobal'),
                  icon: Icons.star_outline,
                  variant: SkButtonVariant.primary,
                  expand: true,
                  onPressed: release.isGlobal
                      ? null
                      : () => ref
                          .read(fvmQueueProvider.notifier)
                          .setGlobal(context, release),
                ),
                const SizedBox(width: SkTokens.sp3),
                if (release.isChannel)
                  SkButton(
                    label: context.i18n('modules:fvm.components.upgrade'),
                    icon: Icons.refresh,
                    variant: SkButtonVariant.secondary,
                    onPressed: () => ref
                        .read(fvmQueueProvider.notifier)
                        .upgrade(context, release),
                  )
                else
                  VersionInstallButton(release),
              ],
            )
          : VersionInstallButton(release, showLabel: true, expand: true),
    );
  }
}
