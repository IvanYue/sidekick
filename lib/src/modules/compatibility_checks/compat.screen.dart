import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/components/molecules/top_app_bar.dart';
import 'package:sidekick/src/modules/common/app_shell.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';
import 'package:sidekick/src/modules/compatibility_checks/compat.provider.dart';

import '../../theme.dart';
import 'compat.dialog.dart';

/// 缺少系统必需组件时的检查页。
///
/// 列出 Git（以及 Windows 的 Chocolatey / macOS·Linux 的 Brew）的检测结果，
/// 底部提供「忽略」与「安装缺失组件」两个出口。
class CompatCheckScreen extends ConsumerWidget {
  /// 构造函数
  const CompatCheckScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(compatProvider);
    final providerState = ref.watch(compatProvider.notifier);

    final theme = Theme.of(context);
    final c = SkColors.of(context);

    /// 一个组件的检测结果行。
    Widget checkRow({
      required String name,
      required String description,
      required bool ok,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SkTokens.sp5,
          vertical: SkTokens.sp4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              ok ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
              size: 18,
              color: ok ? c.ok : c.danger,
            ),
            const SizedBox(width: SkTokens.sp4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleSmall),
                  const SizedBox(height: SkTokens.sp1),
                  Text(description, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isWindows = Platform.isWindows;
    final otherName = isWindows ? 'Chocolatey' : 'Brew';
    final otherDescription = context.i18n(
      isWindows
          ? 'modules:compatibility.screen.chocoDescription'
          : 'modules:compatibility.screen.brewDescription',
    );
    final otherOk = isWindows ? provider.choco : provider.brew;

    return Scaffold(
      appBar: const SkAppBar(),
      backgroundColor: platformBackgroundColor(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(SkTokens.sp5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.i18n('modules:compatibility.screen.title'),
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: SkTokens.sp2),
                Text(
                  context.i18n('modules:compatibility.screen.subtitle'),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: SkTokens.sp5),
                Expanded(
                  child: SkPanel(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        checkRow(
                          name: 'Git',
                          description: context.i18n(
                            'modules:compatibility.screen.gitDescription',
                          ),
                          ok: provider.git,
                        ),
                        const SkDivider(),
                        checkRow(
                          name: otherName,
                          description: otherDescription,
                          ok: otherOk,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: SkTokens.sp5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.i18n(
                          'modules:compatibility.screen.pleaseInstall',
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: SkTokens.sp4),
                    SkButton(
                      label:
                          context.i18n('modules:compatibility.screen.ignore'),
                      onPressed: () {
                        providerState.applyValid();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppShell(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: SkTokens.sp3),
                    SkButton(
                      label: context.i18n(
                        'modules:compatibility.screen.installmissing',
                      ),
                      variant: SkButtonVariant.primary,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const CompatDialog(),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}