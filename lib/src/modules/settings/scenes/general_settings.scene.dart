import 'package:flutter/material.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/i18n/language_manager.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../modules/common/utils/notify.dart';
import '../../ide/components/ide_selection_tile.dart';
import '../../updater/components/update_button.dart';
import '../../../version.dart';
import '../settings.dto.dart';
import '../settings.utils.dart';

/// Settings section general
///
/// 对应 design/index.html 的「通用」面板：每项是「标题 + 说明」一行，
/// 右侧跟一个控件（SkSelect / SkButton）。
class SettingsSectionGeneral extends StatelessWidget {
  /// Constructor
  const SettingsSectionGeneral(
    this.settings,
    this.onSave, {
    super.key,
  });

  /// Settings
  final AllSettings settings;

  /// On save handler
  final void Function() onSave;

  /// 主题下拉的显示文案
  String _themeLabel(BuildContext context, String themeMode) {
    switch (themeMode) {
      case SettingsThemeMode.light:
        return context.i18n('modules:settings.scenes.light');
      case SettingsThemeMode.dark:
        return context.i18n('modules:settings.scenes.dark');
      default:
        return context.i18n('modules:settings.scenes.system');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void handleReset() async {
      // flutter defined function
      await showDialog(
        context: context,
        builder: (context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text(context.i18n(
                'modules:settings.scenes.areYouSureYouWantToResetSettings')),
            content: Text(
              context.i18n(
                  'modules:settings.scenes.thisWillOnlyResetSidekickSpecificPreferences'),
            ),
            buttonPadding: const EdgeInsets.all(15),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              SkButton(
                label: context.i18n('modules:fvm.dialogs.cancel'),
                variant: SkButtonVariant.ghost,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SkButton(
                label: context.i18n('modules:fvm.dialogs.confirm'),
                variant: SkButtonVariant.primary,
                onPressed: () async {
                  Navigator.of(context).pop();
                  settings.sidekick = SidekickSettings();
                  onSave();
                  notify(context.i18n(
                      'modules:settings.scenes.appSettingsHaveBeenReset'));
                },
              ),
            ],
          );
        },
      );
    }

    // 主题选项：显示本地化文案，回调里映射回存储用的原始值
    final themeLabels = [
      context.i18n('modules:settings.scenes.system'),
      context.i18n('modules:settings.scenes.light'),
      context.i18n('modules:settings.scenes.dark'),
    ];
    const themeModes = [
      SettingsThemeMode.system,
      SettingsThemeMode.light,
      SettingsThemeMode.dark,
    ];

    // 语言选项：显示语言名，回调里映射回 Locale
    final locales = languageManager.supportedLocales.toList();
    final languageLabels = [
      for (final locale in locales)
        context.i18n('settings:sidekick.language.${locale.toLanguageTag()}'),
    ];
    final currentLocale = settings.sidekick.locale ?? context.locale;
    final currentLocaleIndex =
        locales.indexWhere((locale) => locale == currentLocale);

    /// 一行设置项：标题 + 说明，右侧是控件。
    Widget row({
      required String title,
      String? description,
      required Widget trailing,
      Widget? leading,
    }) {
      return SkListRow(
        leading: leading,
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: description == null
            ? null
            : Text(
                description,
                style: theme.textTheme.labelSmall,
              ),
        trailing: trailing,
      );
    }

    return SkPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkPanelHeader(
            title: context.i18n('modules:settings.scenes.general'),
            subtitle: context
                .i18n('modules:settings.scenes.changesAreSavedImmediately'),
          ),
          row(
            title: context.i18n('modules:settings.scenes.theme'),
            description: context.i18n(
                'modules:settings.scenes.selectAThemeOrSwitchAccordingToSystemSettings'),
            trailing: SkSelect(
              value: _themeLabel(context, settings.sidekick.themeMode),
              items: themeLabels,
              onChanged: (label) async {
                final index = themeLabels.indexOf(label);
                if (index == -1) return;
                settings.sidekick.themeMode = themeModes[index];
                onSave();
              },
            ),
          ),
          const SkDivider(),
          // IDE 选择沿用已有的检测 / 自定义应用逻辑
          IdeSelectionTile(settings, onSave),
          const SkDivider(),
          row(
            title: context.i18n('modules:settings.scenes.language'),
            description:
                context.i18n('modules:settings.scenes.languageDescription'),
            trailing: SkSelect(
              value: currentLocaleIndex == -1
                  ? languageLabels.first
                  : languageLabels[currentLocaleIndex],
              items: languageLabels,
              onChanged: (label) async {
                final index = languageLabels.indexOf(label);
                if (index == -1) return;
                settings.sidekick.locale = locales[index];
                onSave();
              },
            ),
          ),
          const SkDivider(),
          // 版本号 + 检查更新：「检查」原本在标题栏，改到设置里更合适
          row(
            title: context.i18n('modules:selectedDetail.components.version'),
            description: packageVersion,
            trailing: const UpdateCheckButton(),
          ),
          const SkDivider(),
          row(
            title:
                context.i18n('modules:settings.scenes.resetToDefaultSettings'),
            description: context.i18n(
                'modules:settings.scenes.thisWillOnlyResetSidekickSpecificPreferences'),
            trailing: SkButton(
              label: context.i18n('modules:settings.scenes.reset'),
              variant: SkButtonVariant.secondary,
              size: SkButtonSize.sm,
              onPressed: handleReset,
            ),
          ),
        ],
      ),
    );
  }
}
