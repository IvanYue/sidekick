import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';
import 'package:sidekick/src/modules/common/utils/notify.dart';
import 'package:sidekick/src/modules/compatibility_checks/compat.dto.dart';
import 'package:sidekick/src/modules/compatibility_checks/compat.provider.dart';

import 'compat.utils.dart';

/// 缺少系统组件时的安装指引对话框。
///
/// 对应 design/tokens.css 的 `.modal`：标题 + 说明 + 可复制的命令块 + 底部操作。
class CompatDialog extends ConsumerWidget {
  /// 构造函数
  const CompatDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final command = _genCommand(ref.watch(compatProvider));

    return AlertDialog(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.i18n('modules:compatibility.dialog.dialogTitle'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: SkTokens.sp2),
          Text(
            context.i18n(Platform.isWindows
                ? 'modules:compatibility.dialog.dialogDescriptionWindows'
                : 'modules:compatibility.dialog.dialogDescriptionMacLinux'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      content: Container(
        padding: const EdgeInsets.all(SkTokens.sp3),
        decoration: BoxDecoration(
          color: SkColors.of(context).bgInset,
          borderRadius: SkTokens.radiusMd,
        ),
        child: SingleChildScrollView(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SelectableText(
                  command,
                  style: SkText.mono(context, fontSize: 11),
                ),
              ),
              SkIconButton(
                icon: Icons.content_copy_outlined,
                size: 22,
                iconSize: 14,
                tooltip: context.i18n('components:atoms.copiedToClipboard'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: command));
                  notify(context.i18n('components:atoms.copiedToClipboard'));
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        SkButton(
          label: context.i18n('modules:fvm.dialogs.cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        SkButton(
          label: context.i18n('modules:compatibility.dialog.done'),
          variant: SkButtonVariant.primary,
          onPressed: () {
            notify(context
                .i18n('modules:compatibility.dialog.dialogRestartNotication'));
            Future.delayed(const Duration(seconds: 3)).then((_) => exit(0));
          },
        ),
      ],
    );
  }
}

String _genCommand(CompatibilityCheck check) {
  var command = "";
  final useBrew = (Platform.isMacOS || Platform.isLinux);
  if (!check.brew && useBrew) {
    command += brewInstallCmd;
  }
  if (!check.choco && !useBrew) {
    command += chocoInstallCmd;
  }
  if (!check.git) {
    command += gitInstallCmd;
  }
  return command;
}