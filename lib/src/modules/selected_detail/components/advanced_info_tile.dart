import 'package:flutter/material.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../common/dto/release.dto.dart';
import '../../common/utils/helpers.dart';
import '../../common/utils/open_link.dart';
import 'detail_section.dart';

/// 版本详情抽屉的「高级」分区。
///
/// 对应 design/index.html 的 `.drawer-section`（高级）：下载 zip、Hash、Sha256。
class AdvancedInfoTile extends StatelessWidget {
  /// 构造函数
  const AdvancedInfoTile(
    this.release, {
    super.key,
  });

  /// 版本
  final ReleaseDto release;

  @override
  Widget build(BuildContext context) {
    if (release.release == null) {
      return const SizedBox(height: 0);
    }

    final c = SkColors.of(context);
    final hash = release.release?.hash ?? '';
    final sha256 = release.release?.sha256 ?? '';

    return DetailSection(
      title: context.i18n('modules:selectedDetail.components.advanced'),
      children: [
        DetailKvRow(
          label: context.i18n(
            'modules:selectedDetail.components.downloadZip',
          ),
          trailing: SkIconButton(
            icon: Icons.cloud_download_outlined,
            size: 22,
            iconSize: 14,
            color: c.ink3,
            onPressed: () async {
              await openLink(release.release?.archiveUrl ?? '');
            },
          ),
        ),
        DetailKvRow(
          label: context.i18n('modules:selectedDetail.components.hash'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  hash,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: SkText.mono(context, fontSize: 11, color: c.ink1),
                ),
              ),
              const SizedBox(width: SkTokens.sp2),
              DetailCopyButton(hash),
            ],
          ),
        ),
        DetailKvRow(
          label: context.i18n('modules:selectedDetail.components.sha256'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  sha256,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: SkText.mono(context, fontSize: 11, color: c.ink1),
                ),
              ),
              const SizedBox(width: SkTokens.sp2),
              DetailCopyButton(sha256),
            ],
          ),
        ),
      ],
    );
  }
}
