import 'package:flutter/material.dart';
import 'package:sidekick/src/modules/common/utils/helpers.dart';

import '../../../components/atoms/typography.dart';

/// Small "OHOS" badge used next to version and project names.
///
/// When [onPressed] is given the badge is actionable (e.g. opens the OHOS
/// repository, or a specific version's release page); otherwise it is purely
/// informational.
class OhosBadge extends StatelessWidget {
  const OhosBadge({this.onPressed, this.tooltip, super.key});

  /// Invoked when the badge is tapped; null renders a passive chip.
  final VoidCallback? onPressed;

  /// Tooltip text; defaults to the OHOS repository wording.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final label = context.i18n('modules:ohos.ohosTag');
    final icon = const Icon(Icons.phone_android, size: 14);
    final message = tooltip ?? context.i18n('modules:ohos.openOhosRepo');

    if (onPressed == null) {
      return Chip(
        visualDensity: VisualDensity.compact,
        avatar: icon,
        label: Caption(label),
      );
    }

    return Tooltip(
      message: message,
      child: ActionChip(
        visualDensity: VisualDensity.compact,
        avatar: icon,
        label: Caption(label),
        onPressed: onPressed,
      ),
    );
  }
}
