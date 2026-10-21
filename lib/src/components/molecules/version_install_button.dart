import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../mdi_icons.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../modules/common/dto/release.dto.dart';
import '../../modules/fvm/fvm_queue.provider.dart';

/// 安装按钮。
///
/// 对应 design/tokens.css 的 `.icon-btn`（紧凑图标按钮）与 `.btn-primary`（带文案按钮）。
/// 默认是列表行里的紧凑图标按钮，传 [showLabel] 可变成带文案的主按钮。
class VersionInstallButton extends HookConsumerWidget {
  /// 构造函数
  const VersionInstallButton(
    this.version, {
    super.key,
    this.showLabel = false,
    this.expand = false,
  });

  /// 版本
  final ReleaseDto version;

  /// 是否显示文案（抽屉底部的主操作按钮）
  final bool showLabel;

  /// 是否撑满父级宽度
  final bool expand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installedMsg =
        context.i18n('components:molecules.versionIsInstalled');
    final notInstalledMsg = context.i18n(
      'components:molecules.versionNotInstalledClickToInstall',
    );
    final installLabel = context.i18n('components:molecules.install');
    final isQueued = useState(false);
    final queueProvider = ref.watch(fvmQueueProvider);

    final isCached = version.isCached == true;

    useEffect(() {
      final isInstalling = queueProvider.activeItem != null &&
          queueProvider.activeItem?.version == version;

      if (isInstalling) {
        isQueued.value = true;
        return;
      }

      final queued = queueProvider.queue.firstWhereOrNull(
        (item) => item.version == version,
      );

      isQueued.value = queued != null;
      return;
    }, [queueProvider]);

    Future<void> onInstall() async {
      isQueued.value = true;
      // Add it to queue for installation
      ref.read(fvmQueueProvider.notifier).install(context, version);
    }

    final c = SkColors.of(context);

    // 安装中 / 排队中
    if (isQueued.value && !isCached) {
      final spinner = SizedBox(
        height: 16,
        width: 16,
        child: SpinKitFadingFour(size: 14, color: c.accent),
      );
      if (showLabel) {
        return SkButton(
          label: installLabel,
          icon: Icons.download_outlined,
          variant: SkButtonVariant.primary,
          expand: expand,
          busy: true,
        );
      }
      return _IconInstallButton(
        icon: spinner,
        tooltip: notInstalledMsg,
        onPressed: onInstall,
      );
    }

    // 已缓存但没跑完 setup：显示告警
    if (isCached && version.needSetup) {
      final icon = Icon(MdiIcons.alert, size: 16, color: c.warn);
      if (showLabel) {
        return SkButton(
          label: installLabel,
          icon: MdiIcons.alert,
          variant: SkButtonVariant.secondary,
          expand: expand,
          onPressed: onInstall,
        );
      }
      return _IconInstallButton(
        icon: icon,
        tooltip: installedMsg,
        onPressed: onInstall,
      );
    }

    // 已安装
    if (isCached) {
      final icon = Icon(Icons.check, size: 16, color: c.ok);
      if (showLabel) {
        return SkButton(
          label: installLabel,
          icon: Icons.check,
          variant: SkButtonVariant.secondary,
          expand: expand,
          onPressed: onInstall,
        );
      }
      return _IconInstallButton(
        icon: icon,
        tooltip: installedMsg,
        onPressed: onInstall,
      );
    }

    // 未安装
    if (showLabel) {
      return SkButton(
        label: installLabel,
        icon: Icons.download_outlined,
        variant: SkButtonVariant.primary,
        expand: expand,
        onPressed: onInstall,
      );
    }
    return _IconInstallButton(
      icon: Icon(Icons.arrow_downward, size: 16, color: c.ink2),
      tooltip: notInstalledMsg,
      onPressed: onInstall,
    );
  }
}

/// 紧凑图标安装按钮。
class _IconInstallButton extends StatelessWidget {
  /// 构造函数
  const _IconInstallButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  /// 图标
  final Widget icon;

  /// 悬浮提示
  final String tooltip;

  /// 点击回调
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: SkTokens.radiusMd,
          hoverColor: c.bgHover,
          child: Container(
            width: SkTokens.iconButtonSize,
            height: SkTokens.iconButtonSize,
            alignment: Alignment.center,
            child: icon,
          ),
        ),
      ),
    );
  }
}
