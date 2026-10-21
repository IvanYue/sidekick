import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../../common/utils/helpers.dart';
import '../../../common/utils/notify.dart';
import '../project_detail.provider.dart';
import '../project_details.dart';
import '../project_packages.dart';
import '../pub_dev_client.dart';
import 'detail_widgets.dart';

const _actionWidth = 100.0;

/// 依赖列表：解析版本 vs pub.dev 最新版本。
///
/// 对应 design/index.html：分组小标题 + 表头 + 逐行依赖，行内用语义色
/// 标注「已是最新 / 可升级 / 约束过时 / 无法联网」。
class PackagesTab extends ConsumerWidget {
  /// 构造函数
  const PackagesTab({required this.details, super.key});

  /// 从磁盘读到的项目信息
  final ProjectDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final packages = details.packages;
    if (packages.isEmpty) {
      return DetailMessage(
        icon: Icons.inventory_2_outlined,
        message: context.i18n('modules:projects.detail.noDependencies'),
      );
    }

    final latest = <String, AsyncValue<Version>>{
      for (final package in packages)
        if (package.isOnPubDev)
          package.name: ref.watch(latestVersionProvider(package.name)),
    };

    final outdated = packages.where((package) {
      final status = package.statusFor(latest[package.name]?.value);
      return status == PackageStatus.upgradable ||
          status == PackageStatus.constraintOutdated;
    }).length;

    // 取最新版本失败但不是「pub.dev 上没有」的包（离线 / 超时 / 服务端错误）
    final unreachable = [
      for (final MapEntry(:key, :value) in latest.entries)
        if (value.hasError && !_isNotFound(value.error)) key,
    ];
    final loading = latest.values.any((value) => value.isLoading);

