import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../components/mdi_icons.dart';
import '../updater.provider.dart';

/// Sidekick 更新按钮。
///
/// 标题栏里的「检查更新」图标：有可用更新时高亮并弹出更新对话框，
/// 否则点击一次重新检查最新版本。
class SkUpdateButton extends HookConsumerWidget {
  /// 构造函数
  const SkUpdateButton({
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
      // flutter defined function
      showDialog(
        context: context,
        builder: (context) {
          // return object of type Dialog
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

    return SkIconButton(
      icon: Icons.refresh_rounded,
      color: updateInfo.ready ? c.accent : null,
      tooltip: updateInfo.ready
          ? context.i18n('modules:updater.components.updateAvailable')
          : context.i18n('modules:updater.components.checkForUpdates'),
      onPressed: () {
        if (updateInfo.ready) {
          showUpdateDialog();
        } else {
          updater.checkLatest();
        }
      },
    );
  }
}
