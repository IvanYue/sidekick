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

    // 最新分支若已装在本地，就显示本地的 Flutter / Dart 版本；否则只有远端
    // 分支名解析出的 Flutter 版本，Dart 版本无从得知。
    final installedLatest = (mergedAsync.value ?? const [])
        .where((item) => item.isInstalled && item.branch?.name == latest?.name)
        .firstOrNull;
    final flutterVersion = installedLatest?.cache?.flutterSdkVersion ??
        (latest == null ? null : ohosDisplayName(latest.name));
    final dartVersion = installedLatest?.cache?.dartSdkVersion;

    return SkPanel(
      padding: const EdgeInsets.all(SkTokens.sp4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref
              .read(navigationProvider.notifier)
              .goTo(NavigationRoutes.ohosScreen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              // 说明固定三行高度，和相邻渠道卡保持同一基线
              SizedBox(
                height: 54,
                child: Text(
                  context.i18n('modules:ohos.ohosDescription'),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ),
              // 撑开中间空白，把底部操作区顶到卡片下沿
              const Spacer(),
              // 最新分支版本 + 已安装计数。渠道卡窄，两个版本号上下两行放，
              // 同一行卡片的下沿因此仍然对齐。
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          flutterVersion ?? '—',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              SkText.mono(context, fontSize: 12, color: c.ink1),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dart ${dartVersion ?? '—'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              SkText.mono(context, fontSize: 11, color: c.ink3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SkTokens.sp3),
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
