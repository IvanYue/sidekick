import 'package:flutter/material.dart';

import 'package:sidekick/src/design/kit/kit.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../project_details.dart';

/// 居中的图标 + 文案，用于空态与错误态。
///
/// 现在直接复用设计系统的 [SkEmptyState]，保留旧的命名以免改动调用方。
class DetailMessage extends StatelessWidget {
  /// 构造函数
  const DetailMessage({
    required this.icon,
    required this.message,
    this.action,
    this.tone = SkChipTone.neutral,
    super.key,
  });

  /// 图标
  final IconData icon;

  /// 文案
  final String message;

  /// 可选操作按钮
  final Widget? action;

  /// 语义色
  final SkChipTone tone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SkTokens.sp7),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SkEmptyState(
            icon: icon,
            tone: tone,
            title: message,
            action: action,
          ),
        ),
      ),
    );
  }
}

/// 高亮提示条，可带一个操作按钮。
///
/// 现在直接复用设计系统的 [SkNoteBar]，保留旧的命名以免改动调用方。
class NoticeBanner extends StatelessWidget {
  /// 构造函数
  const NoticeBanner({
    required this.message,
    this.icon = Icons.info_outline,
    this.tone = SkChipTone.accent,
    this.action,
    super.key,
  });

  /// 文案
  final String message;

  /// 图标
  final IconData icon;

  /// 语义色
  final SkChipTone tone;

  /// 可选操作按钮
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SkTokens.sp6,
        SkTokens.sp4,
        SkTokens.sp6,
        0,
      ),
      child: SkNoteBar(
        icon: icon,
        tone: tone,
        description: message,
        trailing: action,
      ),
    );
  }
}

/// 标签 + 值的行。
class InfoRow extends StatelessWidget {
  /// 构造函数
  const InfoRow({
    required this.label,
    required this.child,
    super.key,
  });

  /// 标签
  final String label;

  /// 值
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SkTokens.sp3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: theme.textTheme.labelSmall),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// 项目详情页里的平台标签（Android / iOS / …）。
class PlatformChip extends StatelessWidget {
  /// 构造函数
  const PlatformChip(this.platform, {super.key});

  /// 平台
  final ProjectPlatform platform;

  static const _labels = {
    ProjectPlatform.android: 'Android',
    ProjectPlatform.ios: 'iOS',
    ProjectPlatform.macos: 'macOS',
    ProjectPlatform.web: 'Web',
    ProjectPlatform.windows: 'Windows',
    ProjectPlatform.linux: 'Linux',
  };

  static const _icons = {
    ProjectPlatform.android: Icons.android,
    ProjectPlatform.ios: Icons.phone_iphone,
    ProjectPlatform.macos: Icons.laptop_mac,
    ProjectPlatform.web: Icons.language,
    ProjectPlatform.windows: Icons.desktop_windows_outlined,
    ProjectPlatform.linux: Icons.terminal,
  };

  @override
  Widget build(BuildContext context) {
    return SkChip(
      label: _labels[platform]!,
      icon: _icons[platform],
    );
  }
}
