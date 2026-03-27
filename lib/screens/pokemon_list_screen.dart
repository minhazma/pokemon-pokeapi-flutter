import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pokemon/models/list.dart';
import 'package:pokemon/screens/pokemon_detail_screen.dart';
import 'package:pokemon/ui/route_animations.dart';
import 'package:pokemon/ui/styles.dart';
import 'package:pokemon/utils/string_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokemon/utils/providers.dart';
import 'package:pokemon/utils/constants.dart';
import 'package:pokemon/repo/debouncer.dart';
import 'package:pokemon/api/init.dart';

class PokemonListScreen extends ConsumerStatefulWidget {
  const PokemonListScreen({super.key});

  @override
  ConsumerState<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends ConsumerState<PokemonListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _searchDebouncer = Debouncer();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebouncer.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_query.isEmpty && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 400) {
      ref.read(pokemonPaginatorProvider.notifier).fetchNextPage();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebouncer.debounce(() {
      if (mounted) {
        setState(() => _query = value);
      }
    });
  }

  void _clearSearch() {
    HapticFeedback.lightImpact();
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = _query.isEmpty ? ref.watch(pokemonPaginatorProvider).whenData((p) => p.items) : ref.watch(pokemonListStreamProvider(_query));

    final paginatorState = ref.watch(pokemonPaginatorProvider);

    return Scaffold(
      backgroundColor: ColorPalette.background,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverHeader(context),
            _buildSearchBar(),
            listAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  final sync = ref.watch(syncProgressProvider).value;
                  if (sync?.phase == SyncPhase.fetchingList) {
                    return SliverFillRemaining(child: _SyncProgressView(progress: sync!));
                  }
                  return SliverFillRemaining(child: _EmptyView(query: _query));
                }
                return SliverMainAxisGroup(
                  slivers: [
                    _buildGrid(items),
                    if (_query.isEmpty && paginatorState.asData?.value.hasMore == true)
                      const SliverPadding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        sliver: SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(ColorPalette.primary))),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const SliverFillRemaining(child: _LoadingView()),
              error: (error, _) => SliverFillRemaining(
                child: _ErrorView(
                  onRetry: () {
                    if (_query.isEmpty) {
                      ref.invalidate(pokemonPaginatorProvider);
                    } else {
                      ref.invalidate(pokemonListStreamProvider(_query));
                    }
                  },
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      backgroundColor: ColorPalette.primary,
      elevation: 0,
      scrolledUnderElevation: 2,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 14),
        title: Text(
          AppStrings.pokemonListTitle,
          style: AppTextStyles.heading(color: ColorPalette.textLight, fontWeight: FontWeight.w800),
        ),
        background: DecoratedBox(
          decoration: const BoxDecoration(gradient: ColorPalette.primaryGradient),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 10),
              child: Opacity(opacity: 0.15, child: CachedNetworkImage(imageUrl: ApiConstants.pokeBallImageUrl)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SearchBarDelegate(
        child: Container(
          color: ColorPalette.primary,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: ColorPalette.surfaceLight,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: ColorPalette.primaryDark.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: AppTextStyles.inputText(),
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                hintStyle: AppTextStyles.inputText(color: ColorPalette.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded, color: ColorPalette.textSecondary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), color: ColorPalette.textSecondary, onPressed: _clearSearch, splashRadius: 18) : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<PokemonListItem> items) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.88),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                SlideRightRoute(
                  page: PokemonDetailScreen(id: item.id, name: item.name),
                ),
              );
            },
            child: _PokemonCard(item: item),
          );
        }, childCount: items.length),
      ),
    );
  }
}

class _PokemonCard extends ConsumerStatefulWidget {
  const _PokemonCard({required this.item});

  final PokemonListItem item;

  @override
  ConsumerState<_PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends ConsumerState<_PokemonCard> {
  @override
  void initState() {
    super.initState();

    ref.read(pokemonRepositoryProvider).precacheDetail(widget.item.id);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surfaceLight,
        borderRadius: BorderRadius.circular(WidgetRadius.main + 8),
        boxShadow: [BoxShadow(color: ColorPalette.shadow(), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(WidgetRadius.main + 8),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -15,
              child: Opacity(opacity: 0.05, child: CachedNetworkImage(imageUrl: ApiConstants.pokeBallImageUrl)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorPalette.background.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(WidgetRadius.main + 8)),
                    ),
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    child: _SpriteImage(urls: item.candidateSpriteUrls),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      item.name.formatName,
                      style: AppTextStyles.main(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpriteImage extends StatelessWidget {
  const _SpriteImage({required this.urls, this.index = 0});

  final List<String> urls;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (index >= urls.length) {
      return Center(
        child: CachedNetworkImage(
          imageUrl: ApiConstants.pokeBallImageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.contain,
          errorWidget: (context, url, error) => const Icon(Icons.catching_pokemon, color: ColorPalette.surfaceDark, size: 32),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: urls[index],
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      placeholder: (context, url) => Opacity(
        opacity: 0.1,
        child: Center(child: CachedNetworkImage(imageUrl: ApiConstants.pokeBallImageUrl)),
      ),

      errorWidget: (context, url, error) => _SpriteImage(urls: urls, index: index + 1),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(ColorPalette.primary)));
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: ColorPalette.primary),
            const SizedBox(height: 16),
            Text(AppStrings.somethingWentWrong, style: AppTextStyles.main(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(AppStrings.couldNotLoadPokemon, style: AppTextStyles.sub(), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onRetry();
              },
              style: AppButtonStyles.primaryButton(),
              child: Text(AppStrings.retryButtonText, style: AppTextStyles.buttonText()),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_rounded, size: 48, color: ColorPalette.surfaceDark),
            const SizedBox(height: 16),
            Text(
              query.isEmpty ? AppStrings.noPokemonFound : '${AppStrings.noResultsFor} "$query"',
              style: AppTextStyles.main(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(AppStrings.tryDifferentName, style: AppTextStyles.sub(), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SyncProgressView extends StatelessWidget {
  const _SyncProgressView({required this.progress});

  final SyncProgress progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(ColorPalette.primary)),
            const SizedBox(height: 24),
            Text('Initializing Pokémon Data...', style: AppTextStyles.main(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Fetched ${progress.listLoaded} of ${progress.listTotal} names', style: AppTextStyles.sub()),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(value: progress.listFraction, backgroundColor: ColorPalette.background, valueColor: const AlwaysStoppedAnimation(ColorPalette.primary), borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  const _SearchBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) => true;
}
