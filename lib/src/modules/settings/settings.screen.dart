import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../components/mdi_icons.dart';
import '../../modules/common/utils/helpers.dart';
import '../../modules/common/utils/notify.dart';
import 'scenes/flutter_settings.scene.dart';
import 'scenes/fvm_settings.scene.dart';
import 'scenes/general_settings.scene.dart';
import 'settings.provider.dart';

/// TODO: Unify the nav sections information
/// Nav sections
enum NavSection {
  /// General
  general,

  /// FVM
  fvm,

  /// Flutter
  flutter,
}

final _sectionIcons = [
  MdiIcons.tune,
  MdiIcons.layers,
  MdiIcons.console,
];

/// Settings screen
///
/// 对应 design/index.html 的 `#page-settings`：左侧是分区导航（通用 / FVM /
/// Flutter，选中项用 accent 底色），右侧是设置内容面板。
class SettingsScreen extends HookConsumerWidget {
  /// Constructor
  const SettingsScreen({
    this.section = NavSection.general,
    super.key,
  });

  /// Current nav section
  final NavSection section;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(settingsProvider.notifier);
    final settings = ref.watch(settingsProvider);

    final currentSection = useState(section.index);

    final sections = [
      context.i18n('modules:settings.scenes.general'),
      'FVM',
      'Flutter'
    ];

    void changeSection(int idx) {
      currentSection.value = idx;
    }

    Future<void> handleSave() async {
      final savedMessage =
          context.i18n('modules:settings.settingsHaveBeenSaved');
      final errorMessage =
          context.i18n('modules:settings.couldNotSaveSettings');
      try {
        await provider.save(settings);
        notify(savedMessage);
      } on Exception catch (e) {
        notifyError(errorMessage);
        notifyError(e.toString());
      }
    }

    final c = SkColors.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: c.bgApp,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: const [
          CloseButton(),
          SizedBox(width: 10),
        ],
        flexibleSpace: MoveWindow(),
      ),
      body: Padding(
        // 让内容避开可拖拽的标题栏
        padding: const EdgeInsets.only(top: SkTokens.titleBarHeight),
        child: SkPage(
          title: context.i18n('modules:common.navButtonSettings'),
          description:
              context.i18n('modules:settings.scenes.settingsDescription'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧分区导航
              SizedBox(
                width: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < sections.length; i++)
                      SkNavButton(
                        item: SkNavItem(
                          label: sections[i],
                          icon: _sectionIcons[i],
                          selected: currentSection.value == i,
                          onTap: () => changeSection(i),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: SkTokens.sp6),
              // 右侧设置内容
              Expanded(
                child: switch (currentSection.value) {
                  1 => FvmSettingsScene(settings, handleSave),
                  2 => SettingsSectionFlutter(settings, handleSave),
                  _ => SettingsSectionGeneral(settings, handleSave),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}