import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../navigation/navigation.provider.dart';

/// 已安装页的空态：没有任何 Flutter SDK 时展示。
///
/// 对应 design/tokens.css 的 `.empty`：居中图标瓦片 + 标题 + 说明 + 主操作。
class EmptyVersions extends ConsumerWidget {
  /// 构造函数
  const EmptyVersions({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(SkTokens.sp8),
          child: SkEmptyState(
            tone: SkChipTone.accent,
            icon: Icons.flutter_dash,
            title: context.i18n('modules:fvm.components.flutterSdkNotInstalled'),
            description: context.i18n(
              'modules:fvm.components.noFlutterVersionInstalledMessage',
            ),
            action: SkButton(
              label: context.i18n(
                'modules:fvm.components.exploreFlutterReleases',
              ),
              icon: Icons.explore_outlined,
              variant: SkButtonVariant.primary,
              onPressed: () {
                ref
                    .read(navigationProvider.notifier)
                    .goTo(NavigationRoutes.exploreScreen);
              },
            ),
          ),
        ),
      ),
    );
  }
}