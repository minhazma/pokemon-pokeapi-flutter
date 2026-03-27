# Pokédex Flutter App

A take-home Flutter application that fetches and displays Pokémon data from the [PokéAPI](https://pokeapi.co/), built with clean architecture, offline-first design, and a polished UI.

---

## Table of Contents

1. [Features Overview](#features-overview)
2. [Architecture](#architecture)
3. [Feature Implementation Details](#feature-implementation-details)
   - [Pokémon List Screen](#1-pokémon-list-screen)
   - [Detail Screen](#2-detail-screen)
   - [Offline Handling & Caching](#3-offline-handling--caching)
   - [UI/UX](#4-uiux)
4. [Project Structure](#project-structure)
5. [Key Packages](#key-packages)
6. [Getting Started](#getting-started)
7. [Running Tests](#running-tests)
8. [AI Usage & Manual Review](#ai-usage--manual-review)

---

## Features Overview

| Requirement | Status | Notes |
|---|---|---|
| Pokémon list from PokéAPI | ✅ Met | Paginated, infinite scroll, 1300+ Pokémon |
| Name + sprite on each card | ✅ Met | Official artwork with smart fallback chain |
| Detail screen on tap | ✅ Met | Types, abilities, stats, moves, sprites |
| Offline error message | ✅ Met | Persistent banner via connectivity stream |
| View cached data offline | ✅ Met | Drift SQLite DB with 24-hour TTL |
| Clean UI with Flutter widgets | ✅ Met | Custom SliverAppBar, GridView, Cards |
| **Bonus — Fuzzy search** | ⭐ Extra | `fuzzywuzzy` on local DB, debounced |
| **Bonus — Pokémon cries audio** | ⭐ Extra | Streams audio from PokéAPI CDN |
| **Bonus — Sprite gallery** | ⭐ Extra | Front, back, shiny, Dream World, Home |
| **Bonus — Type-based theming** | ⭐ Extra | Dynamic colour per primary type |

---

## Architecture

The app follows a **layered, offline-first architecture** with unidirectional data flow:

```
UI Layer (Screens / Widgets)
        ↓  watches StreamProviders
State Layer (Riverpod Providers)
        ↓  calls
Repository Layer (PokemonRepository)
        ↓            ↓
  API Layer     Cache Layer
(PokemonApiService) (Drift SQLite via DAOs)
```

**State management:** `flutter_riverpod` — providers are scoped, auto-disposed, and composable.

**Data flow principle:** The list screen always reads from the local database stream (`watchPokemonList`). The repository fills the database from the API on first load or when the cache is stale. This means the UI is always reactive to the local source of truth.

---

## Feature Implementation Details

### 1. Pokémon List Screen

**File:** `lib/screens/pokemon_list_screen.dart`

The list screen is built with a `CustomScrollView` using slivers for smooth performance:

- **`SliverAppBar`** — Collapsing header with a gradient background and decorative Pokéball watermark.
- **`SliverPersistentHeader`** — A pinned search bar that stays visible while scrolling.
- **`SliverGrid`** — A 2-column grid of `_PokemonCard` widgets with `childAspectRatio: 0.88`.

**Pagination:** Handled by `pokemonPaginatorProvider` (a `StateNotifierProvider`). The `_onScroll` listener triggers `fetchNextPage()` when the user scrolls within 400px of the bottom. Page size is 40 items per batch.

**Search:** A `Debouncer` (350ms) throttles input. Queries under 2 characters use a direct DB name search; longer queries use `fuzzySearchByName()` which runs `fuzzywuzzy` scoring on a background isolate via `compute()` to avoid jank.

**Sprite loading:** `_SpriteImage` is a recursive widget that tries a list of candidate URLs (official artwork → Home → front default → showdown GIF) and falls back to the next on error. This handles Pokémon whose primary artwork doesn't exist.

**Pre-caching:** Each card's `initState` calls `repository.precacheDetail(id)` so detail data is already in the local DB by the time the user taps.

---

### 2. Detail Screen

**File:** `lib/screens/pokemon_detail_screen.dart`

Navigation uses a custom `SlideRightRoute` page transition for a native feel. The detail screen loads data via `PokemonRepository.getPokemonDetail(id)`, which checks the local cache first (falling back to the API if stale or missing).

The screen is composed of a `CustomScrollView` with a `SliverPersistentHeader` acting as a collapsible hero image, and a scrollable body below.

**Collapsing header (`_PokemonHeaderDelegate`):**
- Interpolates between an expanded state (large sprite + coloured background) and a collapsed state (compact AppBar) using `shrinkOffset`.
- The background colour and darker accent are derived from the Pokémon's primary type via a `typeColorMap`.
- A refresh button lets users force-fetch from the network.

**Body sections rendered:**
- **Type chips** — Coloured pill badges for each type slot.
- **Physical info** — Height (m) and weight (kg), converted from the API's decimetres/hectograms.
- **Pokémon cries** — Streams audio from `cries.latest` / `cries.legacy` URLs using `audioplayers`. Audio files are cached via a custom `AudioCacheManager`.
- **Sprite gallery** — Horizontally scrollable thumbnails (front, back, shiny, Dream World, Home, showdown). Tapping a thumbnail updates the hero image. Broken sprite URLs are tracked in a local `Set<String>` and excluded from rendering.
- **Base stats** — Animated `LinearProgressIndicator` bars coloured by the Pokémon's type. Values shown as `X / 255`.
- **Abilities** — Cards for each ability, noting hidden abilities with a badge.
- **Generations & appearances** — Game indices grouped by generation.
- **Moves** — Expandable list of all learnable moves.

---

### 3. Offline Handling & Caching

**Connectivity detection:** `lib/utils/connectivity_service.dart` wraps `internet_connection_checker_plus` in a singleton broadcast `StreamController`. A `connectivityStatusProvider` exposes this stream to the UI.

**Global offline banner:** In `main.dart`, `ConnectivityOverlay` is injected into the `MaterialApp` builder via a `Stack`. When `InternetStatus.disconnected` is detected, a dark banner slides in at the bottom of every screen. No manual wiring per screen is needed. It also triggers a haptic vibration on disconnect.

**Database caching (Drift / SQLite):**

Two tables are defined in `lib/cache/app_database.dart`:

- `CachedPokemonList` — Stores `id`, `name`, `url`, `spriteUrl`, `officialArtworkUrl`, and a `cachedAt` unix timestamp.
- `CachedPokemonDetail` — Stores the complete `detailJson` (full API response as a JSON string) plus denormalised columns for `types`, `abilities`, and individual stats for efficient querying without re-parsing JSON.

**Cache freshness:** Both DAOs check `cachedAt` against a 24-hour TTL (`AppConfig.cacheMaxAge`). If the cache is fresh, no network call is made.

**Background sync (`AppInitializer`):** On app startup, `AppInitializer.init()` runs two phases asynchronously:
1. **Phase 1 (List sync):** Fetches all Pokémon names from the API in batches of 100 (the API's max `limit`) and upserts them into `CachedPokemonList`. Skipped entirely if the cache has 500+ rows and is fresh.
2. **Phase 2 (Detail sync):** Optionally pre-fetches details for a configurable `detailSyncTarget` count (currently disabled at app start, but the infrastructure is in place). Progress is reported via a `ValueNotifier<SyncProgress>` and exposed as a `StreamProvider`.

**Offline list browsing:** `watchPokemonList()` in the repository returns a `Stream` from Drift. The list screen is always backed by this stream, so cached data is immediately visible even with no connection.

**Offline detail browsing:** If the detail is in `CachedPokemonDetail` and is fresh, it is deserialised from `detailJson` — no network call. If neither cache nor network is available, the detail screen shows a friendly error UI with a Retry button.

---

### 4. UI/UX

**Design system:** All colours, text styles, and button styles are centralised in `lib/ui/styles.dart` (`ColorPalette`, `AppTextStyles`, `AppButtonStyles`). All user-facing strings are in `lib/utils/constants.dart` (`AppStrings`).

**Type colour theming:** The detail screen derives its entire colour palette (header background, stat bar colour, section accent, darker gradient) from the Pokémon's primary type. This makes each detail page feel unique and brand-appropriate.

**Navigation:** `SlideRightRoute` wraps a `SlideTransition` + `FadeTransition` so the detail screen slides in naturally from the right, matching platform conventions.

**Haptics:** `HapticFeedback.mediumImpact()` fires on card tap, `lightImpact()` on search clear, `selectionClick()` on sprite gallery selection, and `vibrate()` on connectivity loss — giving the app a tactile, responsive feel.

**Empty & error states:**
- `_LoadingView` — Centred `CircularProgressIndicator` in the primary colour.
- `_ErrorView` — Icon + message + Retry button; invalidates the relevant Riverpod provider on retry.
- `_EmptyView` — Shown when a search yields no results, with a helpful suggestion to try a different spelling.
- `_SyncProgressView` — Shown during the initial list sync, with a progress indicator.

---

## Project Structure

```
lib/
├── api/
│   ├── api.dart              # PokemonApiService, PokemonPaginator
│   └── init.dart             # AppInitializer (background sync)
├── cache/
│   ├── app_database.dart     # Drift DB schema & DAOs
│   └── app_database.g.dart   # Drift generated code
├── models/
│   ├── list.dart             # PokemonListItem, PokemonListResponse, PaginatedPokemon
│   └── detail.dart           # PokemonDetail and all nested models
├── repo/
│   ├── pokemon_repository.dart  # Single source of truth (API + Cache)
│   ├── fuzzy_search.dart        # Isolate-safe fuzzy search logic
│   └── debouncer.dart           # Search input debouncer
├── screens/
│   ├── pokemon_list_screen.dart  # List / grid screen
│   └── pokemon_detail_screen.dart # Detail screen
├── ui/
│   ├── styles.dart           # ColorPalette, AppTextStyles, AppButtonStyles
│   └── route_animations.dart # SlideRightRoute
├── utils/
│   ├── providers.dart        # All Riverpod providers
│   ├── constants.dart        # AppStrings, ApiConstants, AppConfig
│   ├── connectivity_service.dart # Singleton connectivity stream
│   ├── string_utils.dart     # Extension: formatName
│   └── audio_cache_manager.dart  # Custom cache manager for cry audio
└── main.dart                 # App entry, ProviderScope, ConnectivityOverlay

test/
├── models/
│   ├── pokemon_list_test.dart   # Unit tests for PokemonListItem, PokemonListResponse
│   └── pokemon_detail_test.dart # Unit tests for PokemonDetail model
```

---

## Key Packages

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^3.2.1 | State management |
| `drift` + `drift_dev` | ^2.32.1 | Type-safe SQLite ORM & code gen |
| `http` | ^1.2.1 | HTTP client for PokéAPI calls |
| `cached_network_image` | ^3.4.1 | Image caching with fallback widgets |
| `flutter_cache_manager` | ^3.4.1 | Underlying disk cache for images & audio |
| `internet_connection_checker_plus` | ^2.4.0 | Real connectivity stream (not just network reachability) |
| `fuzzywuzzy` | ^1.2.0 | Fuzzy string matching for Pokémon search |
| `audioplayers` | ^6.6.0 | Pokémon cry audio playback |
| `path_provider` | ^2.1.5 | Platform-safe file paths for Drift |

---

## Getting Started

**Prerequisites:** Flutter SDK `^3.11.3`, Dart SDK `^3.11.3`

```bash
# Install dependencies
flutter pub get

# Run code generation (required for Drift)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

> **Note:** The app requires the code-generated file `lib/cache/app_database.g.dart`. If it is missing, run the `build_runner` command above before launching.

---

## Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/models/pokemon_list_test.dart
flutter test test/models/pokemon_detail_test.dart
```

Test coverage currently includes unit tests for all model parsing logic (`PokemonListItem`, `PokemonListResponse`, `PokemonDetail`), including edge cases for ID extraction, unit conversions (height/weight), and sprite URL construction.

---

## AI Usage & Manual Review

### Percentage of AI-Generated Output

**Approximately 50–60% of the codebase was AI-assisted.**

AI tools (Claude) were used as a pair-programming accelerator throughout the project. The bulk of the AI contribution was in repetitive, structural code — `fromJson`/`toJson` model parsing, Drift table companions, provider wiring boilerplate, and initial widget tree scaffolding. Architectural decisions were made manually: the offline-first data flow, the singleton connectivity stream with global overlay injection, the isolate-safe `compute()` pattern for fuzzy search, the recursive sprite fallback chain, and the cache TTL strategy. UI proportions, sliver composition, type-based colour theming, and animation tuning were also hand-crafted. Every AI-generated output was reviewed and, in many cases, modified before use — so the final code reflects deliberate authorship rather than wholesale generation.

---

### How Manual Review Was Conducted

Every AI-generated code block was reviewed before being committed, following this process:

**1. Model parsing against the live API**
Every `fromJson` factory was validated by hitting the actual PokéAPI endpoints and comparing response shapes to the generated code. This caught two real issues: `base_experience` returns `null` for some Pokémon (e.g., Eternatus forms), requiring the `int? ?? 0` fallback in `PokemonDetail`; and the `cries` field is absent entirely on older Pokémon entries, requiring a null-safe parse rather than a direct cast.

**2. ID extraction edge case in `PokemonListItem`**
The PokéAPI returns URLs with a trailing slash (e.g., `.../pokemon/1/`) but not always consistently. The `id` getter splits on `/` and strips empty segments before parsing the last element. This was verified with unit tests covering both trailing-slash and non-trailing-slash formats, and confirmed against `pikachu` (id: 25) and `bulbasaur` (id: 1) in `pokemon_list_test.dart`.

**3. Sprite fallback chain validation**
The `_SpriteImage` widget tries a list of candidate URLs in priority order. During review it was found that several Pokémon (notably Scarlet/Violet additions) have no official artwork URL in the API list response — so `officialArtworkUrl` was added as an optional field on `PokemonListItem` and the constructed GitHub raw URL is used as the first fallback. The recursive `errorWidget` pattern was manually verified to not infinitely recurse by capping at `index >= urls.length`.

**4. Riverpod provider scoping & disposal**
Each provider that holds a resource (`AppDatabase`, `PokemonApiService`, `AppInitializer`) was checked to have a matching `ref.onDispose()` call to prevent leaks across hot restarts and test runs. The `pokemonListStreamProvider` uses `.family` with a `String` parameter — this was reviewed to confirm Riverpod correctly caches and disposes per-query streams as the search input changes.

**5. Offline scenario walkthrough**
The three offline states were manually exercised: (a) airplane mode before first launch — list screen shows the loading indicator briefly, then the error view with Retry; (b) airplane mode after the list cache is populated — the grid loads instantly from Drift with the connectivity banner appearing at the bottom; (c) airplane mode after visiting a detail page — the detail screen loads from `detailJson` in `CachedPokemonDetail` without any network call. This confirmed the cache-first flow in `PokemonRepository.getPokemonDetail()` works end-to-end.

**6. Drift DAO query correctness**
The `watchPokemonList` stream query and the `searchByName` SQL were reviewed to ensure they return results ordered by `id` (not insertion order), and that `upsertAll` uses `InsertMode.insertOrReplace` so re-syncing doesn't create duplicate rows. The `isCacheStale` check was also verified to use `MIN(cachedAt)` rather than `MAX`, so a partial sync that left old rows doesn't incorrectly mark the cache as fresh.