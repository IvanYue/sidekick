/// 设计系统组件库统一出口。
///
/// 页面层只允许从 `package:sidekick/src/design/kit/kit.dart` 导入组件，
/// 避免直接依赖内部实现文件。
library;

export 'controls.dart';
export 'layout.dart';
export 'surfaces.dart';
