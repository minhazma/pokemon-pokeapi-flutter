class AppStrings {
  static const String appName = 'Pokémon';
  static const String noInternetMessage = 'No Internet Connection';
  static const String failedToLoadPokemon = 'Failed to load Pokémon';
  static const String checkConnectionMessage = 'Check your connection and try again.';
  static const String retryButtonText = 'Retry';
  static const String refreshTooltip = 'Refresh from network';
  static const String fetchFailedRefreshMessage = 'Failed to refresh. Check your connection.';
  static const String pokemonListTitle = 'Pokémons';
  static const String searchHint = 'Search Pokémon…';
  static const String noPokemonFound = 'No Pokémon found';
  static const String somethingWentWrong = 'Something went wrong';
  static const String couldNotLoadPokemon = 'Could not load Pokémon. Check your connection and try again.';
  static const String noResultsFor = 'No results for';
  static const String tryDifferentName = 'Try a different name or check your spelling.';
}

class ApiConstants {
  static const String baseUrl = 'https://pokeapi.co/api/v2/';
  static const String pokeBallImageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png';
}

class AppConfig {
  static const Duration cacheMaxAge = Duration(hours: 24);
  static const int apiDefaultLimit = 20;
  static const int apiMaxLimit = 100;
  static const int listPageSize = 40;
  static const int fuzzyThreshold = 65;
  static const int defaultDebouncerDelay = 350;
}

class SpriteLabels {
  static const String front = 'Front';
  static const String back = 'Back';
  static const String shiny = 'Shiny';
  static const String shinyBack = 'Shiny Back';
  static const String female = 'Female';
  static const String shinyFemale = 'Shiny';
  static const String dreamWorld = 'Dream World';
  static const String home = 'Home';
  static const String homeShiny = 'Home Shiny';
}
