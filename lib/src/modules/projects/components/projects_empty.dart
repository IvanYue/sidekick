import 'package:flutter/material.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../components/mdi_icons.dart';

/// 项目页的空态：还没有添加任何 Flutter 项目时展示。
///
/// 对应 design/tokens.css 的 `.empty`：居中图标瓦片 + 标题 + 说明。
class EmptyProjects extends StatelessWidget {
  /// 构造函数
  const EmptyProjects({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(SkTokens.sp8),
          child: SkEmptyState(
            tone: SkChipTone.accent,
            icon: MdiIcons.folderMultiple,
            title: context.i18n(
              'modules:projects.components.noFlutterProjectsHaveBeenAddedYet',
            ),
            description: context.i18n(
              'modules:projects.components.addYourFlutterProjectProjectsInformationWillBeDisplayedHere',
            ),
          ),
        ),
      ),
    );
  }
}