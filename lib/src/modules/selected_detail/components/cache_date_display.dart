import 'dart:io';

import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sidekick/src/design/colors.dart';
import 'package:sidekick/src/design/tokens.dart';

import '../../common/dto/release.dto.dart';

/// 缓存目录的创建日期。
///
/// 对应 design/tokens.css 的 `.kv-v.mono`：等宽字体的小号日期。
class CacheDateDisplay extends HookWidget {
  /// 构造函数
  const CacheDateDisplay(
    this.release, {
    super.key,
  });

  /// 版本
  final ReleaseDto? release;

  @override
  Widget build(BuildContext context) {
    final cacheDirStat = useState<FileStat?>(null);

    void setCacheDir() async {
      if (release != null && release?.isCached == true) {
        cacheDirStat.value = await (release?.cache == null ? null : Directory(release!.cache!.directory).stat());
      }
    }

    useEffect(() {
      setCacheDir();
      return;
    }, [release]);

    if (cacheDirStat.value == null) {
      return const SizedBox(height: 0);
    }

    final cacheDir = cacheDirStat.value?.changed;

    if (cacheDir == null) {
      return const SizedBox(height: 0, width: 0);
    }

    return Text(
      DateTimeFormat.format(
        cacheDir,
        format: AmericanDateFormats.abbr,
      ),
      textAlign: TextAlign.right,
      style: SkText.mono(
        context,
        fontSize: 11,
        color: SkColors.of(context).ink1,
      ),
    );
  }
}
