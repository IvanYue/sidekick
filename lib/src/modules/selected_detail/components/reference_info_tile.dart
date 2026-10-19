import 'package:flutter/material.dart';

import '../../../components/atoms/typography.dart';
import '../../../components/molecules/list_tile.dart';
import '../../common/constants.dart';
import '../../common/dto/channel.dto.dart';
import '../../common/dto/release.dto.dart';
import '../../common/utils/helpers.dart';
import '../../common/utils/open_link.dart';
import '../../fvm/components/fvm_setup_button.dart';
import '../../ohos/ohos.constants.dart';
import '../../ohos/ohos.service.dart';

class ReferenceInfoTile extends StatelessWidget {
  final ReleaseDto version;
  const ReferenceInfoTile(
    this.version, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Display channell reference if it's a release
    if (!version.isChannel) {
      return Column(
        children: [
          SkListTile(
            title:
                Text(context.i18n('modules:selectedDetail.components.channel')),
            trailing: Chip(
              label: Text(
                version.isOhosSdk
                    ? kOhosForkName
                    : version.release?.channelName ?? '',
              ),
            ),
          ),
          const Divider(),
          SkListTile(
            title: Text(
                context.i18n('modules:selectedDetail.components.releaseNotes')),
            trailing: IconButton(
              icon: const Icon(
                Icons.open_in_new,
                size: 20,
              ),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Paragraph(channelDescriptions(context)[version.name] ?? ''),
        ),
        const Divider(height: 0),
        SkListTile(
          title:
              Text(context.i18n('modules:selectedDetail.components.version')),
          trailing: channel.sdkVersion != null
              ? Chip(label: Text(channel.sdkVersion ?? ''))
              : SetupButton(release: channel),
        )
      ],
    );
  }
}
