import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../components/mdi_icons.dart';
import '../../common/utils/notify.dart';
import '../../settings/settings.dto.dart';
import '../ide.provider.dart';
import '../ide_detector.dart';
import '../ide_icons.dart';
import '../ide_opener.dart';

/// 在 [ide] 中打开 [folder]，失败时弹提示。
Future<void> openFolderInIde(
  BuildContext context,
  WidgetRef ref,
  DetectedIde ide,
  String folder,
) async {
  final errorMessage = context.i18n(
    'modules:projects.components.couldNotOpenIde',
    variables: {'ideName': ide.name},
  );
  try {
    await openInIde(ide, folder, env: ref.read(ideEnvironmentProvider));
  } on Exception {
    notifyError(errorMessage);
  }
}

/// 设置里选中的 IDE 的快捷按钮。未选或选中的 IDE 未安装时不显示。
class OpenInSelectedIdeButton extends ConsumerWidget {
  /// 构造函数
  const OpenInSelectedIdeButton(this.folder, this.settings, {super.key});

  /// 要打开的目录
  final String folder;

  /// 含已选 IDE 的设置
  final SidekickSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidekick = settings;
    final detected = ref.watch(ideDetectionProvider).value ?? const [];
    final ide = resolveSelectedIde(
      sidekick.ide,
      detected,
      customLocation: sidekick.customIdeLocation,
    );
    if (ide == null) return const SizedBox.shrink();

    // 用 IDE 自己的图标，包一层与 SkIconButton 一致的 28×28 点击区
    return Tooltip(
      message: context.i18n(
        'modules:projects.components.openIde',
        variables: {'ideName': ide.name},
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => openFolderInIde(context, ref, ide, folder),
          borderRadius: SkTokens.radiusMd,
          hoverColor: SkColors.of(context).bgHover,
          child: SizedBox(
            width: SkTokens.iconButtonSize,
            height: SkTokens.iconButtonSize,
            child: Center(child: ideIcon(ide.launcher)),
          ),
        ),
      ),
    );
  }
}

/// 「重新检测」菜单项的取值
const _refreshAction = 'refresh';

/// 「打开方式」菜单，列出所有已安装的启动器。
class OpenInIdeMenu extends ConsumerWidget {
  /// 构造函数
  const OpenInIdeMenu(this.folder, this.settings, {super.key});

  /// 要打开的目录
  final String folder;

  /// 含自定义 IDE 路径的设置
  final SidekickSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sidekick = settings;
    final detection = ref.watch(ideDetectionProvider);
    final custom = customIde(sidekick.customIdeLocation);
    final launchers = [
      ...?detection.value,
      if (custom != null) custom,
    ];

    Widget renderItem(Widget icon, String label) {
      return Row(
        children: [
          IconTheme.merge(data: const IconThemeData(size: 15), child: icon),
          const SizedBox(width: SkTokens.sp3),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      );
    }

    return PopupMenuButton<Object>(
      tooltip: context.i18n('modules:projects.components.openIn'),
      onSelected: (ide) {
        if (ide is DetectedIde) {
          openFolderInIde(context, ref, ide, folder);
        } else {
          ref.read(ideDetectionProvider.notifier).refresh();
        }
      },
      itemBuilder: (context) {
        return [
          if (launchers.isEmpty)
            PopupMenuItem(
              enabled: false,
              child: Text(
                detection.isLoading
                    ? context.i18n('modules:settings.scenes.detectingIdes')
                    : context.i18n('modules:projects.components.noIdesFound'),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ...launchers.map(
            (ide) => PopupMenuItem<Object>(
              value: ide,
              height: 34,
              child: renderItem(
                ideIcon(ide.launcher),
                ide.launcher.isCustom
                    ? context.i18n('modules:settings.scenes.ideCustom')
                    : ide.name,
              ),
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<Object>(
            value: _refreshAction,
            height: 34,
            child: renderItem(
              Icon(MdiIcons.refresh),
              context.i18n('modules:settings.scenes.detectIdesAgain'),
            ),
          ),
        ];
      },
      child: SizedBox(
        width: SkTokens.iconButtonSize,
        height: SkTokens.iconButtonSize,
        child: Icon(MdiIcons.openInNew,
            size: 18, color: SkColors.of(context).ink2),
      ),
    );
  }
}
