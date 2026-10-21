import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: implementation_imports
import 'package:fvm/src/utils/which.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../components/mdi_icons.dart';
import '../../common/utils/open_link.dart';
import '../fvm.provider.dart';

/// 全局版本配置说明对话框。
///
/// 对应 design/tokens.css 的 `.modal`：标题 + 键值说明 + 底部操作。
Future<void> showGlobalInfoDialog(BuildContext context) async {
  final c = SkColors.of(context);
  final theme = Theme.of(context);

  final currentPath = which('flutter', binDir: true);
  final correctPath = fvmContext.globalCacheBinPath;
  final isSetup = currentPath == correctPath;

  // ignore: use_build_context_synchronously
  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          context.i18n('modules:fvm.dialogs.globalConfiguration'),
          style: theme.textTheme.titleLarge,
        ),
        actions: <Widget>[
          SkButton(
            label: context.i18n('modules:fvm.dialogs.ok'),
            variant: SkButtonVariant.primary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.i18n('modules:fvm.dialogs.flutterPathIsPointingOn'),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: SkTokens.sp2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    currentPath ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SkText.mono(context, fontSize: 11, color: c.ink1),
                  ),
                ),
                SkIconButton(
                  icon: Icons.content_copy_outlined,
                  size: 22,
                  iconSize: 14,
                  color: c.ink3,
                  onPressed: () {
                    if (currentPath == null) return;
                    Clipboard.setData(ClipboardData(text: currentPath));
                  },
                ),
              ],
            ),
            const SizedBox(height: SkTokens.sp4),

            if (!isSetup) ...[
              Text(
                context.i18n('modules:fvm.dialogs.changeThePathTo') +
                    context.i18n(
                        'modules:fvm.dialogs.ifYouWantToFlutterSdkThroughFvm'),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: SkTokens.sp2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      correctPath,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SkText.mono(context, fontSize: 11, color: c.ink2),
                    ),
                  ),
                  SkIconButton(
                    icon: Icons.content_copy_outlined,
                    size: 22,
                    iconSize: 14,
                    color: c.ink3,
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: correctPath)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: SkTokens.sp3),
            SkButton(
              label: context.i18n('modules:fvm.dialogs.howToUpdateYourPath'),
              icon: MdiIcons.informationOutline,
              variant: SkButtonVariant.ghost,
              onPressed: () {
                final os = Platform.operatingSystem;
                openLink(
                  'https://flutter.dev/docs/get-started/install/$os#update-your-path',
                );
              },
            ),
          ],
        ),
      );
    },
  );
}