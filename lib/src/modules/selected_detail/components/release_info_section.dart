import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';

import '../../common/dto/release.dto.dart';
import '../../common/utils/helpers.dart';
import 'advanced_info_tile.dart';
import 'detail_section.dart';

/// 版本详情抽屉的「发布详情」分区。
///
/// 对应 design/index.html 的 `.drawer-section`（发布详情）。
class ReleaseInfoSection extends StatelessWidget {
  /// 构造函数
  const ReleaseInfoSection(
    this.version, {
    super.key,
  });

  /// 版本
  final ReleaseDto version;

  @override
  Widget build(BuildContext context) {
    final releaseDate = version.release?.releaseDate;
    if (version.release == null || releaseDate == null) {
      return const SizedBox(height: 0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailSection(
          title: context.i18n(
            'modules:selectedDetail.components.releaseDetails',
          ),
          children: [
            DetailKvRow(
              label: context.i18n(
                'modules:selectedDetail.components.releaseDate',
              ),
              value: DateTimeFormat.format(
                releaseDate,
                format: AmericanDateFormats.abbr,
              ),
              mono: true,
            ),
          ],
        ),
        AdvancedInfoTile(version),
      ],
    );
  }
}
