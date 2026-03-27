import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pokemon/models/detail.dart';
import 'package:pokemon/ui/styles.dart';
import 'package:pokemon/utils/audio_cache_manager.dart';
import 'package:pokemon/utils/string_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokemon/utils/providers.dart';
import 'package:pokemon/utils/constants.dart';

class PokemonDetailScreen extends ConsumerStatefulWidget {
  const PokemonDetailScreen({super.key, required this.id, required this.name});

  final int id;
  final String name;

  @override
  ConsumerState<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends ConsumerState<PokemonDetailScreen> {
  PokemonDetail? _detail;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isRefreshing = false;

  final AudioPlayer _player = AudioPlayer();
  String? _playingCry;
  String? _selectedSpriteUrl;
  final Set<String> _brokenSprites = {};

  @override
  void initState() {
    super.initState();
    _load();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingCry = null);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final detail = await ref.read(pokemonRepositoryProvider).getPokemonDetail(widget.id);
      if (mounted) {
        setState(() {
          _detail = detail;
          _isLoading = false;
        });
        _preCacheAssets(detail);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
      _selectedSpriteUrl = null;
    });
    try {
      final detail = await ref.read(pokemonRepositoryProvider).refreshPokemonDetail(widget.id);
      if (mounted) {
        setState(() {
          _detail = detail;
          _isRefreshing = false;
        });
        _preCacheAssets(detail);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isRefreshing = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppStrings.fetchFailedRefreshMessage)));
      }
    }
  }

  Future<void> _playCry(String type, String url) async {
    if (_playingCry == type) {
      await _player.stop();
      setState(() => _playingCry = null);
      return;
    }

    await _player.stop();

    final localPath = await AudioCacheManager().getAudioPath(widget.id, url, type);

    if (localPath != null && await File(localPath).exists()) {
      await _player.play(DeviceFileSource(localPath));
    } else {
      await _player.play(UrlSource(url));
    }

    if (mounted) setState(() => _playingCry = type);
  }

  Future<void> _preCacheAssets(PokemonDetail detail) async {
    if (detail.cries != null) {
      if (detail.cries!.latest != null) {
        AudioCacheManager().preCache(detail.id, detail.cries!.latest!, 'latest');
      }
      if (detail.cries!.legacy != null) {
        AudioCacheManager().preCache(detail.id, detail.cries!.legacy!, 'legacy');
      }
    }

    final spriteUrls = <String>[];
    final s = detail.sprites;

    void addIfNotNull(String? url) {
      if (url != null) spriteUrls.add(url);
    }

    addIfNotNull(s.frontDefault);
    addIfNotNull(s.backDefault);
    addIfNotNull(s.frontShiny);
    addIfNotNull(s.backShiny);
    addIfNotNull(s.officialArtwork?.frontDefault);
    addIfNotNull(s.home?.frontDefault);
    addIfNotNull(s.dreamWorld?.frontDefault);
    addIfNotNull(s.showdown?.frontDefault);

    for (final url in spriteUrls) {
      DefaultCacheManager()
          .downloadFile(url)
          .then(
            (_) {},
            onError: (e) {
              debugPrint('Error pre-caching sprite: $e');
              if (mounted) setState(() => _brokenSprites.add(url));
            },
          );

      if (mounted) {
        precacheImage(CachedNetworkImageProvider(url), context).catchError((e) {
          debugPrint('Error pre-caching image: $e');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: ColorPalette.background,
        appBar: AppBar(backgroundColor: ColorPalette.primary, foregroundColor: ColorPalette.white, elevation: 0),
        body: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(ColorPalette.primary))),
      );
    }

    if (_hasError || _detail == null) {
      return Scaffold(
        backgroundColor: ColorPalette.background,
        appBar: AppBar(backgroundColor: ColorPalette.primary, foregroundColor: ColorPalette.white, elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: ColorPalette.primary),
                const SizedBox(height: 16),
                Text(AppStrings.failedToLoadPokemon, style: AppTextStyles.main(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(AppStrings.checkConnectionMessage, style: AppTextStyles.sub(), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _isLoading = true;
                      _hasError = false;
                    });
                    _load();
                  },
                  style: AppButtonStyles.primaryButton(),
                  child: Text(AppStrings.retryButtonText, style: AppTextStyles.buttonText()),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final detail = _detail!;
    final primaryTypeColor = ColorPalette.typeColor(detail.primaryType);
    final darkerColor = _darken(primaryTypeColor, 0.18);

    return Scaffold(
      backgroundColor: ColorPalette.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(detail, primaryTypeColor, darkerColor),
          SliverToBoxAdapter(child: _buildBody(detail, primaryTypeColor)),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildAppBar(PokemonDetail detail, Color typeColor, Color darkerColor) {
    final imageUrl = _selectedSpriteUrl ?? detail.sprites.officialArtwork?.frontDefault ?? detail.sprites.home?.frontDefault ?? detail.sprites.frontDefault;
    final topPadding = MediaQuery.paddingOf(context).top;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _PokemonHeaderDelegate(
        detail: detail,
        typeColor: typeColor,
        darkerColor: darkerColor,
        imageUrl: imageUrl,
        isRefreshing: _isRefreshing,
        onRefresh: () {
          HapticFeedback.mediumImpact();
          _refresh();
        },
        topPadding: topPadding,
      ),
    );
  }

  Widget _buildBody(PokemonDetail detail, Color typeColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TypeChipsRow(types: detail.types),
          const SizedBox(height: 16),
          _PhysicalInfoRow(detail: detail),
          if (detail.cries != null && (detail.cries!.latest != null || detail.cries!.legacy != null)) ...[const SizedBox(height: 16), _SoundSection(pokemon: detail.name, cries: detail.cries!, playingCry: _playingCry, onPlay: _playCry)],
          const SizedBox(height: 20),
          _SpriteGallery(
            sprites: detail.sprites,
            typeColor: typeColor,
            selectedUrl: _selectedSpriteUrl,
            brokenSprites: _brokenSprites,
            onSelect: (url) {
              HapticFeedback.selectionClick();
              setState(() => _selectedSpriteUrl = url);
            },
            onBroken: (url) => setState(() => _brokenSprites.add(url)),
          ),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Base Stats', accentColor: typeColor),
          const SizedBox(height: 12),
          _StatsBars(stats: detail.stats, typeColor: typeColor),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Abilities', accentColor: typeColor),
          const SizedBox(height: 12),
          _AbilitiesSection(abilities: detail.abilities),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Generations & Appearances', accentColor: typeColor),
          const SizedBox(height: 12),
          _GenerationsSection(detail: detail),
          if (detail.moves.isNotEmpty) ...[const SizedBox(height: 24), _SectionHeader(title: 'Moves', accentColor: typeColor), const SizedBox(height: 12), _MovesSection(moves: detail.moves)],
        ],
      ),
    );
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

class _PokemonHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PokemonHeaderDelegate({required this.detail, required this.typeColor, required this.darkerColor, required this.imageUrl, required this.isRefreshing, required this.onRefresh, required this.topPadding});

  final PokemonDetail detail;
  final Color typeColor;
  final Color darkerColor;
  final String? imageUrl;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final double topPadding;

  static const double _expandedHeight = 300.0;

  @override
  double get minExtent => topPadding + kToolbarHeight;

  @override
  double get maxExtent => topPadding + _expandedHeight;

  @override
  bool shouldRebuild(_PokemonHeaderDelegate old) => old.imageUrl != imageUrl || old.isRefreshing != isRefreshing || old.typeColor != typeColor || old.darkerColor != darkerColor;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final largeFade = (1.0 - t * 1.5).clamp(0.0, 1.0);

    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(child: Container(color: typeColor)),
          Positioned(
            right: -20,
            top: topPadding - 20,
            child: Opacity(
              opacity: 0.2,
              child: CachedNetworkImage(
                imageUrl: ApiConstants.pokeBallImageUrl,
                width: 200,
                height: 200,
                color: ColorPalette.white,
                errorWidget: (ctx, url, err) => const Icon(Icons.catching_pokemon, size: 200, color: ColorPalette.white),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: largeFade,
              child: Align(
                alignment: const Alignment(0.4, 1.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(scale: Tween(begin: 0.88, end: 1.0).animate(anim), child: child),
                    ),
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            key: ValueKey(imageUrl),
                            imageUrl: imageUrl!,
                            height: 240,
                            width: 240,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorWidget: (ctx, url, err) => Icon(Icons.catching_pokemon, size: 120, color: ColorPalette.white.withValues(alpha: 0.3)),
                          )
                        : Icon(key: const ValueKey('placeholder'), Icons.catching_pokemon, size: 120, color: ColorPalette.white.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            height: kToolbarHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ColorPalette.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Opacity(
                    opacity: t,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (imageUrl != null)
                          ClipRect(
                            child: Align(
                              widthFactor: t,
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: CachedNetworkImage(imageUrl: imageUrl!, height: 32, width: 32, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorWidget: (ctx, url, err) => const SizedBox.shrink()),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${detail.id.toString().padLeft(3, '0')}',
                                style: const TextStyle(fontSize: 11, color: ColorPalette.white70, fontWeight: FontWeight.w500, height: 1),
                              ),
                              Text(
                                detail.name.formatName,
                                style: const TextStyle(fontSize: 20, color: ColorPalette.white, fontWeight: FontWeight.w800, height: 1.2),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isRefreshing)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(ColorPalette.white))),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: ColorPalette.white),
                    tooltip: AppStrings.refreshTooltip,
                    onPressed: onRefresh,
                  ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _darkenColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

class _TypeChipsRow extends StatelessWidget {
  const _TypeChipsRow({required this.types});

  final List<PokemonType> types;

  @override
  Widget build(BuildContext context) {
    final sorted = [...types]..sort((a, b) => a.slot.compareTo(b.slot));
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sorted.map((t) {
        final color = ColorPalette.typeColor(t.type.name);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, _darkenColor(color, 0.12)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: Text(
            t.type.name.capitalize,
            style: const TextStyle(color: ColorPalette.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        );
      }).toList(),
    );
  }
}

class _PhysicalInfoRow extends StatelessWidget {
  const _PhysicalInfoRow({required this.detail});

  final PokemonDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surfaceLight,
        borderRadius: BorderRadius.circular(WidgetRadius.main),
        boxShadow: [BoxShadow(color: ColorPalette.shadow(), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          _InfoCell(label: 'Height', value: '${detail.heightMetres.toStringAsFixed(1)} m'),
          _VerticalDivider(),
          _InfoCell(label: 'Weight', value: '${detail.weightKg.toStringAsFixed(1)} kg'),
          _VerticalDivider(),
          _InfoCell(label: 'Base XP', value: '${detail.baseExperience}'),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.mainSmall(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption()),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 38, color: ColorPalette.surfaceDark);
  }
}

class _SoundSection extends StatelessWidget {
  const _SoundSection({required this.pokemon, required this.cries, required this.playingCry, required this.onPlay});

  final PokemonCries cries;
  final String? playingCry;
  final String pokemon;
  final Future<void> Function(String type, String url) onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceLight,
        borderRadius: BorderRadius.circular(WidgetRadius.main),
        boxShadow: [BoxShadow(color: ColorPalette.shadow(), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.music_note_rounded, size: 18, color: ColorPalette.textSecondary),
              const SizedBox(width: 6),
              Text('${pokemon.formatName}\'s Cry', style: AppTextStyles.mainSmall(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (cries.latest != null)
                Expanded(
                  child: _CryButton(
                    label: 'Current',
                    icon: Icons.graphic_eq_rounded,
                    isPlaying: playingCry == 'latest',
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onPlay('latest', cries.latest!);
                    },
                  ),
                ),
              if (cries.latest != null && cries.legacy != null) const SizedBox(width: 10),
              if (cries.legacy != null)
                Expanded(
                  child: _CryButton(
                    label: 'Legacy',
                    icon: Icons.history_rounded,
                    isPlaying: playingCry == 'legacy',
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onPlay('legacy', cries.legacy!);
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CryButton extends StatelessWidget {
  const _CryButton({required this.label, required this.icon, required this.isPlaying, required this.onTap});

  final String label;
  final IconData icon;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isPlaying ? ColorPalette.primary : ColorPalette.background,
          borderRadius: BorderRadius.circular(WidgetRadius.button),
          border: Border.all(color: isPlaying ? ColorPalette.primary : ColorPalette.surfaceDark),
          boxShadow: isPlaying ? [BoxShadow(color: ColorPalette.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isPlaying ? Icons.stop_rounded : icon, color: isPlaying ? ColorPalette.white : ColorPalette.textSecondary, size: 20),
            const SizedBox(width: 6),
            Text(
              isPlaying ? 'Stop' : label,
              style: AppTextStyles.sub(color: isPlaying ? ColorPalette.white : ColorPalette.textSecondary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpriteGallery extends StatelessWidget {
  const _SpriteGallery({required this.sprites, required this.typeColor, required this.selectedUrl, required this.brokenSprites, required this.onSelect, required this.onBroken});

  final PokemonSprites sprites;
  final Color typeColor;
  final String? selectedUrl;
  final Set<String> brokenSprites;
  final void Function(String url) onSelect;
  final void Function(String url) onBroken;

  @override
  Widget build(BuildContext context) {
    final standard = <_SpriteEntry>[];
    void addStandard(String? url, String label) {
      if (url != null && !brokenSprites.contains(url)) {
        standard.add(_SpriteEntry(url, label));
      }
    }

    addStandard(sprites.frontDefault, SpriteLabels.front);
    addStandard(sprites.backDefault, SpriteLabels.back);
    addStandard(sprites.frontShiny, SpriteLabels.shiny);
    addStandard(sprites.backShiny, SpriteLabels.shinyBack);
    addStandard(sprites.frontFemale, SpriteLabels.female);
    addStandard(sprites.frontShinyFemale, SpriteLabels.shinyFemale);
    addStandard(sprites.dreamWorld?.frontDefault, SpriteLabels.dreamWorld);
    addStandard(sprites.home?.frontDefault, SpriteLabels.home);
    addStandard(sprites.home?.frontShiny, SpriteLabels.homeShiny);

    final showdown = <_SpriteEntry>[];
    void addShowdown(String? url, String label) {
      if (url != null && !brokenSprites.contains(url)) {
        showdown.add(_SpriteEntry(url, label));
      }
    }

    addShowdown(sprites.showdown?.frontDefault, SpriteLabels.front);
    addShowdown(sprites.showdown?.frontShiny, SpriteLabels.shiny);
    addShowdown(sprites.showdown?.backDefault, SpriteLabels.back);
    addShowdown(sprites.showdown?.backShiny, SpriteLabels.shinyBack);
    addShowdown(sprites.showdown?.frontFemale, SpriteLabels.female);
    addShowdown(sprites.showdown?.frontShinyFemale, SpriteLabels.shinyFemale);

    if (standard.isEmpty && showdown.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Sprites'),
        const SizedBox(height: 12),
        if (standard.isNotEmpty) _SpriteRow(items: standard, typeColor: typeColor, selectedUrl: selectedUrl, onSelect: onSelect, onBroken: onBroken),
        if (showdown.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(color: typeColor, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              Text(
                'Showdown',
                style: AppTextStyles.sub(fontWeight: FontWeight.w700, color: ColorPalette.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SpriteRow(items: showdown, typeColor: typeColor, selectedUrl: selectedUrl, onSelect: onSelect, onBroken: onBroken),
        ],
      ],
    );
  }
}

class _SpriteRow extends StatelessWidget {
  const _SpriteRow({required this.items, required this.typeColor, required this.selectedUrl, required this.onSelect, required this.onBroken});

  final List<_SpriteEntry> items;
  final Color typeColor;
  final String? selectedUrl;
  final void Function(String url) onSelect;
  final void Function(String url) onBroken;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = items[i];
          final isSelected = selectedUrl == item.url;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 104,
            decoration: BoxDecoration(
              color: isSelected ? typeColor.withValues(alpha: 0.08) : ColorPalette.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isSelected ? typeColor : ColorPalette.surfaceDark, width: isSelected ? 2 : 1),
              boxShadow: isSelected ? [BoxShadow(color: typeColor.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))] : [BoxShadow(color: ColorPalette.shadow(), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: item.url,
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  errorWidget: (ctx, url, err) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => onBroken(url));
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    item.label,
                    style: AppTextStyles.caption(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SpriteEntry {
  const _SpriteEntry(this.url, this.label);
  final String url;
  final String label;
}

class _StatsBars extends StatelessWidget {
  const _StatsBars({required this.stats, required this.typeColor});

  final List<PokemonStat> stats;
  final Color typeColor;

  static const _maxStat = 255.0;
  static const _labels = <String, String>{'hp': 'HP', 'attack': 'ATK', 'defense': 'DEF', 'special-attack': 'SpA', 'special-defense': 'SpD', 'speed': 'SPD'};

  Color _barColor(int value) {
    if (value >= 120) return const Color(0xFF43A047);
    if (value >= 80) return const Color(0xFFFFA000);
    return typeColor;
  }

  @override
  Widget build(BuildContext context) {
    final total = stats.fold(0, (sum, s) => sum + s.baseStat);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceLight,
        borderRadius: BorderRadius.circular(WidgetRadius.main),
        boxShadow: [BoxShadow(color: ColorPalette.shadow(), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          ...stats.map((stat) {
            final label = _labels[stat.stat.name] ?? stat.stat.name.formatName;
            final fraction = (stat.baseStat / _maxStat).clamp(0.0, 1.0);
            final barColor = _barColor(stat.baseStat);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(label, style: AppTextStyles.sub(fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(
                    width: 38,
                    child: Text(
                      '${stat.baseStat}',
                      style: AppTextStyles.mainSmall(color: ColorPalette.textPrimary, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: fraction),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, value, _) => Stack(
                          children: [
                            Container(
                              height: 14,
                              decoration: BoxDecoration(color: barColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(7)),
                            ),
                            FractionallySizedBox(
                              widthFactor: value,
                              child: Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [barColor.withValues(alpha: 0.75), barColor], begin: Alignment.centerLeft, end: Alignment.centerRight),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 28, color: ColorPalette.surfaceDark),
          Row(
            children: [
              SizedBox(
                width: 40,
                child: Text('TOT', style: AppTextStyles.sub(fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                width: 38,
                child: Text(
                  '$total',
                  style: AppTextStyles.mainSmall(color: ColorPalette.textPrimary, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AbilitiesSection extends StatelessWidget {
  const _AbilitiesSection({required this.abilities});

  final List<PokemonAbility> abilities;

  @override
  Widget build(BuildContext context) {
    final sorted = [...abilities]..sort((a, b) => a.slot.compareTo(b.slot));
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surfaceLight,
        borderRadius: BorderRadius.circular(WidgetRadius.main),
        boxShadow: [BoxShadow(color: ColorPalette.shadow(), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: sorted.asMap().entries.map((e) {
          final i = e.key;
          final a = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(a.ability.name.formatName, style: AppTextStyles.main(fontWeight: FontWeight.w600)),
                    ),
                    if (a.isHidden)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: ColorPalette.textSecondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          'Hidden',
                          style: AppTextStyles.caption(color: ColorPalette.textSecondary, fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              ),
              if (i < sorted.length - 1) const Divider(height: 1, color: ColorPalette.surfaceDark),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _GenerationsSection extends StatelessWidget {
  const _GenerationsSection({required this.detail});

  final PokemonDetail detail;

  @override
  Widget build(BuildContext context) {
    final hasGameIndices = detail.gameIndices.isNotEmpty;
    final hasPastTypes = detail.pastTypes.isNotEmpty;
    final hasPastAbilities = detail.pastAbilities.isNotEmpty;

    if (!hasGameIndices && !hasPastTypes && !hasPastAbilities) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: ColorPalette.surfaceLight, borderRadius: BorderRadius.circular(WidgetRadius.main)),
        child: Text('No generation data available.', style: AppTextStyles.sub()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasGameIndices) ...[_SubSectionHeader(title: 'Game Appearances'), const SizedBox(height: 10), _GameAppearancesGrid(gameIndices: detail.gameIndices), const SizedBox(height: 18)],
        if (hasPastTypes) ...[_SubSectionHeader(title: 'Type History'), const SizedBox(height: 10), ...detail.pastTypes.map((e) => _PastTypeRow(entry: e)), const SizedBox(height: 10)],
        if (hasPastAbilities) ...[_SubSectionHeader(title: 'Ability History'), const SizedBox(height: 10), ...detail.pastAbilities.map((e) => _PastAbilityRow(entry: e))],
      ],
    );
  }
}

class _GameAppearancesGrid extends StatelessWidget {
  const _GameAppearancesGrid({required this.gameIndices});

  final List<GameIndex> gameIndices;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: gameIndices.map((gi) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ColorPalette.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ColorPalette.surfaceDark),
            boxShadow: [BoxShadow(color: ColorPalette.shadow(0.03), blurRadius: 4)],
          ),
          child: Text(gi.version.name.formatName, style: AppTextStyles.sub(fontWeight: FontWeight.w500)),
        );
      }).toList(),
    );
  }
}

class _PastTypeRow extends StatelessWidget {
  const _PastTypeRow({required this.entry});

  final PastTypeEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: ColorPalette.surfaceLight,
          borderRadius: BorderRadius.circular(WidgetRadius.main),
          border: Border.all(color: ColorPalette.surfaceDark),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(entry.generation.name.formatGenerationName, style: AppTextStyles.sub(fontWeight: FontWeight.w600)),
            ),
            Wrap(
              spacing: 6,
              children: entry.types.map((t) {
                final color = ColorPalette.typeColor(t.type.name);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    t.type.name.capitalize,
                    style: const TextStyle(color: ColorPalette.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PastAbilityRow extends StatelessWidget {
  const _PastAbilityRow({required this.entry});

  final PastAbilityEntry entry;

  @override
  Widget build(BuildContext context) {
    final names = entry.abilities.where((a) => a.ability != null).map((a) => a.ability!.name.formatName).toList();
    if (names.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: ColorPalette.surfaceLight,
          borderRadius: BorderRadius.circular(WidgetRadius.main),
          border: Border.all(color: ColorPalette.surfaceDark),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(entry.generation.name.formatGenerationName, style: AppTextStyles.sub(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Text(names.join(', '), style: AppTextStyles.sub()),
          ],
        ),
      ),
    );
  }
}

class _MovesSection extends StatefulWidget {
  const _MovesSection({required this.moves});

  final List<PokemonMove> moves;

  @override
  State<_MovesSection> createState() => _MovesSectionState();
}

class _MovesSectionState extends State<_MovesSection> {
  static const _groupOrder = ['level-up', 'egg', 'tutor'];
  static const _groupLabels = <String, String>{'level-up': 'Level-Up', 'egg': 'Egg Moves', 'tutor': 'Move Tutor'};
  static const _maxPerGroup = 30;

  final Map<String, bool> _expanded = {};

  Map<String, List<_MoveEntry>> _groupMoves() {
    final grouped = <String, List<_MoveEntry>>{};
    for (final move in widget.moves) {
      if (move.versionGroupDetails.isEmpty) continue;
      final vgd = move.versionGroupDetails.last;
      final method = vgd.moveLearnMethod.name;
      grouped.putIfAbsent(method, () => []).add(_MoveEntry(move.move.name, vgd.levelLearnedAt));
    }
    grouped['level-up']?.sort((a, b) => a.level.compareTo(b.level));
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupMoves();
    final orderedKeys = [..._groupOrder.where(grouped.containsKey), ...grouped.keys.where((k) => !_groupOrder.contains(k))];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: orderedKeys.map((method) {
        final moves = grouped[method]!;
        final label = _groupLabels[method] ?? method.formatName;
        final isExpanded = _expanded[method] ?? false;
        final displayed = isExpanded ? moves : moves.take(_maxPerGroup).toList();
        final hasMore = moves.length > _maxPerGroup;

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubSectionHeader(title: '$label (${moves.length})'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: ColorPalette.surfaceLight,
                  borderRadius: BorderRadius.circular(WidgetRadius.main),
                  boxShadow: [BoxShadow(color: ColorPalette.shadow(), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    ...displayed.asMap().entries.map((e) {
                      final i = e.key;
                      final mv = e.value;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                if (method == 'level-up')
                                  Container(
                                    width: 44,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      mv.level == 0 ? 'Evo' : 'Lv ${mv.level}',
                                      style: AppTextStyles.caption(color: ColorPalette.primary, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                Expanded(child: Text(mv.name.formatName, style: AppTextStyles.mainSmall())),
                              ],
                            ),
                          ),
                          if (i < displayed.length - 1 || hasMore) const Divider(height: 1, color: ColorPalette.surfaceDark),
                        ],
                      );
                    }),
                    if (hasMore)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _expanded[method] = !isExpanded);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: ColorPalette.background,
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(WidgetRadius.main)),
                          ),
                          child: Text(
                            isExpanded ? 'Show fewer' : 'Show all ${moves.length} moves',
                            style: AppTextStyles.sub(color: ColorPalette.primary, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MoveEntry {
  const _MoveEntry(this.name, this.level);
  final String name;
  final int level;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.accentColor});

  final String title;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(color: accentColor ?? ColorPalette.primary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.headingSmall(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _SubSectionHeader extends StatelessWidget {
  const _SubSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.main(color: ColorPalette.textSecondary, fontWeight: FontWeight.w700),
    );
  }
}
