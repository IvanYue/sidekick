import 'package:flutter/material.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/tokens.dart';

/// 版本行的次行元信息：`Flutter 3.41.9 · Dart 3.13.5`。
///
/// 已安装版本、发行版版本库、OHOS 分支三处列表共用，保证同一版在三个页面里
/// 的读法完全一致。两个版本号都可能缺失（远端老版本没有 `dart_sdk_version`，
/// 本地缓存未 setup 时也读不到），缺失的一侧显示 `—` 占位，行结构不塌陷。
class SdkVersionMeta extends StatelessWidget {
  /// 构造函数
  const SdkVersionMeta({
    super.key,
    this.flutterVersion,
    this.dartVersion,
    this.leading = const [],
    this.extra = const [],
  });

  /// Flutter（SDK）版本
  final String? flutterVersion;

  /// Dart 版本
  final String? dartVersion;

  /// 排在版本号之前的片段（如渠道名、commit sha）
  final List<Widget> leading;

  /// 追加在版本号之后的片段（如发布日期）
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);

    // 每段都包 Flexible：窗口变窄时各段一起收缩、省略，而不是撑破列表行
    final slots = <Widget>[
      ...leading,
      Flexible(
        child: Text(
          'Flutter ${flutterVersion ?? '—'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: SkText.mono(context, fontSize: 11, color: c.ink3),
        ),
      ),
      Flexible(
        child: Text(
          'Dart ${dartVersion ?? '—'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: SkText.mono(context, fontSize: 11, color: c.ink3),
        ),
      ),
      ...extra,
    ];

    return Row(
      children: [
        for (var i = 0; i < slots.length; i++) ...[
          if (i > 0) ...[
            const SizedBox(width: SkTokens.sp3),
            const _MetaSeparator(),
            const SizedBox(width: SkTokens.sp3),
          ],
          slots[i],
        ],
      ],
    );
  }
}

/// 元信息之间的细点分隔（`.li-meta .sep`）。
class _MetaSeparator extends StatelessWidget {
  /// 构造函数
  const _MetaSeparator();

  @override
  Widget build(BuildContext context) {
    final c = SkColors.of(context);
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(color: c.lineStrong, shape: BoxShape.circle),
    );
  }
}