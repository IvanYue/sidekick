import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import '../tokens.dart';

/// 窗口标题栏。
///
/// 对应 design/tokens.css 的 `.titlebar`：高 44、bgSidebar 底、底部一条 lineSoft 描边。
/// 三段式布局：left（品牌 / 窗口按钮）、center（居中的搜索框）、actions（右侧图标按钮）。
///
/// 整条标题栏都是窗口拖拽区（[MoveWindow]），拖拽层放在最底层，
/// 交互控件（按钮、搜索框）位于其上，优先级更高。
class SkTitleBar extends StatelessWidget {
  /// 构造函数
  const SkTitleBar({
    super.key,
    this.leading,
    this.brand,
    this.center,
    this.actions,
    this.height = SkTokens.titleBarHeight,
    this.centerWidth = 300,
  });

  /// 左侧区域（macOS 交通灯 / 返回按钮）
  final Widget? leading;

  /// 品牌区（图标 + 名称 + 版本号）
  final Widget? brand;

  /// 居中区（搜索框）
  final Widget? center;

  /// 右侧操作区
  final Widget? actions;

  /// 标题栏高度
  final double height;

  /// 居中区域宽度
  final double centerWidth;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: c.bgSidebar,
        border: Border(bottom: BorderSide(color: c.lineSoft)),
      ),
      child: Stack(
        children: [
          // 拖拽层：位于最底，整条标题栏可拖动窗口
          Positioned.fill(child: MoveWindow()),

          // 左侧：窗口按钮 + 品牌
          Positioned(
            left: SkTokens.sp4,
            top: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: SkTokens.sp3),
                ],
                if (brand != null) brand!,
              ],
            ),
          ),

          // 居中：绝对居中于整条标题栏
          if (center != null)
            Positioned.fill(
              child: Center(
                child: SizedBox(width: centerWidth, child: center),
              ),
            ),

          // 右侧操作区
          if (actions != null)
            Positioned(
              right: SkTokens.sp4,
              top: 0,
              bottom: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [actions!],
              ),
            ),
        ],
      ),
    );
  }
}

/// 侧边栏导航项。
class SkNavItem {
  /// 构造函数
  const SkNavItem({
    required this.label,
    required this.icon,
    this.count,
    this.selected = false,
    this.onTap,
  });

  /// 文案
  final String label;

  /// 图标
  final IconData icon;

  /// 右侧计数
  final String? count;

  /// 是否选中
  final bool selected;

  /// 点击回调
  final VoidCallback? onTap;
}

/// 侧边栏导航分组。
class SkNavGroup {
  /// 构造函数
  const SkNavGroup({
    required this.label,
    required this.items,
  });

  /// 分组标题
  final String label;

  /// 分组内的导航项
  final List<SkNavItem> items;
}

/// 侧边栏。
///
/// 对应 design/tokens.css 的 `.sidebar`：宽 232、bgSidebar 底、右侧 lineSoft 描边。
class SkSidebar extends StatelessWidget {
  /// 构造函数
  const SkSidebar({
    super.key,
    required this.groups,
    this.footer,
    this.width = SkTokens.sidebarWidth,
  });

  /// 导航分组
  final List<SkNavGroup> groups;

  /// 底部区域
  final Widget? footer;

  /// 侧边栏宽度
  final double width;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: c.bgSidebar,
        border: Border(right: BorderSide(color: c.lineSoft)),
      ),
      padding: const EdgeInsets.fromLTRB(
        SkTokens.sp3,
        SkTokens.sp5,
        SkTokens.sp3,
        SkTokens.sp3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < groups.length; i++) ...[
            if (i > 0) const SizedBox(height: SkTokens.sp5),
            _NavGroupView(group: groups[i]),
          ],
          if (footer != null) ...[
            const Spacer(),
            const SizedBox(height: SkTokens.sp4),
            Divider(color: c.lineSoft, height: 1),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _NavGroupView extends StatelessWidget {
  const _NavGroupView({required this.group});

  final SkNavGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SkTokens.sp3,
            0,
            SkTokens.sp3,
            SkTokens.sp2,
          ),
          child: Text(
            group.label.toUpperCase(),
            style: SkText.overline(context),
          ),
        ),
        for (final item in group.items) SkNavButton(item: item),
      ],
    );
  }
}

