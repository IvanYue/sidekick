import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../common/dto/release.dto.dart';
import '../../common/utils/helpers.dart';
import 'cache_date_display.dart';
import 'detail_section.dart';

/// 版本详情抽屉的「本地缓存信息」分区。
///
/// 对应 design/index.html 的 `.drawer-section`（本地缓存信息）。
class FvmInfoTile extends StatelessWidget {
  /// 构造函数
  const FvmInfoTile(
    this.release, {
    super.key,
  });

  /// 版本
  final ReleaseDto release;

  @override
  Widget build(BuildContext context) {
    if (!release.isCached) {
      return const SizedBox(height: 0);
    }

    final directory = release.cache?.directory ?? '';

    return DetailSection(
      title: context
          .i18n('modules:selectedDetail.components.localCacheInformation'),
      children: [
        DetailKvRow(
          label: context.i18n('modules:selectedDetail.components.createdDate'),
          trailing: CacheDateDisplay(release),
        ),
        DetailKvRow(
          label:
              context.i18n('modules:selectedDetail.components.cacheLocation'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  directory,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: SkText.mono(
                    context,
                    fontSize: 11,
                    color: SkColors.of(context).ink1,
                  ),
                ),
              ),
              const SizedBox(width: SkTokens.sp2),
              DetailCopyButton(directory),
              const SizedBox(width: SkTokens.sp1),
              SkIconButton(
                icon: Icons.open_in_new,
                size: 22,
                iconSize: 14,
                color: SkColors.of(context).ink3,
                onPressed: () async {
                  await OpenFile.open(release.cache?.directory);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
