import 'package:flutter/material.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

/// 版本 / 项目名旁边的小「OHOS」徽章。
///
/// 传入 [onPressed] 时徽章可点击（例如打开 OHOS 仓库或某个版本的发布页）；
/// 不传则是纯展示的标签。
class OhosBadge extends StatelessWidget {
  /// 构造函数
  const OhosBadge({this.onPressed, this.tooltip, super.key});

  /// 点击回调；为 null 时渲染成不可点的标签。
  final VoidCallback? onPressed;

  /// 悬浮提示；默认为「打开 OHOS 仓库」文案。
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final label = context.i18n('modules:ohos.ohosTag');
    final badge = SkChip(
      label: label,
      tone: SkChipTone.ok,
      icon: Icons.phone_android,
    );

    if (onPressed == null) return badge;

    return Tooltip(
      message: tooltip ?? context.i18n('modules:ohos.openOhosRepo'),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          child: badge,
        ),
      ),
    );
  }
}