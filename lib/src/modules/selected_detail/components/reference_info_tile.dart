import 'package:flutter/material.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../common/constants.dart';
import '../../common/dto/channel.dto.dart';
import '../../common/dto/release.dto.dart';
import '../../common/utils/helpers.dart';
import '../../common/utils/open_link.dart';
import '../../fvm/components/fvm_setup_button.dart';
import '../../ohos/ohos.constants.dart';
import '../../ohos/ohos.service.dart';
import 'detail_section.dart';

/// 版本详情抽屉的「参考信息」分区。
///
/// 对应 design/index.html 的 `.drawer-section`（参考信息）。
class ReferenceInfoTile extends StatelessWidget {
  /// 构造函数
  const ReferenceInfoTile(
    this.version, {
    super.key,
  });

  /// 版本
  final ReleaseDto version;

  @override
  Widget build(BuildContext context) {
    // Display channell reference if it's a release
    if (!version.isChannel) {
      return DetailSection(
        title: context.i18n(
          'modules:selectedDetail.components.referenceInformation',
        ),
        children: [
          DetailKvRow(
            label: context.i18n('modules:selectedDetail.components.channel'),
            trailing: SkChip(
              label: version.isOhosSdk
                  ? kOhosForkName
                  : version.release?.channelName ?? '',
              outline: true,
            ),
          ),
          DetailKvRow(
            label: context.i18n(
              'modules:selectedDetail.components.releaseNotes',
            ),
            trailing: SkButton(
              label: context.i18n('modules:projects.components.open'),
              icon: Icons.open_in_new,
              variant: SkButtonVariant.ghost,
              size: SkButtonSize.sm,
              onPressed: () async {
                // OHOS SDKs are published as releases on the CPF-Flutter fork,
                // under the tag the installed SDK reports
                final url = version.isOhosSdk
                    ? ohosReleasePageUrl(version.cache)
                    : kFlutterTagsUrl + version.name;
                await openLink(url);
              },
            ),
          ),
        ],
      );
    }

    final channel = version as ChannelDto;
    return DetailSection(
      title: context.i18n(
        'modules:selectedDetail.components.referenceInformation',
      ),
      children: [
        Text(
          channelDescriptions(context)[version.name] ?? '',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: SkTokens.sp3),
        DetailKvRow(
          label: context.i18n('modules:selectedDetail.components.version'),
          trailing: channel.sdkVersion != null
              ? SkChip(label: channel.sdkVersion ?? '', outline: true)
              : SetupButton(release: channel),
        ),
      ],
    );
  }
}
