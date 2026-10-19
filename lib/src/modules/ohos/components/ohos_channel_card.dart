import 'package:flutter/material.dart';
import 'package:fvm/fvm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../components/atoms/typography.dart';
import '../../navigation/navigation.provider.dart';
import '../ohos.dto.dart';
import '../ohos.provider.dart';
import '../ohos.service.dart';

/// OHOS card in the Releases channel showcase.
///
/// Summarizes the OHOS fork (latest release branch + install count) and jumps
/// to the OHOS management screen instead of a detail drawer.
class OhosChannelCard extends ConsumerWidget {
  const OhosChannelCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(ohosRemoteBranchesProvider);
    final mergedAsync = ref.watch(ohosBranchesProvider);

    final branches = branchesAsync.value ?? const <OhosBranchDto>[];
    final latest =
        branches.firstWhereOrNull((b) => b.type == OhosBranchType.release)
            // Branches are sorted newest first, so this is the latest release
            ??
            (branches.isEmpty ? null : branches.first);

    final installedCount = (mergedAsync.value ?? const [])
        .where((item) => item.isInstalled)
        .length;

    return Card(
      child: InkWell(
        onTap: () => ref
            .read(navigationProvider.notifier)
            .goTo(NavigationRoutes.ohosScreen),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Heading('OHOS'),
                  Subheading(
                      latest != null ? ohosDisplayName(latest.name) : ''),
                  const SizedBox(height: 5),
                  Caption(
                    context.i18n(
                      'modules:ohos.installedCount',
                      variables: {'count': installedCount},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
