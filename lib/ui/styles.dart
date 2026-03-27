import 'package:flutter/material.dart';

class Elevations {
  static const double short = 0.5;
  static const double medium = 1.5;
  static const double high = 3.5;
}

class ColorPalette {
  static const Color primary = Color(0xFFE3350D);
  static const Color primaryLight = Color(0xFFFF5959);
  static const Color primaryDark = Color(0xFFB02508);

  static const Color secondary = Color(0xFFE6BC2F);
  static const Color secondaryLight = Color(0xFFFBD743);
  static const Color secondaryDark = Color(0xFFC5A000);

  static const Color background = Color(0xFFF2F2F2);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFFE0E0E0);

  static const Color textPrimary = Color(0xFF313131);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textLight = Color(0xFFFFFFFF);

  static const Color accent = Color(0xFF30A7D7);
  static const Color warning = Color(0xFFF17F2F);
  static const Color success = Color(0xFF9BCC50);

  static const LinearGradient primaryGradient = LinearGradient(colors: [primary, primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight);

  static Color typeColor(String type) {
    const map = <String, Color>{
      'normal': Color(0xFFA8A77A),
      'fire': Color(0xFFEE8130),
      'water': Color(0xFF6390F0),
      'electric': Color(0xFFF7D02C),
      'grass': Color(0xFF7AC74C),
      'ice': Color(0xFF96D9D6),
      'fighting': Color(0xFFC22E28),
      'poison': Color(0xFFA33EA1),
      'ground': Color(0xFFE2BF65),
      'flying': Color(0xFFA98FF3),
      'psychic': Color(0xFFF95587),
      'bug': Color(0xFFA6B91A),
      'rock': Color(0xFFB6A136),
      'ghost': Color(0xFF735797),
      'dragon': Color(0xFF6F35FC),
      'dark': Color(0xFF705746),
      'steel': Color(0xFFB7B7CE),
      'fairy': Color(0xFFD685AD),
    };
    return map[type.toLowerCase()] ?? const Color(0xFF68A090);
  }

  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color white70 = Colors.white70;

  static Color shadow([double opacity = 0.05]) => Colors.black.withValues(alpha: opacity);

  static const LinearGradient secondaryGradient = LinearGradient(colors: [secondaryLight, secondary], begin: Alignment.topLeft, end: Alignment.bottomRight);
}

class WidgetRadius {
  static const double button = 10.0;
  static const double main = 10.0;
  static const double modal = 16.2;
}

class TextSize {
  static const double headingLarge = 30.0;
  static const double heading = 24.0;
  static const double headingSmall = 20.0;

  static const double mainLarge = 18.0;
  static const double main = 17.0;
  static const double mainSmall = 15.0;

  static const double sub = 13.0;

  static const double subMini = 12.0;
  static const double caption = 11.0;
}

class AppTextStyles {
  static TextStyle headingLarge({Color? color, FontWeight? fontWeight, double? height, TextDecoration? decoration, FontStyle? fontStyle}) {
    return TextStyle(fontSize: TextSize.headingLarge, color: color ?? ColorPalette.textPrimary, fontWeight: fontWeight ?? FontWeight.w700, height: height, decoration: decoration, fontStyle: fontStyle);
  }

  static TextStyle heading({Color? color, FontWeight? fontWeight, double? height, TextDecoration? decoration, FontStyle? fontStyle}) {
    return TextStyle(fontSize: TextSize.heading, color: color ?? ColorPalette.textPrimary, fontWeight: fontWeight ?? FontWeight.w700, height: height, fontStyle: fontStyle, decoration: decoration);
  }

  static TextStyle headingSmall({Color? color, FontWeight? fontWeight, double? height, TextDecoration? decoration, FontStyle? fontStyle}) {
    return TextStyle(fontSize: TextSize.headingSmall, color: color ?? ColorPalette.textPrimary, fontWeight: fontWeight ?? FontWeight.w700, height: height, decoration: decoration, fontStyle: fontStyle);
  }

