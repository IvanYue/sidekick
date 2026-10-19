import 'package:fvm/fvm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidekick/src/modules/releases/releases.provider.dart';

void main() {
  group('AppReleasesState.addUntrackedCachedVersions', () {
    final ohosVersion = CacheFlutterVersion(
      '3.41.9',
      type: VersionType.release,
      directory: '/fake/versions/3.41.9',
      flutterSdkVersion: null,
      dartSdkVersion: null,
      isSetup: false,
    );

    final officialCached = CacheFlutterVersion(
      '3.38.7',
      type: VersionType.release,
      directory: '/fake/versions/3.38.7',
      flutterSdkVersion: '3.38.7',
      dartSdkVersion: '3.10.7',
      isSetup: true,
    );

    test('synthesizes untracked cached versions into installed list', () {
      final state = AppReleasesState();
      state.generateMap();

      state.addUntrackedCachedVersions([officialCached, ohosVersion], null);

      expect(state.all.length, 2);
      expect(state.allMap['3.41.9'], isNotNull);
      expect(state.allMap['3.41.9']!.release, isNull);
      expect(state.allMap['3.41.9']!.needSetup, isTrue);
      expect(state.allMap['3.41.9']!.isCached, isTrue);
      expect(state.allMap['3.38.7']!.needSetup, isFalse);
      // Neither version was detected as an OHOS checkout
      expect(state.allMap['3.41.9']!.isOhosSdk, isFalse);
      expect(state.allMap['3.38.7']!.isOhosSdk, isFalse);
    });

    test('marks manually cloned top-level OHOS checkouts via git remote', () {
      final state = AppReleasesState();
      state.generateMap();

      // FvmCacheProvider.reloadState detects 3.41.9 as an OHOS checkout
      state.addUntrackedCachedVersions(
        [ohosVersion],
        null,
        topLevelOhosNames: {'3.41.9'},
      );

      expect(state.allMap['3.41.9']!.isOhosSdk, isTrue);
    });

    test('skips versions already covered by official releases list', () {
      final state = AppReleasesState();
      state.generateMap();

      // First pass registers 3.38.7, like the official list would
      state.addUntrackedCachedVersions([officialCached], null);
      // Second pass merges everything again: no duplicates should appear
      state.addUntrackedCachedVersions([officialCached, ohosVersion], null);

      expect(state.all.length, 2);
      expect(state.all.where((v) => v.name == '3.38.7').length, 1);
    });

    test('marks untracked version as global when global version matches', () {
      final state = AppReleasesState();
      state.generateMap();

      state.addUntrackedCachedVersions([ohosVersion], '3.41.9');

      expect(state.allMap['3.41.9']!.isGlobal, isTrue);
    });

    test('does not pollute official releases browse list', () {
      final state = AppReleasesState();
      state.generateMap();

      state.addUntrackedCachedVersions([ohosVersion], null);

      expect(state.versions, isEmpty);
      expect(state.channels, isEmpty);
      expect(state.master, isNull);
    });

    test('synthesizes fork versions with the fork-prefixed name', () {
      // fvm installs forks under versions/<fork>/<ref> and reports them with
      // the bare branch name; the queue re-parses VersionDto.name and needs
      // the 'ohos/' prefix to resolve the fork cache directory.
      const forkedVersion = CacheFlutterVersion(
        'oh-3.41.9-release',
        type: VersionType.unknownRef,
        fork: 'ohos',
        directory: '/fake/versions/ohos/oh-3.41.9-release',
        flutterSdkVersion: '3.41.9+ohos-1.0.2',
        dartSdkVersion: null,
        isSetup: false,
      );

      final state = AppReleasesState();
      state.generateMap();

      state.addUntrackedCachedVersions(
          [forkedVersion], 'ohos/oh-3.41.9-release');

      final dto = state.allMap['ohos/oh-3.41.9-release'];
      expect(dto, isNotNull);
      expect(dto!.name, 'ohos/oh-3.41.9-release');
      expect(dto.isGlobal, isTrue);
      // Fork installs are OHOS SDKs by definition
      expect(dto.isOhosSdk, isTrue);
      // No bare-name alias: FlutterVersion.parse('oh-3.41.9-release')
      // without the prefix would resolve to a non-existent top-level cache.
      expect(state.allMap['oh-3.41.9-release'], isNull);
    });
  });
}
