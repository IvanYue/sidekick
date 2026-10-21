import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../design/colors.dart';
import '../../design/kit/kit.dart';
import '../../design/tokens.dart';
import '../common/utils/helpers.dart';
import '../common/utils/open_link.dart';
import 'components/ohos_branch_list_item.dart';
import 'ohos.constants.dart';
import 'ohos.provider.dart';

/// OHOS Flutter fork 版本管理页。
///
/// 对应 design/index.html 的 `#page-ohos`：页头 + fork 说明 hero +
/// 筛选栏（全部 / Release / Dev）+ 分支列表；空态与网络失败态用 [SkEmptyState]。
class OhosScreen extends ConsumerWidget {
  /// 构造函数
  const OhosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(ohosBranchesProvider);
    final items = ref.watch(ohosFilterableProvider);
    final filter = ref.watch(ohosFilterProvider.notifier);

    final all = branches.value ?? const [];
    final installedCount = all.where((item) => item.isInstalled).length;
    final updateCount = all.where((item) => item.updateAvailable).length;

    final c = SkColors.of(context);

    // 筛选选项：OhosFilter 枚举顺序 = 全部 / Release / Dev
    final filters = OhosFilter.values;
    final filterLabels = filters.map((value) {
      return switch (value) {
        OhosFilter.all => context.i18n('modules:ohos.all'),
        OhosFilter.release => context.i18n('modules:ohos.release'),
        OhosFilter.dev => context.i18n('modules:ohos.dev'),
      };
    }).toList();

    return SkPage(
      title: context.i18n('modules:ohos.title'),
      description: context.i18n('modules:ohos.ohosDescription'),
      processing: branches.isLoading,
      actions: SkIconButton(
        icon: Icons.refresh,
        tooltip: context.i18n('components:atoms.refresh'),
        onPressed: () => ref.refresh(ohosRemoteBranchesProvider.future),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // fork 说明强调区
          SkNoteBar(
            icon: Icons.phone_android,
            title: 'CPF-Flutter / flutter_flutter',
            description: context.i18n('modules:ohos.ohosDescription'),
            tone: SkChipTone.ok,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HeroStat(
                  value: '$installedCount',
                  label: context.i18n('modules:ohos.statInstalled'),
                ),
                const SizedBox(width: SkTokens.sp6),
                _HeroStat(
                  value: '${all.length}',
                  label: context.i18n('modules:ohos.statRemoteBranches'),
                ),
                const SizedBox(width: SkTokens.sp6),
                _HeroStat(
                  value: '$updateCount',
                  label: context.i18n('modules:ohos.statUpdatePending'),
                ),
                const SizedBox(width: SkTokens.sp6),
                Tooltip(
                  message: kOhosRepoWebUrl,
                  child: SkButton(
                    label: context.i18n('modules:ohos.openRepo'),
                    icon: Icons.open_in_new,
                    onPressed: () => openLink(kOhosRepoWebUrl),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SkTokens.sp6),

          // 筛选栏：全部 / Release / Dev + 已安装计数
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
                  context.i18n('modules:ohos.branches').toUpperCase(),
                  style: SkText.overline(context, color: c.ink2),
                ),
                const SizedBox(width: SkTokens.sp3),
                SkChip(label: '${items.length}'),
                const Spacer(),
                SkChip(
                  label: context.i18n(
                    'modules:ohos.installedCount',
                    variables: {'count': installedCount},
                  ),
                  tone: SkChipTone.ok,
                  dot: true,
                ),
                const SizedBox(width: SkTokens.sp4),
                SkSegmented(
                  items: filterLabels,
                  selectedIndex: filters.indexOf(ref.watch(ohosFilterProvider)),
                  onChanged: (index) => filter.state = filters[index],
                ),
              ],
            ),
          ),
          const SizedBox(height: SkTokens.sp4),

          // 分支列表 / 空态 / 失败态
          branches.when(
            loading: () => const SkPanel(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: SkTokens.sp8),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, _) => SkPanel(
              child: SkEmptyState(
                icon: Icons.error_outline,
                tone: SkChipTone.danger,
                title: context.i18n('modules:ohos.fetchFailed'),
                description: context.i18n('modules:ohos.fetchFailedMessage'),
                action: SkButton(
                  label: context.i18n('modules:ohos.retry'),
                  icon: Icons.refresh,
                  onPressed: () => ref.refresh(ohosRemoteBranchesProvider),
                ),
              ),
            ),
            data: (_) => items.isEmpty
                ? SkPanel(
                    child: SkEmptyState(
                      icon: Icons.account_tree_outlined,
                      title: context.i18n('modules:ohos.noBranches'),
                      description:
                          context.i18n('modules:ohos.noBranchesMessage'),
                    ),
                  )
                : SkPanel(
                    flush: true,
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final item in items) OhosBranchListItem(item),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// hero 里的统计项：等宽数值 + 小号标签。
class _HeroStat extends StatelessWidget {
  /// 构造函数
  const _HeroStat({required this.value, required this.label});

  /// 数值
  final String value;

  /// 标签
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value, style: SkText.mono(context, fontSize: 16, color: c.ink1)),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
