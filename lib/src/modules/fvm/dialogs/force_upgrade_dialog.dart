import 'package:flutter/material.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

/// Flutter 拒绝升级 [versionName] 时询问是否强制升级。
/// 用户确认则返回 true。
Future<bool> showForceUpgradeDialog(
  BuildContext context,
  String versionName,
  String message,
) async {
  final theme = Theme.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          context.i18n(
            'modules:fvm.dialogs.couldNotUpgradeVersionname',
            variables: {'versionName': versionName},
          ),
          style: theme.textTheme.titleLarge,
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              Text(
                context.i18n('modules:fvm.dialogs.forceUpgradeDiscardsChanges'),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.i18n('modules:fvm.dialogs.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.i18n('modules:fvm.dialogs.forceUpgrade')),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}