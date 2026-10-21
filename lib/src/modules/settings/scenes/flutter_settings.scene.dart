import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../releases/releases.provider.dart';
import '../settings.dto.dart';

/// Flutter 设置面板。
///
/// 对应 design/index.html 的「Flutter」面板：每项是「标题 + 说明」一行，
/// 右侧跟一个 [SkSwitch]。
class SettingsSectionFlutter extends ConsumerWidget {
  /// 构造函数
  const SettingsSectionFlutter(
    this.settings,
    this.onSave, {
    super.key,
  });

  /// 设置
  final AllSettings settings;

  /// 保存回调
  final Function() onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final releases = ref.watch(releasesStateProvider);

    final deactivate = !releases.hasGlobal;

    /// 一行开关设置项。
    Widget row({
      required String title,
      String? description,
      required bool value,
      required ValueChanged<bool>? onChanged,
    }) {
      return SkListRow(
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: onChanged == null ? SkColors.of(context).ink3 : null,
          ),
        ),
        subtitle: description == null
            ? null
            : Text(
                description,
                style: theme.textTheme.labelSmall,
              ),
        trailing: SkSwitch(
          value: value,
          onChanged: onChanged,
        ),
      );
    }

    return SkPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkPanelHeader(
            title: 'Flutter',
            subtitle: context
                .i18n('modules:settings.scenes.changesAreSavedImmediately'),
          ),
          if (!releases.hasGlobal) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SkTokens.sp5,
                SkTokens.sp4,
                SkTokens.sp5,
                0,
              ),
              child: SkNoteBar(
                icon: Icons.info_outline,
                tone: SkChipTone.warn,
                description: context.i18n(
                  'modules:settings.scenes.flutterSDKGlobalDescription',
                ),
              ),
            ),
          ],
          row(
            title: context.i18n(
              'modules:settings.scenes.analyticsCrashReporting',
            ),
            description: context.i18n(
              'modules:settings.scenes.analyticsCrashReportSubtitle',
            ),
            value: settings.flutter.analytics,
            onChanged: deactivate
                ? null
                : (value) {
                    settings.flutter.analytics = value;
                    onSave();
                  },
          ),
          const SkDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SkTokens.sp6,
              SkTokens.sp5,
              SkTokens.sp6,
              SkTokens.sp2,
            ),
            child: Text(
              context
                  .i18n('modules:settings.scenes.platforms')
                  .toUpperCase(),
              style: SkText.overline(context),
            ),
          ),
          row(
            title: context.i18n('modules:settings.scenes.web'),
            value: settings.flutter.web,
            onChanged: deactivate
                ? null
                : (value) {
                    settings.flutter.web = value;
                    onSave();
                  },
          ),
          const SkDivider(),
          row(
            title: 'macOS',
            value: settings.flutter.macos,
            onChanged: deactivate
                ? null
                : (value) {
                    settings.flutter.macos = value;
                    onSave();
                  },
          ),
          const SkDivider(),
          row(
            title: 'Windows',
            value: settings.flutter.windows,
            onChanged: deactivate
                ? null
                : (value) {
                    settings.flutter.windows = value;
                    onSave();
                  },
          ),
          const SkDivider(),
          row(
            title: 'Linux',
            value: settings.flutter.linux,
            onChanged: deactivate
                ? null
                : (value) {
                    settings.flutter.linux = value;
                    onSave();
                  },
          ),
        ],
      ),
    );
  }
}