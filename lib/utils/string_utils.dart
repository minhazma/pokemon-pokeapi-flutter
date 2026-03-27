extension StringUtils on String {
  String get capitalize => isEmpty ? this : this[0].toUpperCase() + substring(1);

  String get formatName => split('-').map((w) => w.capitalize).join(' ');

  String get formatGenerationName {
    final parts = split('-');
    return parts.length >= 2 ? '${parts[0].capitalize} ${parts[1].toUpperCase()}' : capitalize;
  }
}
