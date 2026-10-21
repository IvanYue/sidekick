import 'package:flutter/material.dart';

import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';
import '../../../common/utils/helpers.dart';
import '../../project.dto.dart';
import '../project_details.dart';
import '../project_packages.dart';
import 'detail_widgets.dart';

/// Project summary: icon, description, Flutter version, platforms
class OverviewTab extends StatelessWidget {
  /// Constructor
  const OverviewTab({
    required this.project,
    required this.details,
    super.key,
  });

  /// Project
  final FlutterProject project;

  /// Details read from disk
  final ProjectDetails details;

  @override
  Widget build(BuildContext context) {
    final pinned = project.pinnedVersion?.nameWithAlias;
    final dependencies = details.packages
        .where((p) => p.section == DependencySection.dependencies)
        .length;
    final devDependencies = details.packages.length - dependencies;
    final description = details.description ?? '';

    final theme = Theme.of(context);
    final c = SkColors.of(context);

    return ListView(
      padding: const EdgeInsets.all(SkTokens.sp6),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: SkTokens.radiusLg,
              child: SizedBox(
                width: 72,
                height: 72,
                child: FutureBuilder<Widget>(
                  future: project.icon,
                  initialData: project.cachedIcon,
                  builder: (context, snapshot) =>
                      snapshot.data ?? const SizedBox(),
                ),
              ),
            ),
            const SizedBox(width: SkTokens.sp6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: SkTokens.sp1),
                  Text(
                    details.rawVersion ??
                        context.i18n('modules:projects.detail.noVersion'),
                    style: theme.textTheme.bodySmall,
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: SkTokens.sp3),
                    Text(description, style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: SkTokens.sp6),
        SkDivider(strong: true),
        const SizedBox(height: SkTokens.sp3),
        InfoRow(
          label: context.i18n('modules:projects.detail.flutterVersion'),
          child: Text(
            pinned ?? context.i18n('modules:projects.detail.notPinned'),
            style: theme.textTheme.bodyMedium?.copyWith(color: c.ink1),
          ),
        ),
        InfoRow(
          label: context.i18n('modules:projects.detail.dartSdk'),
          child: Text(
            details.dartSdk ?? '-',
            style: theme.textTheme.bodyMedium?.copyWith(color: c.ink1),
          ),
        ),
        InfoRow(
          label: context.i18n('modules:projects.detail.platforms'),
          child: details.platforms.isEmpty
              ? Text(
                  context.i18n('modules:projects.detail.noPlatforms'),
                  style: theme.textTheme.bodyMedium,
                )
              : Wrap(
                  spacing: SkTokens.sp3,
                  runSpacing: SkTokens.sp3,
                  children: [
                    for (final platform in details.platforms)
                      PlatformChip(platform),
                  ],
                ),
        ),
        InfoRow(
          label: context.i18n('modules:projects.detail.packages'),
          child: Text(
            context.i18n(
              'modules:projects.detail.dependencyCount',
              variables: {
                'dependencies': dependencies,
                'devDependencies': devDependencies,
              },
            ),
            style: theme.textTheme.bodyMedium?.copyWith(color: c.ink1),
          ),
        ),
        InfoRow(
          label: context.i18n('modules:projects.detail.location'),
          child: SelectableText(
            project.path,
            style: SkText.mono(context, fontSize: 11, color: c.ink1),
          ),
        ),
      ],
    );
  }
}
