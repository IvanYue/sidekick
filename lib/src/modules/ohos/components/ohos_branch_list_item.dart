import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../components/mdi_icons.dart';
import '../../../components/atoms/typography.dart';
import '../../../components/molecules/list_tile.dart';
import '../../fvm/components/fvm_release_actions.dart';
import '../../fvm/components/fvm_setup_button.dart';
import '../../fvm/dialogs/fvm_global_dialog.dart';
import '../../fvm/fvm_queue.provider.dart';
import '../../selected_detail/selected_detail.provider.dart';
import '../ohos.dto.dart';
import '../ohos.service.dart';

/// List item for an OHOS branch: install, update and manage it.
class OhosBranchListItem extends ConsumerWidget {
  const OhosBranchListItem(
    this.item, {
    super.key,
  });

  final OhosBranchItem item;

  // Queue matching is by name: provider rebuilds recreate DTO instances, so
  // object identity (used by VersionInstallButton) would lose the spinner.
  bool _isInQueue(WidgetRef ref, String name) {
    final queue = ref.watch(fvmQueueProvider);
    if (queue.activeItem?.version.name == name) return true;

    return queue.queue.any((i) => i.version.name == name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dto = item.toVersionDto();
    final isQueued = _isInQueue(ref, dto.name);
    final branch = item.branch;

    return SkListTile(
      leading: Icon(
        branch?.type == OhosBranchType.dev ? Icons.bolt : MdiIcons.alphaRCircle,
      ),
      title: Row(
        children: [
          // Short display name: the type shows as a badge next to it
          Subheading(ohosDisplayName(branch?.name ?? item.cache!.name)),
          const SizedBox(width: 10),
          if (branch != null)
            Chip(
              label: Caption(
                branch.type == OhosBranchType.release
                    ? context.i18n('modules:ohos.release')
                    : context.i18n('modules:ohos.dev'),
              ),
              visualDensity: VisualDensity.compact,
            ),
          const SizedBox(width: 10),
          if (item.isGlobal)
            ActionChip(
              avatar: Icon(MdiIcons.information, size: 20),
              label: Caption(context.i18n('modules:fvm.components.global')),
              onPressed: () => showGlobalInfoDialog(context),
            ),
          const Spacer(),
          if (item.updateAvailable)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_upward, size: 16),
                const SizedBox(width: 4),
                Caption(context.i18n('modules:ohos.updateAvailable')),
              ],
            ),
        ],
      ),
      subtitle: Caption(
        branch != null
            ? '${branch.sha.substring(0, 7)}'
                '${branch.extra != null ? ' · ${branch.extra}' : ''}'
            : context.i18n('modules:ohos.orphanBranch'),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.isInstalled) ...[
            if (item.cache!.isNotSetup) SetupButton(release: dto),
            IconButton(
              icon: Icon(MdiIcons.update, size: 20),
              tooltip: branch != null
                  ? context.i18n('modules:ohos.updateOhosVersion')
                  : context.i18n('modules:ohos.orphanBranch'),
              // Orphaned installs have no remote branch to pull from
              onPressed: branch == null
                  ? null
                  : () => ref
                      .read(fvmQueueProvider.notifier)
                      .ohosUpdate(context, dto),
            ),
            FvmReleaseActions(dto),
          ] else
            isQueued
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: SpinKitFadingFour(
                      size: 15,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_downward, size: 20),
                    tooltip: context.i18n('modules:ohos.installOhosVersion'),
                    onPressed: () => ref
                        .read(fvmQueueProvider.notifier)
                        .install(context, dto),
                  ),
        ],
      ),
      onTap: () {
        ref.read(selectedDetailProvider.notifier).state = SelectedDetail(
          release: dto,
        );
      },
    );
  }
}
