import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../../common/utils/helpers.dart';
import '../../../common/utils/notify.dart';
import '../project_detail.provider.dart';
import '../project_details.dart';
import '../project_version.dart';

/// 展示并修改 pubspec.yaml 里的应用版本号。
///
/// 对应 design/index.html 的版本页：当前版本（等宽大字）+ 四档自增按钮 +
/// 手动设置版本输入框。
class VersionTab extends HookConsumerWidget {
  /// 构造函数
  const VersionTab({required this.details, super.key});

  /// 从磁盘读到的项目信息
  final ProjectDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final c = SkColors.of(context);

    final raw = details.rawVersion;
    final current = details.version;
    final controller = useTextEditingController(text: raw ?? '');
    final input = useValueListenable(controller);
    final saving = useState(false);

    // 编辑后展示新版本
    useEffect(() {
      controller.text = raw ?? '';
      return null;
    }, [raw]);

    Version? parsedInput;
    try {
      parsedInput = Version.parse(input.text.trim());
    } on FormatException {
      parsedInput = null;
    }

    Future<void> run(Future<Version> Function() edit) async {
      if (saving.value) return;
      final i18next = context.i18next;
      saving.value = true;
      try {
        final version = await edit();
        notify(i18next.t(
          'modules:projects.detail.versionUpdated',
          variables: {'version': version.toString()},
        ));
      } catch (e) {
        notifyError(e.toString());
      } finally {
        if (context.mounted) saving.value = false;
      }
    }

    final editor = ref.read(projectEditorProvider);

    Widget bumpButton(VersionBump bump, String label) {
      final next = bumpVersion(current ?? Version.none, bump);
      final enabled =
          next != null && !saving.value && (current != null || raw == null);
      // 按钮上下两行：操作名 + 会变成的版本号
      return SizedBox(
        width: 150,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled
                ? () => run(() => editor.bump(details.path, bump))
                : null,
            borderRadius: SkTokens.radiusMd,
            hoverColor: c.bgHover,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: SkTokens.sp3),
              decoration: BoxDecoration(
                color: enabled ? c.bgRaised : c.bgRaised.withAlpha(80),
                borderRadius: SkTokens.radiusMd,
                border: Border.all(color: enabled ? c.line : c.lineSoft),
              ),
              child: Column(
                children: [
                  Text(
                    context.i18n(label),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: enabled ? c.ink1 : c.ink3,
                    ),
                  ),
                  const SizedBox(height: SkTokens.sp1),
                  Text(
                    next?.toString() ?? '-',
                    style: SkText.mono(
                      context,
                      fontSize: 11,
                      color: enabled ? c.ink3 : c.ink3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(SkTokens.sp6),
      children: [
        Text(
          context.i18n('modules:projects.detail.currentVersion'),
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: SkTokens.sp1),
        Text(
          raw ?? context.i18n('modules:projects.detail.noVersion'),
          style: SkText.monoLg(context, color: c.ink1).copyWith(fontSize: 22),
        ),
        if (raw != null && current == null) ...[
          const SizedBox(height: SkTokens.sp1),
          Text(
            context.i18n('modules:projects.detail.invalidVersion'),
            style: theme.textTheme.bodySmall?.copyWith(color: c.danger),
          ),
        ],
        const SizedBox(height: SkTokens.sp7),
        Text(
          context.i18n('modules:projects.detail.bumpVersion'),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: SkTokens.sp3),
        Row(
          children: [
            bumpButton(VersionBump.major, 'modules:projects.detail.major'),
            const SizedBox(width: SkTokens.sp2),
            bumpButton(VersionBump.minor, 'modules:projects.detail.minor'),
            const SizedBox(width: SkTokens.sp2),
            bumpButton(VersionBump.patch, 'modules:projects.detail.patch'),
            const SizedBox(width: SkTokens.sp2),
            bumpButton(VersionBump.build, 'modules:projects.detail.build'),
          ],
        ),
        const SizedBox(height: SkTokens.sp3),
        Text(
          context.i18n('modules:projects.detail.bumpHint'),
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: SkTokens.sp7),
        Text(
          context.i18n('modules:projects.detail.setVersion'),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: SkTokens.sp3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 220,
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '1.0.0+1',
                  errorText: input.text.trim().isEmpty || parsedInput != null
                      ? null
                      : context.i18n('modules:projects.detail.invalidVersion'),
                ),
              ),
            ),
            const SizedBox(width: SkTokens.sp3),
            SkButton(
              label: context.i18n('modules:projects.detail.save'),
              variant: SkButtonVariant.primary,
              onPressed: parsedInput == null ||
                      parsedInput.toString() == raw ||
                      saving.value
                  ? null
                  : () {
                      final version = parsedInput!;
                      run(() async {
                        await editor.setVersion(details.path, version);
                        return version;
                      });
                    },
            ),
          ],
        ),
      ],
    );
  }
}
