import 'package:flutter/material.dart';
import 'package:fvm/fvm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../navigation/navigation.provider.dart';
import '../ohos.dto.dart';
import '../ohos.provider.dart';
import '../ohos.service.dart';

/// 发行版页渠道行里的 OHOS 卡。
///
/// 对应 design/index.html `#page-releases` 的 `.chan-card`：汇总 OHOS fork
/// 的最新 release 分支与已安装数量，点击跳到 OHOS 管理页而不是详情抽屉。
class OhosChannelCard extends ConsumerWidget {
  /// 构造函数
  const OhosChannelCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    final branchesAsync = ref.watch(ohosRemoteBranchesProvider);
    final mergedAsync = ref.watch(ohosBranchesProvider);

    final branches = branchesAsync.value ?? const <OhosBranchDto>[];
    final latest =
        branches.firstWhereOrNull((b) => b.type == OhosBranchType.release)
            // 分支按新到旧排序，因此第一个 release 就是最新的
            ??
            (branches.isEmpty ? null : branches.first);

    final installedCount = (mergedAsync.value ?? const [])
        .where((item) => item.isInstalled)
        .length;

    return SkPanel(
      padding: const EdgeInsets.all(SkTokens.sp4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref
              .read(navigationProvider.notifier)
              .goTo(NavigationRoutes.ohosScreen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 渠道名 + OHOS 徽章
              Row(
                children: [
                  Icon(Icons.phone_android, size: 18, color: c.ok),
                  const SizedBox(width: SkTokens.sp3),
                  Text('OHOS', style: theme.textTheme.titleMedium),
                  const SizedBox(width: SkTokens.sp3),
                  SkChip(
                    label: context.i18n('modules:ohos.ohosTag'),
                    tone: SkChipTone.ok,
                  ),
                ],
              ),
              const SizedBox(height: SkTokens.sp3),
              Text(
                context.i18n('modules:ohos.ohosDescription'),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: SkTokens.sp4),
              // 最新分支 + 已安装计数
              Row(
                children: [
                  Flexible(
                    child: Text(
                      latest != null ? ohosDisplayName(latest.name) : '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SkText.mono(context, fontSize: 12, color: c.ink1),
                    ),
                  ),
                  const Spacer(),
                  SkChip(
                    label: context.i18n(
                      'modules:ohos.installedCount',
                      variables: {'count': installedCount},
                    ),
                    tone: SkChipTone.ok,
                    outline: true,
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