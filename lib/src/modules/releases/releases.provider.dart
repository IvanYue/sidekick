// ignore_for_file: top_level_function_literal_block
import "package:system_info2/system_info2.dart";

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:fvm/fvm.dart';

import '../../modules/common/dto/channel.dto.dart';
import '../../modules/common/dto/master.dto.dart';
import '../../modules/common/dto/release.dto.dart';
import '../../modules/common/dto/version.dto.dart';
import '../common/constants.dart';
import '../fvm/fvm.provider.dart';
import '../ohos/ohos.service.dart';
import 'releases.service.dart';

class AppReleasesState {
  /// 远端发行版列表是否还在加载
  bool fetching;

  /// 远端发行版列表是否不可用（网络失败且磁盘上也没有上一次成功的结果）。
  ///
  /// 渠道卡、master 卡与已安装版本列表只依赖本地缓存，这种情况下照常渲染；
  /// 只有「版本库」列表为空，页面据此换一句更准确的空态说明。
  bool remoteUnavailable = false;

  MasterDto? _master;
  final List<ChannelDto> _channels = [];
  final List<VersionDto> _versions = [];

  Map<String, ReleaseDto> _allMap = {};

  bool hasGlobal;

  List<ReleaseDto> _allCached = [];

  final arch = SysInfo.kernelArchitecture;

  AppReleasesState({
    this.fetching = true,
    this.hasGlobal = false,
  });

  /// Returns all releases and channels
  Map<String, ReleaseDto> get allMap {
    return _allMap;
  }

  /// Returns all releases and channels that are cached
  List<ReleaseDto> get all {
    // Only get unique cached releases
    // Some releases replicate across channels
    // They can only be installed once and conflict
    return _allCached;
  }

  void generateMap() {
    final releases = [..._channels, ..._versions];
    if (_master != null) {
      // Master goes first
      releases.insert(0, _master!);
    }
    _allMap = {for (var release in releases) release.name: release};

    /// Returns all releases and channels that are cached
    _allCached = allMap.entries
        .where((entry) => entry.value.isCached)
        .map((entry) => entry.value)
        .toList();
  }

  List<VersionDto> get versions {
    return _versions;
  }

  List<ChannelDto> get channels {
    return _channels;
  }

  MasterDto? get master {
    return _master;
  }

  void addChannel(ChannelDto channel) {
    _channels.add(channel);
  }

  /// Whether [archive] is built for the host architecture
  bool _isNativeArchive(String archive) {
    final isArm = arch == ProcessorArchitecture.arm64;
    return archive.contains('arm64') == isArm;
  }

  void addVersion(VersionDto version) {
    // The same version can be published for several architectures,
    // keep a single entry and prefer the one built for the host.
    final index = _versions.indexWhere((e) => e.name == version.name);
    if (index == -1) {
      _versions.add(version);
      return;
    }

    final existing = _versions[index].release;
    final candidate = version.release;

    if (existing != null &&
        candidate != null &&
        !_isNativeArchive(existing.archive) &&
        _isNativeArchive(candidate.archive)) {
      _versions[index] = version;
    }
  }

  void addMaster(MasterDto master) {
    _master = master;
  }

  /// Merges locally cached versions that are not part of the official
  /// releases list (e.g. third-party forks like OHOS).
  ///
  /// These versions have no [FlutterSdkRelease] metadata, so a VersionDto is
  /// synthesized with a null release. They are only added to the installed
  /// versions list (allMap/all), not to the official releases browse list
  /// (versions), since they cannot be installed from the official archives.
  void addUntrackedCachedVersions(
    List<CacheFlutterVersion> cachedVersions,
    String? globalVersion, {
    Set<String> topLevelOhosNames = const {},
  }) {
    for (final cached in cachedVersions) {
      // Use the alias-qualified name ('fork/version'): the queue re-parses it
      // with FlutterVersion.parse and relies on the fork prefix to resolve
      // the cache directory. CacheFlutterVersion.name drops the prefix.
      final name = cached.nameWithAlias;

      // Already covered by the official releases list
      if (_allMap[name] != null) continue;

      final version = VersionDto(
        name: name,
        release: null,
        cache: cached,
        needSetup: cached.isSetup != true,
        isGlobal: globalVersion == name,
        // Fork installs carry the alias; manually cloned top-level checkouts
        // are detected via their git remote (FvmCacheProvider.reloadState).
        isOhosSdk: isOhosCachedVersion(cached, topLevelOhosNames),
      );

      _allMap[name] = version;
      _allCached.add(version);
    }
  }
}

/// 远端发行版列表。
///
/// 永不抛错：网络不可用时返回 null（可能来自磁盘缓存，也可能彻底没有），
/// 由 [releasesStateProvider] 决定如何降级。抛错会让整个 provider 进入 error
/// 状态，渠道卡与已安装版本会跟着一起消失，而这部分数据本来就只依赖本地缓存。
///
/// 页面刷新按钮 invalidate 它来强制重取，绕过 FVM client 的内部缓存。
final flutterReleasesProvider = FutureProvider<FlutterReleasesResponse?>(
  (_) => loadFlutterReleases(),
);