    void retry() {
      for (final package in unreachable) {
        ref.invalidate(latestVersionProvider(package));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (details.lockOutdated)
          NoticeBanner(
            message: context.i18n('modules:projects.detail.lockOutdated'),
          ),
        if (unreachable.isNotEmpty)
          NoticeBanner(
            icon: Icons.cloud_off,
            tone: SkChipTone.danger,
            message: context.i18n('modules:projects.detail.pubDevUnavailable'),
            action: SkButton(
              label: context.i18n('modules:projects.detail.retry'),
              size: SkButtonSize.sm,
              onPressed: retry,
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SkTokens.sp6,
            SkTokens.sp4,
            SkTokens.sp6,
            SkTokens.sp1,
          ),
          child: Row(
            children: [
              // 版本还没拿全时，计数会误导用户
              if (unreachable.isEmpty) ...[
                Text(
                  context.i18n(
                    'modules:projects.detail.outdatedCount',
                    variables: {'count': outdated},
                  ),
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(width: SkTokens.sp3),
              ],
              if (loading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              SkTokens.sp6,
              0,
              SkTokens.sp6,
              SkTokens.sp6,
            ),
            children: [
              for (final section in DependencySection.values)
                ..._section(context, section, latest),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _section(
    BuildContext context,
    DependencySection section,
    Map<String, AsyncValue<Version>> latest,
  ) {
    final theme = Theme.of(context);
    final packages = details.packages.where((p) => p.section == section);
    if (packages.isEmpty) return const [];

    final title = section == DependencySection.dependencies
        ? 'modules:projects.detail.dependencies'
        : 'modules:projects.detail.devDependencies';

    return [
      Padding(
        padding: const EdgeInsets.only(top: SkTokens.sp4, bottom: SkTokens.sp1),
        child: Text(
          context.i18n(title),
          style: theme.textTheme.titleSmall,
        ),
      ),
      _HeaderRow(),
      const SkDivider(strong: true),
      for (final package in packages)
        PackageRow(
          projectPath: details.path,
          package: package,
          latest: latest[package.name],
        ),
    ];
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget cell(String key, int flex) => Expanded(
          flex: flex,
          child: Text(
            context.i18n(key),
            style: SkText.overline(context),
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SkTokens.sp2),
      child: Row(
        children: [
          cell('modules:projects.detail.package', 4),
          cell('modules:projects.detail.constraint', 3),
          cell('modules:projects.detail.resolved', 2),
          cell('modules:projects.detail.latest', 2),
          const SizedBox(width: _actionWidth),
        ],
      ),
    );
  }
}

/// 单个依赖
class PackageRow extends ConsumerWidget {
  /// 构造函数
  const PackageRow({
    required this.projectPath,
    required this.package,
    required this.latest,
    super.key,
  });

  /// 依赖所属项目
  final String projectPath;

  /// 依赖
  final ProjectPackage package;

  /// pub.dev 上的最新版本；不在 pub.dev 上时为 null
  final AsyncValue<Version>? latest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    final latestVersion = latest?.value;
    final status = package.statusFor(latestVersion);

    Future<void> upgrade() async {
      final version = latestVersion!;
      final constraint = ProjectPackage.constraintFor(version);
      final i18next = context.i18next;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            context.i18n(
              'modules:projects.detail.upgradeTitle',
              variables: {'package': package.name},
            ),
            style: theme.textTheme.titleLarge,
          ),
          content: Text(
            context.i18n(
              'modules:projects.detail.upgradeMessage',
              variables: {
                'from': package.constraint ?? 'any',
                'to': constraint,
              },
            ),
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            SkButton(
              label: context.i18n('modules:projects.detail.cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            SkButton(
              label: context.i18n('modules:projects.detail.upgrade'),
              variant: SkButtonVariant.primary,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      try {
        await ref
            .read(projectEditorProvider)
            .setConstraint(projectPath, package, constraint);
        notify(i18next.t(
          'modules:projects.detail.constraintUpdated',
          variables: {'package': package.name, 'constraint': constraint},
        ));
      } catch (e) {
        notifyError(e.toString());
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: SkTokens.sp1),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.lineSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              package.name,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(color: c.ink1),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              package.constraint ?? _sourceLabel(package.source),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SkText.mono(context, fontSize: 11, color: c.ink2),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              package.resolved?.toString() ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SkText.mono(context, fontSize: 11, color: c.ink2),
            ),
          ),
          Expanded(flex: 2, child: _latestCell(context, status)),
          SizedBox(
            width: _actionWidth,
            height: 32,
            child: status == PackageStatus.constraintOutdated
                ? Align(
                    alignment: Alignment.centerRight,
                    child: SkButton(
                      label: context.i18n('modules:projects.detail.upgrade'),
                      size: SkButtonSize.sm,
                      onPressed: upgrade,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _latestCell(BuildContext context, PackageStatus status) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    final latest = this.latest;
    if (latest == null) {
      return Text('-', style: theme.textTheme.bodySmall);
    }

    final error = latest.error;
    if (error != null) {
      final notFound = _isNotFound(error);
      return Tooltip(
        message: context.i18n(notFound
            ? 'modules:projects.detail.notOnPubDev'
            : 'modules:projects.detail.pubDevUnavailable'),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            notFound ? Icons.help_outline : Icons.cloud_off,
            size: 16,
            color: c.ink3,
          ),
        ),
      );
    }

    final version = latest.value;
    if (version == null) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final (color, icon, tooltip) = switch (status) {
      PackageStatus.upToDate => (
          c.ok,
          Icons.check_circle_outline,
          'modules:projects.detail.upToDate',
        ),
      PackageStatus.upgradable => (
          c.warn,
          Icons.arrow_circle_up,
          'modules:projects.detail.updateAvailable',
        ),
      PackageStatus.constraintOutdated => (
          c.accent,
          Icons.error_outline,
          'modules:projects.detail.constraintOutdated',
        ),
      PackageStatus.unknown => (null, null, null),
    };

    final text = Text(
      version.toString(),
      style: SkText.mono(context, fontSize: 11, color: color ?? c.ink1),
    );
    if (icon == null || tooltip == null) return text;

    return Tooltip(
      message: context.i18n(tooltip),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: SkTokens.sp1),
          Flexible(child: text),
        ],
      ),
    );
  }
}

String _sourceLabel(DependencySource source) {
  switch (source) {
    case DependencySource.sdk:
      return 'sdk';
    case DependencySource.path:
      return 'path';
    case DependencySource.git:
      return 'git';
    case DependencySource.pubDev:
    case DependencySource.customHosted:
      return 'hosted';
  }
}

bool _isNotFound(Object? error) {
  return error is PubDevException && error.kind == PubDevErrorKind.notFound;
}
