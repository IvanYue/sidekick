import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../components/mdi_icons.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../components/atoms/typography.dart';
import '../../../modules/common/dto/release.dto.dart';
import '../../fvm/fvm_queue.provider.dart';
import '../../ohos/ohos.constants.dart';
import '../../ohos/ohos.service.dart';
import '../project.dto.dart';

/// Select project release
class ProjectReleaseSelect extends ConsumerWidget {
  /// Constructor
  const ProjectReleaseSelect({
    required this.project,
    required this.releases,
    super.key,
  });

  /// Project
  final FlutterProject project;

  /// Releases
  final List<ReleaseDto> releases;

  /// Caption for the currently pinned version: OHOS pins show their short
  /// name instead of the raw branch name.
  String _pinnedLabel(BuildContext context) {
    final pinned = project.pinnedVersion;
    if (pinned == null) {
      return context.i18n('modules:projects.choose');
    }

    return ohosBranchPattern.hasMatch(pinned.nameWithAlias.split('/').last)
        ? ohosDisplayName(pinned.nameWithAlias)
        : pinned.nameWithAlias;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
        tooltip: context.i18n(
          'modules:projects.components.selectAFlutterSdkVersion',
        ),

        // elevation: 1,
        padding: EdgeInsets.zero,
        onSelected: (version) async {
          await ref
              .read(fvmQueueProvider.notifier)
              .pinVersion(context, project, version);
        },
        itemBuilder: (context) {
          return releases
              .map(
                (version) => PopupMenuItem(
                  value: version.name,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          version.isOhosSdk
                              ? ohosDisplayName(version.name)
                              : version.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      // Distinguish OHOS SDKs in the picker
                      if (version.isOhosSdk) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.phone_android, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          context.i18n('modules:ohos.ohosTag'),
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
              .toList();
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
          constraints: const BoxConstraints(
            maxWidth: 165,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Caption(_pinnedLabel(context)),
              // const SizedBox(width: 20),
              Icon(MdiIcons.menuDown),
            ],
          ),
        ));
  }
}