final releasesStateProvider = Provider<AppReleasesState>((ref) {
  // Watch this state change for refresh
  ref.watch(fvmCacheProvider);
  final installedVersions = ref.read(fvmCacheProvider.notifier);

  // 远端数据：未就绪 / 失败都不阻塞本地数据的渲染
  var loadingRemote = true;
  FlutterReleasesResponse? payload;
  ref.watch(flutterReleasesProvider).when(
        data: (value) {
          payload = value;
          loadingRemote = false;
        },
        error: (_, __) => loadingRemote = false,
        loading: () {},
      );

  //Creates empty releases state
  final releasesState = AppReleasesState();
  releasesState.fetching = loadingRemote;
  releasesState.remoteUnavailable = !loadingRemote && payload == null;

  final flutterReleases = payload?.versions ?? const <FlutterSdkRelease>[];
  final flutterChannels = payload?.channels;

  final globalVersion = fvmContext.get<CacheService>().getGlobalVersion();
  releasesState.hasGlobal = globalVersion != null;

  // OHOS checkouts live in the cache, not in the official payload, so the
  // flag has to be computed here and applied to every DTO below.
  final topLevelOhosNames = installedVersions.topLevelOhosNames;

  //  MASTER: Set Master separetely because workflow is very different
  final masterCache = installedVersions.getChannel(kMasterChannel);
  final masterVersion = masterCache?.flutterSdkVersion;

  releasesState.addMaster(MasterDto(
    name: kMasterChannel,
    cache: masterCache,
    needSetup: masterCache?.isSetup != true,
    sdkVersion: masterVersion ?? '0.0.0',
    isGlobal: globalVersion == kMasterChannel,
    isOhosSdk: isOhosCachedVersion(masterCache, topLevelOhosNames),
  ));

  // CHANNELS: Loop through available channels NOT including master
  for (var name in kReleaseChannels) {
    final latestRelease = flutterChannels?[name];
    final channelCache = installedVersions.getChannel(name);

    // Get sdk version
    final sdkVersion = channelCache?.flutterSdkVersion;
    final currentRelease = sdkVersion != null && payload != null
        ? payload!.fromVersion(sdkVersion)
        : null;

    final channelDto = ChannelDto(
      name: name,
      cache: channelCache,
      needSetup: channelCache?.isSetup != true,
      sdkVersion: sdkVersion,
      // Get version for the channel
      currentRelease: currentRelease,
      release: latestRelease,
      isGlobal: globalVersion == name,
      isOhosSdk: isOhosCachedVersion(channelCache, topLevelOhosNames),
    );

    releasesState.addChannel(channelDto);
  }

  // VERSIONS loop to create versions（只有远端数据可用时才有内容可列）
  for (final item in flutterReleases) {
    // Check if version is found in installed versions
    final cacheVersion = installedVersions.getVersion(item.version);
    final version = VersionDto(
      name: item.version,
      release: item,
      cache: cacheVersion,
      needSetup: cacheVersion?.isSetup != true,
      isGlobal: globalVersion == item.version,
      // A published version number can still be an OHOS checkout when the
      // user cloned the fork manually (e.g. `3.41.9`)
      isOhosSdk: isOhosCachedVersion(cacheVersion, topLevelOhosNames),
    );

    releasesState.addVersion(version);
  }

  // 版本选择器的选项：已安装的版本永远可选，不受远端可用性影响
  releasesState.generateMap();

  // Merge locally cached versions that are not in the official releases list
  // (e.g. third-party forks like OHOS), so they show up as installed versions
  releasesState.addUntrackedCachedVersions(
    installedVersions.versions,
    globalVersion,
    topLevelOhosNames: topLevelOhosNames,
  );

  return releasesState;
});

final getVersionProvider = Provider.family<ReleaseDto?, String?>(
  (ref, versionName) {
    final state = ref.read(releasesStateProvider);
    return state.allMap[versionName];
  },
);

enum Filter {
  beta,
  stable,
  all,
}

extension FilterExtension on Filter {
  /// Name of the channel
  String get name {
    final self = this;
    return self.toString().split('.').last;
  }
}

/// Returns a [Channel] from [name]
Filter filterFromName(String name) {
  switch (name) {
    case 'stable':
      return Filter.stable;
    case 'beta':
      return Filter.beta;
    case 'all':
      return Filter.all;
    default:
      throw Exception('Unknown filter $name');
  }
}

final filterProvider = StateProvider<Filter>((_) => Filter.all);

final filterableReleasesProvider = Provider((ref) {
  final filter = ref.watch(filterProvider);
  final releases = ref.watch(releasesStateProvider);

  if (filter == Filter.all) {
    return releases.versions;
  }

  final versions = releases.versions.where((version) {
    if (version.isChannel && version.name == filter.name) {
      return true;
    }

    if (!version.isChannel && version.release?.channelName == filter.name) {
      return true;
    }

    return false;
  });

  return versions.toList();
});
