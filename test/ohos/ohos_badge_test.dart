import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fvm/fvm.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/modules/common/dto/version.dto.dart';
import 'package:sidekick/src/modules/fvm/components/fvm_release_list_item.dart';
import 'package:sidekick/src/modules/ohos/components/ohos_badge.dart';
import 'package:sidekick/src/modules/ohos/ohos.constants.dart';

import '../helpers/app.dart';

const _ohosCached = CacheFlutterVersion(
  'oh-3.41.9-release',
  type: VersionType.unknownRef,
  fork: kOhosForkName,
  directory: '/fake/versions/ohos/oh-3.41.9-release',
  flutterSdkVersion: '3.41.9+ohos-1.0.2',
  dartSdkVersion: null,
  isSetup: true,
);

void main() {
  testWidgets('FvmReleaseListItem shows an actionable OHOS badge for OHOS SDKs',
      (tester) async {
    final ohosDto = VersionDto(
      name: 'ohos/oh-3.41.9-release',
      release: null,
      cache: _ohosCached,
      needSetup: false,
      isGlobal: false,
      isOhosSdk: true,
    );

    await pumpTestApp(tester, FvmReleaseListItem(ohosDto));
    await settle(tester);

    // OHOS versions display the short branch name
    expect(find.text('oh-3.41.9'), findsOneWidget);
    expect(find.byType(OhosBadge), findsOneWidget);
    // The actionable badge is a tappable chip wrapped in a tooltip
    expect(
      find.descendant(
        of: find.byType(OhosBadge),
        matching: find.byType(SkChip),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(OhosBadge),
        matching: find.byType(Tooltip),
      ),
      findsOneWidget,
    );
  });

  testWidgets('FvmReleaseListItem shows no OHOS badge for official versions',
      (tester) async {
    final officialDto = VersionDto(
      name: '3.38.7',
      release: null,
      cache: const CacheFlutterVersion(
        '3.38.7',
        type: VersionType.release,
        directory: '/fake/versions/3.38.7',
        flutterSdkVersion: '3.38.7',
        dartSdkVersion: '3.10.7',
        isSetup: true,
      ),
      needSetup: false,
      isGlobal: false,
    );

    await pumpTestApp(tester, FvmReleaseListItem(officialDto));
    await settle(tester);

    expect(find.byType(OhosBadge), findsNothing);
  });

  testWidgets('OhosBadge renders passively without onPressed', (tester) async {
    await pumpTestApp(tester, const Center(child: OhosBadge()));
    await settle(tester);

    expect(find.byType(SkChip), findsOneWidget);
    // Nothing to tap and nothing to hover-explain
    expect(find.byType(Tooltip), findsNothing);
    expect(find.byType(InkWell), findsNothing);
  });
}