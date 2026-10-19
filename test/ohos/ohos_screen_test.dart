import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidekick/src/modules/ohos/ohos.dto.dart';
import 'package:sidekick/src/modules/ohos/ohos.provider.dart';
import 'package:sidekick/src/modules/ohos/ohos.screen.dart';

import '../helpers/app.dart';

const _branches = [
  OhosBranchDto(
    name: 'oh-3.41.9-release',
    type: OhosBranchType.release,
    version: '3.41.9',
    sha: '62357a93d653bf844f730bb1f4b7cc9e2139d14e',
  ),
  OhosBranchDto(
    name: 'oh-3.41.9-dev',
    type: OhosBranchType.dev,
    version: '3.41.9',
    sha: 'e0b83362e7a1eebd72eddecf6f9e0180a16f7465',
  ),
];

void main() {
  testWidgets('renders remote branches with type chips and install buttons',
      (tester) async {
    await pumpTestApp(
      tester,
      const OhosScreen(),
      overrides: [
        ohosRemoteBranchesProvider.overrideWith((ref) async => _branches),
      ],
    );
    await settle(tester);

    // Both branch types show the short name; the type is a separate badge
    expect(find.text('oh-3.41.9'), findsNWidgets(2));
    expect(find.text('Release'), findsOneWidget);
    expect(find.text('Dev'), findsOneWidget);
    // Uninstalled branches show an install button. The count depends on
    // the machine's real cache (the merged provider reads ~/fvm), so only
    // assert presence, not the exact number.
    expect(find.byIcon(Icons.arrow_downward), findsAtLeastNWidgets(1));
    expect(
      find.byTooltip('Install this OHOS branch'),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('shows error state with retry on fetch failure', (tester) async {
    await pumpTestApp(
      tester,
      const OhosScreen(),
      overrides: [
        ohosRemoteBranchesProvider.overrideWith((ref) async {
          throw Exception('network down');
        }),
      ],
    );
    await settle(tester);

    expect(find.text('Could not fetch OHOS branches'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows the empty state when no branches exist', (tester) async {
    await pumpTestApp(
      tester,
      const OhosScreen(),
      overrides: [
        ohosRemoteBranchesProvider.overrideWith((ref) async => []),
        // Merged provider is overridden directly so the machine's real
        // cache can't add orphaned installs to the list
        ohosBranchesProvider.overrideWith((ref) async => []),
      ],
    );
    await settle(tester);

    expect(find.text('No OHOS branches found'), findsOneWidget);
  });
}
