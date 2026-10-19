import 'package:fvm/fvm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidekick/src/modules/ohos/ohos.dto.dart';
import 'package:sidekick/src/modules/ohos/ohos.service.dart';

const _releaseBranch = OhosBranchDto(
  name: 'oh-3.41.9-release',
  type: OhosBranchType.release,
  version: '3.41.9',
  sha: 'remote-sha',
);

CacheFlutterVersion _cachedVersion({
  String name = 'oh-3.41.9-release',
  String directory = '/fake/versions/ohos/oh-3.41.9-release',
  String? fork = 'ohos',
}) {
  return CacheFlutterVersion(
    name,
    type: VersionType.unknownRef,
    fork: fork,
    directory: directory,
    flutterSdkVersion: '3.41.9+ohos-1.0.2',
    dartSdkVersion: null,
    isSetup: true,
  );
}

void main() {
  group('mergeOhosBranches', () {
    test('pairs remote branches with installed versions', () async {
      final items = await mergeOhosBranches(
        [_releaseBranch],
        [_cachedVersion()],
        (_) async => 'remote-sha',
        null,
      );

      final item = items.single;
      expect(item.isInstalled, isTrue);
      expect(item.branch!.name, 'oh-3.41.9-release');
    });

    test('flags update available when local sha differs from remote', () async {
      final items = await mergeOhosBranches(
        [_releaseBranch],
        [_cachedVersion()],
        (_) async => 'local-sha',
        null,
      );

      expect(items.single.updateAvailable, isTrue);
    });

    test('no update when shas match or local sha unavailable', () async {
      final upToDate = await mergeOhosBranches(
        [_releaseBranch],
        [_cachedVersion()],
        (_) async => 'remote-sha',
        null,
      );
      final unknown = await mergeOhosBranches(
        [_releaseBranch],
        [_cachedVersion()],
        (_) async => null,
        null,
      );

      expect(upToDate.single.updateAvailable, isFalse);
      expect(unknown.single.updateAvailable, isFalse);
    });

    test('keeps orphaned installs whose remote branch was deleted', () async {
      final items = await mergeOhosBranches(
        [_releaseBranch],
        [_cachedVersion(name: 'oh-9.99.9-release')],
        (_) async => 'some-sha',
        null,
      );

      expect(items.length, 2);
      final orphan = items.singleWhere((i) => i.branch == null);
      expect(orphan.isInstalled, isTrue);
      expect(orphan.updateAvailable, isFalse);
      expect(orphan.cache!.name, 'oh-9.99.9-release');
    });

    test('marks installed version as global using qualified name', () async {
      final items = await mergeOhosBranches(
        [_releaseBranch],
        [_cachedVersion()],
        (_) async => null,
        'ohos/oh-3.41.9-release',
      );

      expect(items.single.isGlobal, isTrue);
    });

    test('matches top-level installs and their bare global name', () async {
      final topLevel = _cachedVersion(
        name: 'oh-3.41.9-release',
        directory: '/fake/versions/oh-3.41.9-release',
        fork: null,
      );

      final items = await mergeOhosBranches(
        [_releaseBranch],
        [topLevel],
        (_) async => null,
        'oh-3.41.9-release',
      );

      expect(items.single.isInstalled, isTrue);
      expect(items.single.isGlobal, isTrue);
      // Queue name follows the cache layout: bare for top-level installs
      expect(items.single.toVersionDto().name, 'oh-3.41.9-release');
    });

    test('toVersionDto queue name follows the install layout', () async {
      final installed = await mergeOhosBranches(
        [_releaseBranch],
        [_cachedVersion()],
        (_) async => null,
        null,
      );
      final orphan = await mergeOhosBranches(
        [],
        [_cachedVersion(name: 'oh-9.99.9-release')],
        (_) async => null,
        null,
      );

      expect(installed.single.toVersionDto().name, 'ohos/oh-3.41.9-release');
      expect(orphan.single.toVersionDto().name, 'ohos/oh-9.99.9-release');
      expect(installed.single.toVersionDto().release, isNull);
      expect(installed.single.toVersionDto().needSetup, isFalse);
    });
  });
}
