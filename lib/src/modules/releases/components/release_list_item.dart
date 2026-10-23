import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../../components/mdi_icons.dart';
import '../../../components/molecules/sdk_version_meta.dart';
import '../../../components/molecules/version_install_button.dart';
import '../../../modules/common/dto/release.dto.dart';
import '../../common/utils/helpers.dart';
import '../../selected_detail/selected_detail.provider.dart';

/// 版本列表行。
///
/// 对应 design/index.html `#page-releases` 的列表（`.list-item.compact`）：
/// 左侧版本类型瓦片 + 等宽版本号 + 渠道 / 全局徽章，次行是 Flutter / Dart
/// 版本与发布日期，右侧是安装按钮。
class ReleaseListItem extends ConsumerWidget {
  /// 构造函数
  const ReleaseListItem(
    this.release, {
    super.key,
  });

  /// 列表项对应的发行版
  final ReleaseDto release;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = SkColors.of(context);
    // 渠道优先取渠道自身的名字，普通发行版取它所属的渠道
    final channel =
        release.isChannel ? release.name : release.release?.channelName;
    final releaseDate = release.release?.releaseDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkListRow(
          dense: true,
          onTap: () {
            ref.read(selectedDetailProvider.notifier).state = SelectedDetail(
              release: release,
            );
          },
          leading: _ReleaseTile(isChannel: release.isChannel),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  release.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SkText.mono(context, fontSize: 12, color: c.ink1),
                ),
              ),
              if (channel != null) ...[
                const SizedBox(width: SkTokens.sp3),
                SkChip(
                  label: channel,
                  tone: _channelTone(channel),
                  // stable 与设计稿一致，只用描边不填充
                  outline: channel == 'stable',
                ),
              ],
              if (release.isGlobal) ...[
                const SizedBox(width: SkTokens.sp3),
                SkChip(
                  label: context.i18n('modules:fvm.components.global'),
                  tone: SkChipTone.info,
                  icon: Icons.star_outline,
                ),
              ],
            ],
          ),
          // 次行：Flutter / Dart 版本 + 发布日期
          subtitle: SdkVersionMeta(
            flutterVersion: release.sdkFlutterVersion,
            dartVersion: release.sdkDartVersion,
            extra: [
              if (releaseDate != null)
                Text(
                  DateTimeFormat.format(releaseDate, format: 'Y-m-d'),
                  style: SkText.mono(context, fontSize: 11, color: c.ink3),
                ),
            ],
          ),
          trailing: VersionInstallButton(release),
        ),
        const SkDivider(),
      ],
    );
  }
}

/// 渠道徽章的语义色。
///
/// 对应 design/tokens.css：stable 走描边、beta / dev 用 warn、master 用 accent。
SkChipTone _channelTone(String channel) {
  switch (channel) {
    case 'master':
      return SkChipTone.accent;
    case 'beta':
    case 'dev':
      return SkChipTone.warn;
    default:
      return SkChipTone.neutral;
  }
}

/// 版本类型图标瓦片。
///
/// 对应 design/tokens.css 的 `.tile`（26×26、radiusSm）：渠道用 C 图标，
/// 普通发行版用 R 图标。
class _ReleaseTile extends StatelessWidget {
  /// 构造函数
  const _ReleaseTile({required this.isChannel});

  /// 是否渠道
  final bool isChannel;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);

    return Container(
      width: SkTokens.controlHeightSm,
      height: SkTokens.controlHeightSm,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.bgRaised,
        borderRadius: SkTokens.radiusSm,
        border: Border.all(color: c.lineSoft),
      ),
      child: Icon(
        isChannel ? MdiIcons.alphaCCircle : MdiIcons.alphaRCircle,
        size: 14,
        color: c.ink2,
      ),
    );
  }
}