/// 单个侧边栏导航按钮。
class SkNavButton extends StatelessWidget {
  /// 构造函数
  const SkNavButton({
    super.key,
    required this.item,
  });

  /// 导航项数据
  final SkNavItem item;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);
    final fg = item.selected ? c.accent : c.ink2;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: SkTokens.radiusSm,
        hoverColor: c.bgHover,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: SkTokens.sp3),
          decoration: BoxDecoration(
            color: item.selected ? c.accentSoft : Colors.transparent,
            borderRadius: SkTokens.radiusSm,
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: fg),
              const SizedBox(width: SkTokens.sp3),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: fg,
                    fontWeight:
                        item.selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (item.count != null)
                Text(
                  item.count!,
                  style: SkText.mono(
                    context,
                    fontSize: 10,
                    color: item.selected ? c.accent : c.ink3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 页面标题区。
///
/// 对应 design/tokens.css 的 `.page-head`：左侧标题 + 描述，右侧操作区。
class SkPageHeader extends StatelessWidget {
  /// 构造函数
  const SkPageHeader({
    super.key,
    required this.title,
    this.description,
    this.actions,
  });

  /// 主标题
  final String title;

  /// 描述文案
  final String? description;

  /// 右侧操作
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.displaySmall,
              ),
              if (description != null) ...[
                const SizedBox(height: SkTokens.sp1),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Text(
                    description!,
                    style: theme.textTheme.bodySmall?.copyWith(color: c.ink3),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actions != null) ...[
          const SizedBox(width: SkTokens.sp6),
          actions!,
        ],
      ],
    );
  }
}

/// 页面骨架。
///
/// 结构：可滚动的内容区 + 顶部页头（标题 / 描述 / 操作）+ 进度条。
class SkPage extends StatelessWidget {
  /// 构造函数
  const SkPage({
    super.key,
    required this.title,
    this.description,
    this.actions,
    this.processing = false,
    this.scrollController,
    this.padding = const EdgeInsets.fromLTRB(
      SkTokens.sp7,
      SkTokens.sp7,
      SkTokens.sp8,
      SkTokens.sp9,
    ),
    required this.child,
  });

  /// 页面标题
  final String title;

  /// 页面描述
  final String? description;

  /// 页头右侧操作
  final Widget? actions;

  /// 是否展示顶部进度条
  final bool processing;

  /// 滚动控制器
  final ScrollController? scrollController;

  /// 内容内边距
  final EdgeInsets padding;

  /// 页面主体
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SkTokens.sp7,
            SkTokens.sp7,
            SkTokens.sp8,
            0,
          ),
          child: SkPageHeader(
            title: title,
            description: description,
            actions: actions,
          ),
        ),
        SizedBox(
          height: 3,
          child: processing
              ? const LinearProgressIndicator(minHeight: 3)
              : const SizedBox.shrink(),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: padding.copyWith(top: SkTokens.sp6),
            child: child,
          ),
        ),
      ],
    );
  }
}

/// 品牌标记（titlebar 里的方形字母块）。
class SkBrandMark extends StatelessWidget {
  /// 构造函数
  const SkBrandMark({
    super.key,
    required this.letter,
    this.size = 20,
  });

  /// 标记字母
  final String letter;

  /// 尺寸
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.accent,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Text(
        letter,
        style: theme.textTheme.titleSmall?.copyWith(
          color: c.onAccent,
          fontSize: size * 0.55,
          height: 1,
        ),
      ),
    );
  }
}
