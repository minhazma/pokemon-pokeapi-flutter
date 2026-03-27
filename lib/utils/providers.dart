import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokemon/api/api.dart';
import 'package:pokemon/api/init.dart';
import 'package:pokemon/cache/app_database.dart';
import 'package:pokemon/models/list.dart';
import 'package:pokemon/repo/pokemon_repository.dart';
import 'package:pokemon/utils/connectivity_service.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Provider for the [AppDatabase].
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Provider for the [PokemonApiService].
final apiServiceProvider = Provider<PokemonApiService>((ref) {
  final api = PokemonApiService();
  ref.onDispose(() => api.dispose());
  return api;
});

/// Provider for the [PokemonRepository].
final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final api = ref.watch(apiServiceProvider);
  return PokemonRepository(db: db, api: api);
});

/// StreamProvider for monitoring internet connectivity status.
final connectivityStatusProvider = StreamProvider<InternetStatus>((ref) {
  return ConnectivityService.instance.onStatusChange;
});

/// Provider for the [AppInitializer].
final appInitializerProvider = Provider<AppInitializer>((ref) {
  final db = ref.watch(databaseProvider);
  final api = ref.watch(apiServiceProvider);
  final init = AppInitializer(api: api, db: db, detailSyncTarget: 0, syncDetails: false);
  ref.onDispose(() => init.cancel());
  return init;
});

/// Provider for watching the sync progress.
final syncProgressProvider = StreamProvider<SyncProgress>((ref) {
  final init = ref.watch(appInitializerProvider);
  final controller = StreamController<SyncProgress>();
  void listener() => controller.add(init.progress.value);
  init.progress.addListener(listener);
  controller.add(init.progress.value);
  ref.onDispose(() {
    init.progress.removeListener(listener);
    controller.close();
  });
  return controller.stream;
});

/// StreamProvider for the Pokemon list, filtered by name.
final pokemonListStreamProvider = StreamProvider.family<List<PokemonListItem>, String>((ref, query) {
  final repo = ref.watch(pokemonRepositoryProvider);
  return repo.watchPokemonList(query: query);
});

/// Provider for paginated Pokemon list.
final pokemonPaginatorProvider = AsyncNotifierProvider<PokemonPaginatorNotifier, PaginatedPokemon>(() {
  return PokemonPaginatorNotifier();
});

class PokemonPaginatorNotifier extends AsyncNotifier<PaginatedPokemon> {
  @override
  FutureOr<PaginatedPokemon> build() {
    ref.listen(syncProgressProvider, (previous, next) {
      final prevPhase = previous?.value?.phase;
      final nextPhase = next.value?.phase;

      if (prevPhase == SyncPhase.fetchingList && nextPhase != SyncPhase.fetchingList) {
        ref.invalidateSelf();
      }
    });

    return _fetchPage(0);
  }

  Future<PaginatedPokemon> _fetchPage(int offset) async {
    final repo = ref.read(pokemonRepositoryProvider);
    return repo.getPaginatedPokemon(offset: offset);
  }

  Future<void> fetchNextPage() async {
    final currentState = state.asData?.value;
    if (currentState == null || !currentState.hasMore || state.isLoading) return;

    state = await AsyncValue.guard(() async {
      final nextPage = await _fetchPage(currentState.nextOffset);
      return currentState.copyWith(items: [...currentState.items, ...nextPage.items], nextOffset: nextPage.nextOffset, hasMore: nextPage.hasMore, totalCount: nextPage.totalCount);
    });
  }
}
