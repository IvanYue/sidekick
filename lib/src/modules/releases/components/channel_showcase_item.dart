import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../../components/molecules/version_install_button.dart';
import '../../../modules/common/dto/channel.dto.dart';
import '../../common/constants.dart';
import '../../common/utils/helpers.dart';
import '../../selected_detail/selected_detail.provider.dart';

/// 渠道展示卡。
///
/// 对应 design/index.html `#page-releases` 的 `.chan-card`：图标 + 渠道名、
/// 渠道说明、底部是当前版本号（等宽）与安装按钮。整卡可点，打开版本详情抽屉。
class ChannelShowcaseItem extends ConsumerWidget {
  /// 构造函数
  const ChannelShowcaseItem(
    this.channel, {
    super.key,
  });

  /// 渠道数据
  final ChannelDto channel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    final description = channelDescriptions(context)[channel.name];
    // 优先展示已安装的 SDK 版本，未安装时回落官方最新版本
    final version = channel.sdkVersion ?? channel.release?.version;
    final tone = _channelTone(channel.name);
    final accent = _toneColor(c, tone);

    return SkPanel(
      padding: const EdgeInsets.all(SkTokens.sp4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(selectedDetailProvider.notifier).state = SelectedDetail(
              release: channel,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 渠道名
              Row(
                children: [
                  Icon(_channelIcon(channel.name), size: 18, color: accent),
                  const SizedBox(width: SkTokens.sp3),
                  Text(channel.name.capitalize(), style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: SkTokens.sp3),
              // 渠道说明
              if (description != null)
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              const SizedBox(height: SkTokens.sp4),
              // 当前版本 + 安装按钮
              Row(
                children: [
                  Flexible(
                    child: Text(
                      version ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SkText.mono(context, fontSize: 12, color: c.ink1),
                    ),
                  ),
                  const Spacer(),
                  VersionInstallButton(channel, showLabel: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 各渠道的图标。
IconData _channelIcon(String name) {
  switch (name) {
    case 'stable':
      return Icons.check_circle_outline;
    case 'beta':
      return Icons.bolt;
    case kMasterChannel:
      return Icons.view_in_ar;
    default:
      return Icons.layers_outlined;
  }
}

/// 各渠道的语义色：stable=info、beta=warn、master=accent。
SkChipTone _channelTone(String name) {
  switch (name) {
    case 'stable':
      return SkChipTone.info;
    case 'beta':
      return SkChipTone.warn;
    case kMasterChannel:
      return SkChipTone.accent;
    default:
      return SkChipTone.neutral;
  }
}

/// 语义色取色。
Color _toneColor(SkColors c, SkChipTone tone) {
  switch (tone) {
    case SkChipTone.accent:
      return c.accent;
    case SkChipTone.ok:
      return c.ok;
    case SkChipTone.warn:
      return c.warn;
    case SkChipTone.danger:
      return c.danger;
    case SkChipTone.info:
      return c.info;
    case SkChipTone.neutral:
      return c.ink3;
  }
}