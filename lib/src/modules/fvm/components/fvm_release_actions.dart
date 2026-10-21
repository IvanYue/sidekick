import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../../components/mdi_icons.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../modules/common/dto/release.dto.dart';
import '../../selected_detail/selected_detail.provider.dart';
import '../dialogs/fvm_delete_dialog.dart';
import '../fvm_queue.provider.dart';

/// 已安装版本可执行的操作。
enum FvmReleaseActionOptions {
  /// 删除版本
  remove,

  /// 查看详情
  detail,

  /// 设为全局
  global,

  /// 更新渠道
  upgrade,
}

/// 已缓存版本的操作菜单。
///
/// 对应 design/tokens.css 的 `.icon-btn`：一个竖向三点图标按钮，
/// 点开是带图标与文案的下拉菜单。
class FvmReleaseActions extends ConsumerWidget {
  /// 构造函数
  const FvmReleaseActions(
    this.release, {
    super.key,
  });

  /// 版本
  final ReleaseDto release;

  /// 渲染菜单项
  List<PopupMenuEntry<FvmReleaseActionOptions>> renderMenuOptions(
      BuildContext context) {
    PopupMenuItem<FvmReleaseActionOptions> item({
      required FvmReleaseActionOptions value,
      required IconData icon,
      required String label,
    }) {
      return PopupMenuItem(
        value: value,
        height: 34,
        child: Row(
          children: [
            Icon(icon, size: 15),
            const SizedBox(width: SkTokens.sp3),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    final menus = <PopupMenuEntry<FvmReleaseActionOptions>>[
      item(
        value: FvmReleaseActionOptions.global,
        label: context.i18n('modules:fvm.components.setAsGlobal'),
        icon: MdiIcons.earth,
      ),
      item(
        value: FvmReleaseActionOptions.detail,
        label: context.i18n('modules:pubPackages.components.details'),
        icon: MdiIcons.information,
      ),
      item(
        value: FvmReleaseActionOptions.remove,
        label: context.i18n('modules:projects.components.remove'),
        icon: MdiIcons.delete,
      ),
    ];

    // 只有渠道版本才能「更新」
    if (release.isChannel) {
      menus.insert(
        0,
        item(
          value: FvmReleaseActionOptions.upgrade,
          label: context.i18n('modules:fvm.components.upgrade'),
          icon: MdiIcons.update,
        ),
      );
    }

    return menus;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = SkColors.of(context);

    return PopupMenuButton<FvmReleaseActionOptions>(
      tooltip: '',
      onSelected: (result) {
        if (result == FvmReleaseActionOptions.remove) {
          showDeleteDialog(context, item: release, onDelete: () {
            ref.read(fvmQueueProvider.notifier).remove(context, release);
          });
        }

        if (result == FvmReleaseActionOptions.detail) {
          ref.read(selectedDetailProvider.notifier).state = SelectedDetail(
            release: release,
          );
        }

        if (result == FvmReleaseActionOptions.global) {
          ref.read(fvmQueueProvider.notifier).setGlobal(context, release);
        }

        if (result == FvmReleaseActionOptions.upgrade) {
          ref.read(fvmQueueProvider.notifier).upgrade(context, release);
        }
      },
      itemBuilder: (context) => renderMenuOptions(context),
      child: SizedBox(
        width: SkTokens.iconButtonSize,
        height: SkTokens.iconButtonSize,
        child: Icon(MdiIcons.dotsVertical, size: 18, color: c.ink2),
      ),
    );
  }
}
