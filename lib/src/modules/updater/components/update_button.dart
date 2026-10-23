import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../components/mdi_icons.dart';
import '../updater.provider.dart';

/// Sidekick 自身版本的「检查更新」按钮。
///
/// 放在设置页「通用」面板的版本号那一行，不再占用标题栏。有可用更新时按钮
/// 高亮并弹出更新对话框，否则点击一次重新向 GitHub 查询最新版本。
class UpdateCheckButton extends HookConsumerWidget {
  /// 构造函数
  const UpdateCheckButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updater = ref.watch(updaterProvider.notifier);
    final updateInfo = ref.watch(updaterProvider);
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    final isMounted = context.mounted;

    void showUpdateDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(MdiIcons.alertDecagram, color: c.accent),
                const SizedBox(width: SkTokens.sp3),
                Text(
                  context.i18n('modules:updater.components.updateAvailable'),
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            content: Text(
              context.i18n(
                'modules:updater.components.sidekickVersionUpdateinfolatestIsNowAvailable',
                variables: {
                  'updateInfoLatest': updateInfo.latest,
                },
              ),
              style: theme.textTheme.bodyMedium,
            ),
            actions: <Widget>[
              SkButton(
                label: context.i18n('modules:updater.components.later'),
                variant: SkButtonVariant.ghost,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SkButton(
                label: context.i18n('modules:updater.components.updateNow'),
                variant: SkButtonVariant.primary,
                onPressed: () async {
                  await updater.openInstaller(context);
                  // ignore: use_build_context_synchronously
                  if (isMounted) Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    // 有可用更新 → 走更新安装流程；否则重新检查一次
    if (updateInfo.ready) {
      return SkButton(
        label: context.i18n('modules:updater.components.updateNow'),
        icon: Icons.file_download_outlined,
        variant: SkButtonVariant.primary,
        size: SkButtonSize.sm,
        onPressed: showUpdateDialog,
      );
    }

    return SkButton(
      label: context.i18n('modules:updater.components.checkForUpdates'),
      icon: Icons.refresh,
      variant: SkButtonVariant.secondary,
      size: SkButtonSize.sm,
      onPressed: updater.checkLatest,
    );
  }
}