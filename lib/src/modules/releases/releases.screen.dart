import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../modules/common/utils/helpers.dart';
import '../fvm/fvm.provider.dart';
import '../ohos/components/ohos_channel_card.dart';
import 'components/channel_showcase_item.dart';
import 'components/release_list_item.dart';
import 'releases.provider.dart';

/// 发行版页。
///
/// 对应 design/index.html 的 `#page-releases`：页头 + 渠道卡（stable / beta /
/// master / OHOS）+ 版本库筛选栏 + 版本列表。
class ReleasesScreen extends ConsumerWidget {
  /// 构造函数
  const ReleasesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releases = ref.watch(releasesStateProvider);
    final versions = ref.watch(filterableReleasesProvider);
    final filter = ref.watch(filterProvider.notifier);

    final c = SkColors.of(context);

    // 渠道筛选：展示名 -> 枚举值
    final filterLabels = <Filter, String>{
      Filter.all: context.i18n('modules:releases.all'),
      Filter.stable: Filter.stable.name.capitalize(),
      Filter.beta: Filter.beta.name.capitalize(),
    };
    final currentLabel = filterLabels[ref.watch(filterProvider)]!;

    return SkPage(
      title: context.i18n('modules:releases.releases'),
      description: context.i18n('modules:releases.releasesDescription'),
      processing: releases.fetching,
      actions: SkIconButton(
        icon: Icons.refresh,
        tooltip: context.i18n('components:atoms.refresh'),
        // 远端列表与本地缓存一起重取：远端失败时会回落到磁盘缓存
        onPressed: () {
          ref.invalidate(flutterReleasesProvider);
          ref.read(fvmCacheProvider.notifier).reloadState();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 渠道卡：stable / beta / master / OHOS
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final channel in releases.channels) ...[
                  Expanded(child: ChannelShowcaseItem(channel)),
                  const SizedBox(width: SkTokens.sp4),
                ],
                if (releases.master != null) ...[
                  Expanded(child: ChannelShowcaseItem(releases.master!)),
                  const SizedBox(width: SkTokens.sp4),
                ],
                const Expanded(child: OhosChannelCard()),
              ],
            ),
          ),
          const SizedBox(height: SkTokens.sp7),

          // 版本库筛选栏
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SkTokens.sp4,
              vertical: SkTokens.sp3,
            ),
            decoration: BoxDecoration(
              color: c.bgPanel,
              borderRadius: SkTokens.radiusMd,
              border: Border.all(color: c.lineSoft),
            ),
            child: Row(
              children: [
                Text(
                  context.i18n('modules:releases.versions').toUpperCase(),
                  style: SkText.overline(context, color: c.ink2),
                ),
                const SizedBox(width: SkTokens.sp3),
                SkChip(label: '${versions.length}'),
                const Spacer(),
                SkSelect(
                  value: currentLabel,
                  width: 150,
                  items: filterLabels.values.toList(),
                  onChanged: (label) {
                    final entry =
                        filterLabels.entries.firstWhere((e) => e.value == label);
                    filter.state = entry.key;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: SkTokens.sp4),

          // 版本列表 / 空态 / 加载中
          if (releases.fetching || versions.isEmpty)
            SkPanel(
              child: SkEmptyState(
                icon: releases.fetching
                    ? Icons.downloading_outlined
                    : releases.remoteUnavailable
                        ? Icons.cloud_off_outlined
                        : Icons.inbox_outlined,
                tone: releases.remoteUnavailable
                    ? SkChipTone.warn
                    : SkChipTone.neutral,
                title: releases.fetching
                    ? context.i18n('modules:releases.loading')
                    : releases.remoteUnavailable
                        ? context.i18n('modules:releases.unavailable')
                        : context.i18n('modules:releases.empty'),
                description: releases.fetching
                    ? null
                    : releases.remoteUnavailable
                        ? context.i18n('modules:releases.unavailableMessage')
                        : context.i18n('modules:releases.emptyMessage'),
              ),
            )
          else
            SkPanel(
              flush: true,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final version in versions) ReleaseListItem(version),
                ],
              ),
            ),
        ],
      ),
    );
  }
}