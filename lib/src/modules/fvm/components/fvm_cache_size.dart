import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/tokens.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../modules/common/utils/dir_stat.dart';
import '../fvm.provider.dart';

/// 缓存占用统计格。
///
/// 对应 design/index.html `.stat-strip` 的第二格「占用空间」：
/// 大号等宽数值 + 下方小灰字标签，并附一条「使用中 / 未使用」占比细进度条。
class FvmCacheSize extends HookConsumerWidget {
  /// 构造函数
  const FvmCacheSize({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    final cacheSize = ref.watch(cacheSizeProvider);
    final unusedSize = useState(DirectorySizeInfo());
    ref
        .watch(unusedReleaseSizeProvider)
        .whenData((value) => unusedSize.value = value);

    // 缓存大小为 0 时数据尚未就绪，占位保持标签可见
    final hasSize = cacheSize.totalSize != 0;
    final unusedPercentage =
        hasSize ? unusedSize.value.totalSize / cacheSize.totalSize : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SkTokens.sp5,
        vertical: SkTokens.sp4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hasSize ? cacheSize.friendlySize : '—',
            style: SkText.mono(context, fontSize: 18, color: c.ink1),
          ),
          const SizedBox(height: 2),
          Text(
            context.i18n('modules:fvm.statsCacheSize'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(color: c.ink3),
          ),
          if (hasSize) ...[
            const SizedBox(height: SkTokens.sp2),
            ClipRRect(
              borderRadius: SkTokens.radiusFull,
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: (1 - unusedPercentage).clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: c.bgInset,
                  valueColor: AlwaysStoppedAnimation<Color>(c.accent),
                ),
              ),
            ),
            const SizedBox(height: SkTokens.sp1),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${context.i18n('modules:fvm.components.inUse')} '
                    '${((1 - unusedPercentage) * 100).round()}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SkText.mono(context, fontSize: 10, color: c.ink3),
                  ),
                ),
                Text(
                  '${context.i18n('modules:fvm.components.unused')} '
                  '${(unusedPercentage * 100).round()}%',
                  style: SkText.mono(context, fontSize: 10, color: c.ink3),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}