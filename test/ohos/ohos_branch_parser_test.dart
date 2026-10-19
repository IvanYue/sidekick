import 'package:flutter_test/flutter_test.dart';
import 'package:sidekick/src/modules/ohos/ohos.constants.dart';
import 'package:sidekick/src/modules/ohos/ohos.dto.dart';
import 'package:sidekick/src/modules/ohos/ohos.service.dart';

void main() {
  group('parseOhosLsRemote', () {
    test('parses release and dev branches with sha', () {
      const output = ''
          '04d2008b35eae67162f0f11d2fd8e2453092c891\trefs/heads/oh-3.35.7-release\n'
          'e0b83362e7a1eebd72eddecf6f9e0180a16f7465\trefs/heads/oh-3.41.9-dev\n'
          '62357a93d653bf844f730bb1f4b7cc9e2139d14e\trefs/heads/oh-3.41.9-release\n';

      final branches = parseOhosLsRemote(output);

      expect(branches.length, 3);
      final release =
          branches.firstWhere((b) => b.name == 'oh-3.41.9-release');
      expect(release.type, OhosBranchType.release);
      expect(release.version, '3.41.9');
      expect(release.sha, '62357a93d653bf844f730bb1f4b7cc9e2139d14e');
      expect(release.extra, isNull);

      final dev = branches.firstWhere((b) => b.name == 'oh-3.41.9-dev');
      expect(dev.type, OhosBranchType.dev);
      expect(dev.qualifiedName, 'ohos/oh-3.41.9-dev');
    });

    test('parses dev branch variants with extra segment', () {
      const output =
          '53031a9bd2c8d53f0c627061b047125fa87d0f2a\trefs/heads/oh-3.7.12-dev-6.0\n';

      final branches = parseOhosLsRemote(output);

      expect(branches.single.name, 'oh-3.7.12-dev-6.0');
      expect(branches.single.type, OhosBranchType.dev);
      expect(branches.single.version, '3.7.12');
      expect(branches.single.extra, '6.0');
    });

    test('skips non-OHOS refs and malformed lines', () {
      const output = ''
          '39eec52debb5abcc0dcf3c611a8e890dbff9372e\trefs/heads/master\n'
          'gsy-sha-not-a-tab-line\n'
          '77b901bb2a192820a242bd0f2ad4503a16bd2868\trefs/heads/oh-3.22.0-dev-6.0\n'
          '\n'
          'f26081dd693678cc8599292f4a5f1c6d70e6ba91\trefs/heads/oh-3.22.0-dev\n';

      final branches = parseOhosLsRemote(output);

      expect(
        branches.map((b) => b.name).toList(),
        isNot(contains('master')),
      );
      expect(branches.length, 2);
    });

    test('sorts newest version first, release before dev', () {
      const output = ''
          'a\trefs/heads/oh-3.7.12-release\n'
          'b\trefs/heads/oh-3.41.9-dev\n'
          'c\trefs/heads/oh-3.41.9-release\n'
          'd\trefs/heads/oh-3.35.7-release\n';

      final branches = parseOhosLsRemote(output);

      expect(branches.map((b) => b.name).toList(), [
        'oh-3.41.9-release',
        'oh-3.41.9-dev',
        'oh-3.35.7-release',
        'oh-3.7.12-release',
      ]);
    });

    test('handles empty output', () {
      expect(parseOhosLsRemote(''), isEmpty);
      expect(parseOhosLsRemote('\n\n'), isEmpty);
    });

    test('branch pattern matches known CPF branch names only', () {
      const known = [
        'oh-3.41.9-release',
        'oh-3.41.9-dev',
        'oh-3.44.9-dev',
        'oh-3.35.7-dev',
        'oh-3.22.0-dev',
        'oh-3.22.3-dev',
        'oh-3.27.0-release',
        'oh-3.32.0-release',
        'oh-3.7.12-dev-6.0',
        'oh-3.7.12-dev',
      ];
      for (final name in known) {
        expect(ohosBranchPattern.hasMatch(name), isTrue, reason: name);
      }

      const rejected = [
        'master',
        'stable',
        'oh-3.41.9-beta',
        '3.22.0-ohos',
        'br_3.22.0-ohos-1.0.4',
        'revert-merge-57-master',
      ];
      for (final name in rejected) {
        expect(ohosBranchPattern.hasMatch(name), isFalse, reason: name);
      }
    });
  });
}
