# Pokémon Flutter App

A Flutter app that fetches and displays Pokémon data from the [PokéAPI](https://pokeapi.co/), built with clean architecture, offline-first design, and a polished UI.

---

## Features

| Feature | Status |
|---|---|
| Paginated Pokémon list (1300+) with name & sprite | ✅ |
| Detail screen — types, stats, abilities, moves | ✅ |
| Offline banner + cached data browsing | ✅ |
| **Bonus:** Fuzzy search (debounced, isolate-safe) | ⭐ |
| **Bonus:** Pokémon cry audio playback | ⭐ |
| **Bonus:** Sprite gallery (front, back, shiny, Home) | ⭐ |
| **Bonus:** Type-based dynamic theming | ⭐ |

---

## Architecture

Layered, offline-first with unidirectional data flow:

```
UI (Screens/Widgets)
    ↓ StreamProviders
State (Riverpod)
    ↓
Repository (PokemonRepository)
    ↓               ↓
API Service     Cache (Drift DB)
```

The list screen always reads from the local Drift DB stream. The repository syncs from the API only when the cache is missing or stale — so the UI is always reactive to a local source of truth.

---

## Key Screens

### List Screen
- `CustomScrollView` with `SliverAppBar`, pinned search bar, and 2-column `SliverGrid`
- Infinite scroll pagination (40 items/page), triggered 400px before the bottom
- Debounced fuzzy search (350ms) runs on a background isolate via `compute()`
- Recursive sprite fallback: official artwork → Home → front default → showdown GIF
- Pre-caches detail data on card render so taps feel instant

### Detail Screen
- Collapsing hero header with type-based colour theming
- Sections: type chips, physical info, cry audio, sprite gallery, animated stat bars, abilities, moves
- Loads from local cache first; falls back to network if stale

---

## Offline & Caching

- **Connectivity:** `internet_connection_checker_plus` wrapped in a singleton stream
- **Global banner:** `ConnectivityOverlay` injected via `MaterialApp` builder — no per-screen wiring needed. Triggers haptic feedback on disconnect.
- **Drift DB tables:**
  - `CachedPokemonList` — id, name, sprite URLs, cached timestamp
  - `CachedPokemonDetail` — full JSON + denormalised columns for fast queries
- **24-hour TTL** on both tables
- **Background sync:** On startup, fetches all Pokémon names in batches of 100 and upserts into the DB via `insertOnConflictUpdate`. Skipped if cache has 500+ fresh rows.

---

## Project Structure

```
lib/
├── api/          # PokemonApiService, AppInitializer
├── cache/        # Drift DB schema, DAOs, generated code
├── models/       # PokemonListItem, PokemonDetail
├── repo/         # PokemonRepository, fuzzy search, debouncer
├── screens/      # List screen, Detail screen
├── ui/           # Styles, route animations
└── utils/        # Providers, constants, connectivity, audio cache

test/
└── models/       # Unit tests for list and detail models
```

---

## Key Packages

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `drift` | Type-safe SQLite ORM |
| `http` | API calls |
| `cached_network_image` | Image caching |
| `internet_connection_checker_plus` | Real connectivity detection |
| `fuzzywuzzy` | Fuzzy search |
| `audioplayers` | Cry audio playback |

---

## AI Usage

~60–70% of the codebase was AI-assisted (Claude Code & Antigravity), primarily for boilerplate: `fromJson`/`toJson` parsing, Drift companions, provider wiring, and widget scaffolding.

All architectural decisions were made manually — offline-first data flow, singleton connectivity stream, isolate-safe fuzzy search, recursive sprite fallback, and cache TTL strategy. Every AI-generated block was reviewed and validated before use:

- **Model parsing** validated against live PokéAPI responses. Caught real edge cases: `base_experience` returns `null` for some Pokémon, and older entries omit the `cries` field entirely — both handled with null-safe parsing.
- **URL edge cases** covered by unit tests for ID extraction with and without trailing slashes, verified against `bulbasaur` (id: 1) and `pikachu` (id: 25).
- **Riverpod providers** checked for `ref.onDispose()` on `databaseProvider`, `apiServiceProvider`, `appInitializerProvider`, and `syncProgressProvider`.
- **Offline scenarios** manually tested: cold start with no cache, list browsing from cached data, and detail screen loading entirely from `CachedPokemonDetail` without a network call.
- **Drift queries** use `insertOnConflictUpdate` for upserts. Ordering is context-aware: `getPage` sorts by `name` for alphabetical list browsing; `PokemonDetailDao` and full name queries sort by `id`.