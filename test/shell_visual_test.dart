import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/app_sidebar.dart';
import 'package:sidekick/src/modules/navigation/navigation.provider.dart';
import 'package:sidekick/src/modules/ohos/ohos.dto.dart';
import 'package:sidekick/src/modules/ohos/ohos.provider.dart';
import 'package:sidekick/src/modules/projects/projects.provider.dart';
import 'package:sidekick/src/modules/releases/releases.provider.dart';

import 'helpers/app.dart';

/// 侧边栏的视觉快照：确认导航分组、计数与底部环境状态渲染正常。
void main() {
  testWidgets('sidebar renders workspace group and footer', (tester) async {
    setWindowSize(tester, const Size(700, 520));

    await pumpTestApp(
      tester,
      Scaffold(
        body: Row(
          children: [
            AppSidebar(
              currentRoute: NavigationRoutes.homeScreen,
              onNavigate: (_) {},
            ),
          ],
        ),
      ),
      overrides: [
        // 这几个 provider 正常运行时会读盘 / 发网络请求
        releasesStateProvider.overrideWithValue(AppReleasesState()),
        projectsProvider.overrideWith((ref) => _EmptyProjects()),
        ohosBranchesProvider
            .overrideWith((ref) async => const <OhosBranchItem>[]),
      ],
    );
    await settle(tester);

    expect(find.text('WORKSPACE'), findsOneWidget);
    expect(find.text('Installed'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Releases'), findsOneWidget);
    expect(find.text('OHOS'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await takeScreenshot(tester, 'shell_sidebar');
  });

  testWidgets('design kit controls render on the dark theme', (tester) async {
    setWindowSize(tester, const Size(760, 520));

    await pumpTestApp(
      tester,
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(SkTokens.sp5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: SkTokens.sp3,
                children: [
                  SkButton(label: 'Primary', onPressed: () {}),
                  SkButton(
                    label: 'Primary fill',
                    variant: SkButtonVariant.primary,
                    onPressed: () {},
                  ),
                  SkButton(
                    label: 'Danger',
                    variant: SkButtonVariant.danger,
                    onPressed: () {},
                  ),
                  SkButton(label: 'Disabled'),
                ],
              ),
              const SizedBox(height: SkTokens.sp5),
              Wrap(
                spacing: SkTokens.sp3,
                children: const [
                  SkChip(label: 'neutral'),
                  SkChip(label: 'accent', tone: SkChipTone.accent),
                  SkChip(label: 'ok', tone: SkChipTone.ok, dot: true),
                  SkChip(label: 'warn', tone: SkChipTone.warn),
                  SkChip(label: 'danger', tone: SkChipTone.danger),
                  SkChip(label: 'info', tone: SkChipTone.info),
                ],
              ),
              const SizedBox(height: SkTokens.sp5),
              const SkSegmented(
                items: ['All', 'Release', 'Dev'],
                selectedIndex: 1,
              ),
              const SizedBox(height: SkTokens.sp5),
              const SkNoteBar(
                icon: Icons.info_outline,
                title: 'Note bar',
                description: 'A short supporting sentence next to the title.',
              ),
            ],
          ),
        ),
      ),
    );
    await settle(tester);

    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('accent'), findsOneWidget);
    expect(find.text('Note bar'), findsOneWidget);

    await takeScreenshot(tester, 'design_kit_controls');
  });
}

/// 空项目列表，避免测试里真的去读磁盘
class _EmptyProjects extends ProjectsStateNotifier {
  @override
  Future<void> load() async {
    state = const [];
  }
}