  static TextStyle mainLarge({Color? color, FontWeight? fontWeight, double? height, TextDecoration? decoration, FontStyle? fontStyle}) {
    return TextStyle(fontSize: TextSize.mainLarge, color: color ?? ColorPalette.textPrimary, fontWeight: fontWeight ?? FontWeight.w500, height: height, decoration: decoration, fontStyle: fontStyle);
  }

  static TextStyle main({Color? color, FontWeight? fontWeight, double? height, TextDecoration? decoration, FontStyle? fontStyle}) {
    return TextStyle(fontSize: TextSize.main, color: color ?? ColorPalette.textPrimary, fontWeight: fontWeight ?? FontWeight.w500, height: height, decoration: decoration, fontStyle: fontStyle);
  }

  static TextStyle mainSmall({Color? color, FontWeight? fontWeight, double? height, TextDecoration? decoration, FontStyle? fontStyle}) {
    return TextStyle(fontSize: TextSize.mainSmall, color: color ?? ColorPalette.textPrimary, fontWeight: fontWeight ?? FontWeight.w500, height: height, decoration: decoration, fontStyle: fontStyle);
  }

  static TextStyle sub({Color? color, FontWeight? fontWeight, double? height, TextDecoration? decoration, FontStyle? fontStyle}) {
    return TextStyle(fontSize: TextSize.sub, fontStyle: fontStyle, color: color ?? ColorPalette.textSecondary, fontWeight: fontWeight ?? FontWeight.w400, height: height, decoration: decoration);
  }

  static TextStyle subMini({Color? color, FontWeight? fontWeight, double? height, TextDecoration? decoration, FontStyle? fontStyle}) {
    return TextStyle(fontSize: TextSize.subMini, color: color ?? ColorPalette.textSecondary, fontWeight: fontWeight ?? FontWeight.w300, height: height, decoration: decoration, fontStyle: fontStyle);
  }

  static TextStyle caption({Color? color, FontWeight? fontWeight, double? height, TextDecoration? decoration, FontStyle? fontStyle}) {
    return TextStyle(fontSize: TextSize.caption, color: color ?? ColorPalette.textSecondary, fontWeight: fontWeight ?? FontWeight.w300, height: height, decoration: decoration, fontStyle: fontStyle);
  }

  static TextStyle buttonText({Color? color, FontWeight? fontWeight, FontStyle? fontStyle}) {
    return TextStyle(fontSize: TextSize.main, color: color ?? ColorPalette.textLight, fontWeight: fontWeight ?? FontWeight.w600, letterSpacing: 0.5, fontStyle: fontStyle);
  }

  static TextStyle link({Color? color, TextDecoration? decoration, FontStyle? fontStyle}) {
    return TextStyle(fontSize: TextSize.main, color: color ?? ColorPalette.accent, fontWeight: FontWeight.w500, decoration: decoration ?? TextDecoration.underline);
  }

  static TextStyle tabLabel({Color? color, FontWeight? fontWeight, FontStyle? fontStyle}) {
    return TextStyle(fontSize: TextSize.sub, color: color ?? ColorPalette.textSecondary, fontWeight: fontWeight ?? FontWeight.w500, fontStyle: fontStyle);
  }

  static TextStyle inputText({Color? color, FontWeight? fontWeight, FontStyle? fontStyle}) {
    return TextStyle(fontSize: TextSize.main, color: color ?? ColorPalette.textPrimary, fontWeight: fontWeight ?? FontWeight.w400, fontStyle: fontStyle);
  }
}

class AppButtonStyles {
  static ButtonStyle primaryButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: ColorPalette.primary,
      foregroundColor: ColorPalette.textLight,
      elevation: Elevations.medium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(WidgetRadius.button)),
    );
  }

  static ButtonStyle warningButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: ColorPalette.warning,
      foregroundColor: ColorPalette.textLight,
      elevation: Elevations.medium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(WidgetRadius.button)),
    );
  }
}
