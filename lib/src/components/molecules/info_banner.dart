import 'package:flutter/material.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

/// Master 渠道的说明条。
///
/// 对应 design/tokens.css 的 `.note-bar`：左侧竖条 + 标题 + 说明。
class InfoBanner extends StatelessWidget {
  /// 构造函数
  const InfoBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SkNoteBar(
        icon: Icons.alt_route,
        tone: SkChipTone.warn,
        title: context.i18n('components:molecules.master'),
        description: context.i18n(
          'modules:releases.theCurrentTipoftreeAbsoluteLatestCuttingEdgeBuildUsuallyFunctional',
        ),
      ),
    );
  }
}