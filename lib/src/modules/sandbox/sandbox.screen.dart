import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fvm/fvm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';
import 'package:sidekick/src/window_border.dart';

import '../../components/mdi_icons.dart';
import '../../modules/common/dto/release.dto.dart';
import '../releases/releases.provider.dart';
import 'components/sandbox_terminal.dart';
import 'sandbox.provider.dart';

/// Terminal Playground：在某个项目里跑指定 Flutter SDK 的命令。
///
/// 左边选版本，右边是终端输出。
class SandboxScreen extends HookConsumerWidget {
  /// 构造函数
  const SandboxScreen({
    required this.project,
    super.key,
  });

  /// 项目
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    final releases = ref.watch(releasesStateProvider);
    final terminal = ref.watch(sandboxProvider.notifier);
    final processing = ref.watch(sandboxProvider).processing;

    final selectedRelease = useState<ReleaseDto?>(null);
    final sandboxScrollController = ScrollController();

    useEffect(() {
      if (selectedRelease.value == null && releases.all.isNotEmpty) {
        selectedRelease.value = releases.all[0];
      }
      return;
    }, []);

    return Scaffold(
      backgroundColor: c.bgApp,
      appBar: AppBar(
        backgroundColor: c.bgSidebar,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: Platform.isMacOS ? const WindowButtons() : null,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(MdiIcons.playBox, size: 18, color: c.accent),
            const SizedBox(width: SkTokens.sp3),
            Text(
              context.i18n('modules:sandbox.playground'),
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          SkIconButton(
            icon: Icons.close,
            tooltip: context.i18n('modules:fvm.dialogs.cancel'),
            onPressed: () {
              terminal.clearConsole();
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: SkTokens.sp3),
          if (!Platform.isMacOS) const WindowButtons(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: c.lineSoft),
        ),
        // 保留整条标题栏可拖动窗口
        flexibleSpace: MoveWindow(),
      ),
      body: Row(
        children: [
          // 左：版本列表
          Container(
            width: 240,
            decoration: BoxDecoration(
              color: c.bgSidebar,
              border: Border(right: BorderSide(color: c.lineSoft)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SkTokens.sp5,
                    SkTokens.sp5,
                    SkTokens.sp5,
                    SkTokens.sp4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context
                            .i18n('modules:releases.releases')
                            .toUpperCase(),
                        style: SkText.overline(context),
                      ),
                      const SizedBox(height: SkTokens.sp2),
                      Text(
                        context.i18n(
                          'modules:sandbox.releasesVersions',
                          variables: {'releases': releases.all.length},
                        ),
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                const SkDivider(),
                Expanded(
                  child: CupertinoScrollbar(
                    controller: sandboxScrollController,
                    child: ListView(
                      controller: sandboxScrollController,
                      padding: const EdgeInsets.all(SkTokens.sp3),
                      children: [
                        for (final version in releases.all)
                          SkListRow(
                            dense: true,
                            selected: version.name == selectedRelease.value?.name,
                            onTap: () => selectedRelease.value = version,
                            title: Text(
                              version.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SkText.mono(
                                context,
                                fontSize: 12,
                                color: version.name == selectedRelease.value?.name
                                    ? c.accent
                                    : c.ink1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 右：终端
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SkTokens.sp5,
                    vertical: SkTokens.sp4,
                  ),
                  child: Row(
                    children: [
                      Icon(MdiIcons.folderMultiple, size: 18, color: c.ink2),
                      const SizedBox(width: SkTokens.sp3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: SkTokens.sp1),
                            Text(
                              project.path,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SkText.mono(
                                context,
                                fontSize: 11,
                                color: c.ink3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: SkTokens.sp4),
                      if (processing)
                        SkButton(
                          label: context.i18n('modules:fvm.dialogs.cancel'),
                          variant: SkButtonVariant.danger,
                          onPressed: terminal.endProcess,
                        )
                      else
                        SkChip(
                          label: context.i18n('modules:sandbox.notRunning'),
                          dot: true,
                        ),
                    ],
                  ),
                ),
                const SkDivider(strong: true),
                Expanded(
                  child: selectedRelease.value != null
                      ? SandboxTerminal(
                          project: project,
                          release: selectedRelease.value!,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}