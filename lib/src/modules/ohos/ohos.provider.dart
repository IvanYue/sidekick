import 'package:fvm/fvm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../fvm/fvm.provider.dart';
import 'ohos.constants.dart';
import 'ohos.dto.dart';
import 'ohos.service.dart';

/// Remote OHOS branches (network layer).
///
/// Only this provider hits the network; refresh by invalidating it.
final ohosRemoteBranchesProvider =
    FutureProvider<List<OhosBranchDto>>((ref) => fetchOhosBranches());

/// Remote branches merged with local installation state.
///
/// Watches `fvmCacheProvider`, so installs/removals/updates recompute this
/// without re-fetching the remote list. Both install layouts are matched:
/// fork installs (`ohos/<branch>`) and top-level checkouts detected via their
/// git remote in `FvmCacheProvider.topLevelOhosNames`.
final ohosBranchesProvider = FutureProvider<List<OhosBranchItem>>((ref) async {
  ref.watch(fvmCacheProvider);

  final remote = await ref.watch(ohosRemoteBranchesProvider.future);
  final topLevelOhosNames =
      ref.read(fvmCacheProvider.notifier).topLevelOhosNames;
  final cached = ref
      .watch(fvmCacheProvider)
      .where((v) =>
          v.fork == kOhosForkName || topLevelOhosNames.contains(v.name))
      .toList();
  final globalVersion = fvmContext.get<CacheService>().getGlobalVersion();

  return mergeOhosBranches(remote, cached, getLocalHeadSha, globalVersion);
});

/// Filter for the OHOS branch list.
enum OhosFilter { all, release, dev }

/// Filter state for the OHOS screen.
final ohosFilterProvider = StateProvider<OhosFilter>((_) => OhosFilter.all);

/// OHOS branches matching the active filter.
///
/// Orphaned installs (remote branch deleted) only show under `all`.
final ohosFilterableProvider = Provider((ref) {
  final filter = ref.watch(ohosFilterProvider);
  final items = ref.watch(ohosBranchesProvider).value ?? [];

  if (filter == OhosFilter.all) return items;

  return items
      .where((item) => item.branch?.type.name == filter.name)
      .toList();
});
