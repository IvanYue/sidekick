import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../components/atoms/empty_dataset.dart';
import '../../components/atoms/refresh_button.dart';
import '../../components/atoms/typography.dart';
import '../../components/organisms/screen.dart';
import '../common/utils/open_link.dart';
import 'components/ohos_branch_list_item.dart';
import 'ohos.constants.dart';
import 'ohos.provider.dart';

/// Screen that browses and manages OHOS Flutter fork versions.
class OhosScreen extends ConsumerWidget {
  const OhosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(ohosBranchesProvider);
    final items = ref.watch(ohosFilterableProvider);
    final filter = ref.watch(ohosFilterProvider.notifier);

    final installedCount =
        (branches.value ?? []).where((item) => item.isInstalled).length;

    return SkScreen(
      title: context.i18n('modules:ohos.title'),
      actions: [
        Text(
          context.i18n(
            'modules:ohos.installedCount',
            variables: {'count': installedCount},
          ),
        ),
        const SizedBox(width: 20),
        Tooltip(
          message: kOhosRepoWebUrl,
          child: IconButton(
            icon: const Icon(Icons.open_in_new, size: 18),
            onPressed: () => openLink(kOhosRepoWebUrl),
          ),
        ),
        RefreshButton(
          onPressed: () =>
              ref.refresh(ohosRemoteBranchesProvider.future),
        ),
        const SizedBox(width: 20),
      ],
      child: branches.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyDataset(
          icon: const Icon(Icons.account_tree),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Subheading(context.i18n('modules:ohos.fetchFailed')),
              const SizedBox(height: 10),
              Caption(context.i18n('modules:ohos.fetchFailedMessage')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => ref.refresh(ohosRemoteBranchesProvider),
                child: Text(context.i18n('modules:ohos.retry')),
              ),
            ],
          ),
        ),
        data: (all) => CustomScrollView(
          primary: false,
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 0),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Heading(context.i18n('modules:ohos.branches')),
                      const SizedBox(width: 10),
                      Chip(label: Text(items.length.toString())),
                    ],
                  ),
                  DropdownButton<String>(
                    value: filter.state.name,
                    icon: const Icon(Icons.filter_list),
                    underline: Container(),
                    items: OhosFilter.values.map((value) {
                      final label = switch (value) {
                        OhosFilter.all => context.i18n('modules:ohos.all'),
                        OhosFilter.release =>
                          context.i18n('modules:ohos.release'),
                        OhosFilter.dev => context.i18n('modules:ohos.dev'),
                      };

                      return DropdownMenuItem(
                        value: value.name,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        filter.state = OhosFilter.values
                            .firstWhere((f) => f.name == value);
                      }
                    },
                  ),
                ],
              ),
            ),
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyDataset(
                  icon: Icon(Icons.account_tree),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Subheading(context.i18n('modules:ohos.noBranches')),
                      const SizedBox(height: 10),
                      Caption(
                        context.i18n('modules:ohos.noBranchesMessage'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Column(
                    children: [
                      OhosBranchListItem(items[index]),
                      const Divider(height: 0),
                    ],
                  ),
                  childCount: items.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
