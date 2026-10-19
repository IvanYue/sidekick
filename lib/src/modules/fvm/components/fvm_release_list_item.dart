import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../components/mdi_icons.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../components/atoms/typography.dart';
import '../../../components/molecules/list_tile.dart';
import '../../../modules/common/dto/release.dto.dart';
import '../../common/utils/open_link.dart';
import '../../ohos/components/ohos_badge.dart';
import '../../ohos/ohos.service.dart';
import '../../selected_detail/selected_detail.provider.dart';
import '../dialogs/fvm_global_dialog.dart';
import 'fvm_release_actions.dart';
import 'fvm_release_status.dart';

/// FVM release list item
class FvmReleaseListItem extends ConsumerWidget {
  /// Constructor
  const FvmReleaseListItem(
    this.release, {
    super.key,
  });

  /// Release
  final ReleaseDto release;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SkListTile(
      leading: release.isChannel
          ? Icon(MdiIcons.alphaCCircle)
          : Icon(MdiIcons.alphaRCircle),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // OHOS versions show their short name; the badge next to them
          // carries the OHOS meaning
          Subheading(
            release.isOhosSdk ? ohosDisplayName(release.name) : release.name,
          ),
          // OHOS SDKs: badge opens this version's CPF-Flutter release page
          if (release.isOhosSdk)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: OhosBadge(
                tooltip: context.i18n('modules:ohos.openOhosRelease'),
                onPressed: () => openLink(ohosReleasePageUrl(release.cache)),
              ),
            ),
          const SizedBox(width: 20),
          release.isGlobal
              ? ActionChip(
                  label: Caption(context.i18n('modules:fvm.components.global')),
                  avatar: Icon(MdiIcons.information, size: 20),
                  onPressed: () {
                    showGlobalInfoDialog(context);
                  },
                )
              : Container(),
          const Spacer(),
          FvmReleaseStatus(release),
        ],
      ),
      trailing: FvmReleaseActions(release),
      onTap: () {
        ref.read(selectedDetailProvider.notifier).state = SelectedDetail(
          release: release,
        );
      },
    );
  }
}
