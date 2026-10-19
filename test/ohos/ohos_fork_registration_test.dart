import 'dart:io';

import 'package:fvm/fvm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidekick/src/modules/ohos/ohos.constants.dart';
import 'package:sidekick/src/modules/ohos/ohos.service.dart';

Directory _fakeSdkCheckout(Directory parent, String name, String remoteUrl) {
  final dir = Directory('${parent.path}/$name')..createSync(recursive: true);
  Directory('${dir.path}/.git').createSync();
  File('${dir.path}/.git/config').writeAsStringSync('''
[core]
	repositoryformatversion = 0
[remote "origin"]
	url = $remoteUrl
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
	remote = origin
''');
  return dir;
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ohos_fork_test');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('ensureOhosForkRegistered', () {
    test('creates config with the OHOS fork on first run', () async {
      final configPath = '${tempDir.path}/.fvmrc';

      await ensureOhosForkRegistered(appConfigPath: configPath);

      final config = LocalAppConfig.read(path: configPath);
      final fork =
          config.forks.firstWhereOrNull((f) => f.name == kOhosForkName);
      expect(fork, isNotNull);
      expect(fork!.url, kOhosRepoUrl);
    });

    test('does not overwrite an existing fork with the same alias', () async {
      final configPath = '${tempDir.path}/.fvmrc';
      final customUrl = 'https://example.com/custom-flutter.git';
      LocalAppConfig(
        forks: {FlutterFork(name: kOhosForkName, url: customUrl)},
      ).save(path: configPath);

      await ensureOhosForkRegistered(appConfigPath: configPath);

      final fork = LocalAppConfig.read(path: configPath)
          .forks
          .firstWhereOrNull((f) => f.name == kOhosForkName);
      expect(fork!.url, customUrl);
    });

    test('preserves other forks already present', () async {
      final configPath = '${tempDir.path}/.fvmrc';
      LocalAppConfig(
        forks: {FlutterFork(name: 'mycompany', url: 'https://example.com/x')},
      ).save(path: configPath);

      await ensureOhosForkRegistered(appConfigPath: configPath);

      final forks = LocalAppConfig.read(path: configPath).forks;
      expect(
        forks.any((f) => f.name == 'mycompany'),
        isTrue,
      );
      expect(forks.any((f) => f.name == kOhosForkName), isTrue);
    });

    test('is idempotent on repeated calls', () async {
      final configPath = '${tempDir.path}/.fvmrc';

      await ensureOhosForkRegistered(appConfigPath: configPath);
      await ensureOhosForkRegistered(appConfigPath: configPath);

      final forks = LocalAppConfig.read(path: configPath).forks;
      expect(
        forks.where((f) => f.name == kOhosForkName).length,
        1,
      );
    });

    test('swallows failures when the config path is not writable', () async {
      // Path under a regular file: parent directory creation must fail
      final blocker = File('${tempDir.path}/blocker')..writeAsStringSync('');

      await ensureOhosForkRegistered(
        appConfigPath: '${blocker.path}/nested/.fvmrc',
      );

      expect(blocker.existsSync(), isTrue);
    });
  });

  group('isOhosGitCheckout', () {
    test('detects a checkout cloned from the CPF-Flutter repository', () {
      final sdk = _fakeSdkCheckout(
        tempDir,
        'ohos-sdk',
        'https://gitcode.com/CPF-Flutter/flutter_flutter.git',
      );

      expect(isOhosGitCheckout(sdk.path), isTrue);
    });

    test('rejects official Flutter checkouts', () {
      final sdk = _fakeSdkCheckout(
        tempDir,
        'official-sdk',
        'https://github.com/flutter/flutter.git',
      );

      expect(isOhosGitCheckout(sdk.path), isFalse);
    });

    test('returns false without a .git/config', () {
      final dir = Directory('${tempDir.path}/no-git')..createSync();

      expect(isOhosGitCheckout(dir.path), isFalse);
    });
  });

  group('isOhosCachedVersion', () {
    CacheFlutterVersion cached({
      String name = '3.41.9',
      String? fork,
      String directory = '/fake/versions/3.41.9',
    }) {
      return CacheFlutterVersion(
        name,
        type: VersionType.release,
        fork: fork,
        directory: directory,
        flutterSdkVersion: '3.41.9',
        dartSdkVersion: null,
        isSetup: true,
      );
    }

    test('returns false without a cache entry', () {
      expect(isOhosCachedVersion(null, const {}), isFalse);
    });

    test('detects fork-layout installs via the fork field', () {
      expect(
        isOhosCachedVersion(cached(fork: kOhosForkName), const {}),
        isTrue,
      );
    });

    test('detects top-level checkouts via the detected name set', () {
      expect(
        isOhosCachedVersion(cached(), const {'3.41.9'}),
        isTrue,
      );
    });

    test('rejects plain official installs', () {
      expect(isOhosCachedVersion(cached(), const {}), isFalse);
      expect(isOhosCachedVersion(cached(name: '3.38.7'), const {'3.41.9'}),
          isFalse);
    });
  });

  group('ohosReleasePageUrl', () {
    CacheFlutterVersion cached(String? sdkVersion) {
      return CacheFlutterVersion(
        'oh-3.41.9-release',
        type: VersionType.unknownRef,
        fork: kOhosForkName,
        directory: '/fake/versions/ohos/oh-3.41.9-release',
        flutterSdkVersion: sdkVersion,
        dartSdkVersion: null,
        isSetup: true,
      );
    }

    test('points at the release page of the reported fork tag', () {
      // The tag comes from the SDK's own flutter.version.json, and the web
      // URL must not carry the git-only `.git` suffix (it returns 403)
      expect(
        ohosReleasePageUrl(cached('3.41.9+ohos-1.0.2')),
        '$kOhosRepoWebUrl/releases/3.41.9+ohos-1.0.2',
      );
      expect(
        ohosReleasePageUrl(cached('3.41.9+ohos-1.0.2')),
        isNot(contains('.git')),
      );
    });

    test('falls back to the tag list without SDK metadata', () {
      expect(ohosReleasePageUrl(cached(null)), '$kOhosRepoWebUrl/tags');
      expect(ohosReleasePageUrl(cached('')), '$kOhosRepoWebUrl/tags');
      expect(ohosReleasePageUrl(null), '$kOhosRepoWebUrl/tags');
    });
  });

  group('ohosDisplayName', () {
    test('strips the release/dev suffix from branch names', () {
      expect(ohosDisplayName('oh-3.41.9-release'), 'oh-3.41.9');
      expect(ohosDisplayName('oh-3.41.9-dev'), 'oh-3.41.9');
      // Fork-qualified names pass through the same shortening
      expect(ohosDisplayName('ohos/oh-3.41.9-release'), 'oh-3.41.9');
    });

    test('keeps the extra segment of dev variants', () {
      expect(ohosDisplayName('oh-3.7.12-dev-6.0'), 'oh-3.7.12-6.0');
    });

    test('returns non-OHOS names unchanged', () {
      expect(ohosDisplayName('3.38.7'), '3.38.7');
      expect(ohosDisplayName('stable'), 'stable');
    });
  });

  group('promoteOhosInstallToTopLevel', () {
    Directory makeForkInstall(String branch) {
      final forkDir = Directory('${tempDir.path}/versions/ohos')
        ..createSync(recursive: true);
      final install = Directory('${forkDir.path}/$branch')
        ..createSync(recursive: true);
      File('${install.path}/bin').createSync();
      return install;
    }

    test('moves the checkout to versions/<branch> and cleans the fork dir',
        () async {
      final install = makeForkInstall('oh-3.41.9-release');

      final newPath = await promoteOhosInstallToTopLevel(install.path);

      expect(newPath, '${tempDir.path}/versions/oh-3.41.9-release');
      expect(Directory(newPath).existsSync(), isTrue);
      expect(install.existsSync(), isFalse);
      // Empty fork directory is cleaned up
      expect(Directory('${tempDir.path}/versions/ohos').existsSync(), isFalse);
    });

    test('throws when the top-level name is already taken', () async {
      final install = makeForkInstall('oh-3.35.7-release');
      Directory('${tempDir.path}/versions/oh-3.35.7-release')
          .createSync(recursive: true);

      await expectLater(
        promoteOhosInstallToTopLevel(install.path),
        throwsException,
      );
      // The fork install is left untouched
      expect(install.existsSync(), isTrue);
    });

    test('is a no-op for a checkout already at the top level', () async {
      final top = Directory('${tempDir.path}/versions/oh-3.32.0-release')
        ..createSync(recursive: true);

      final result = await promoteOhosInstallToTopLevel(top.path);

      expect(result, top.path);
      expect(top.existsSync(), isTrue);
    });

    test('throws when the source does not exist', () async {
      await expectLater(
        promoteOhosInstallToTopLevel('${tempDir.path}/versions/ohos/gone'),
        throwsException,
      );
    });
  });
}
