import 'package:flutter/material.dart';

/// Forest-and-stone palette with one deep green accent. Amber is reserved for
/// earned things (stars, coins, streak).
@immutable
class SqColors extends ThemeExtension<SqColors> {
  const SqColors({
    required this.background,
    required this.surface,
    required this.surfaceWarm,
    required this.surfaceGreen,
    required this.surfaceMuted,
    required this.border,
    required this.ink,
    required this.inkSoft,
    required this.inkMuted,
    required this.green,
    required this.greenDeep,
    required this.greenSoft,
    required this.greenTint,
    required this.amber,
    required this.amberSoft,
    required this.coral,
    required this.coralSoft,
    required this.lavender,
    required this.lavenderSoft,
    required this.skin,
    required this.hair,
  });

  final Color background;
  final Color surface;
  final Color surfaceWarm;
  final Color surfaceGreen;
  final Color surfaceMuted;
  final Color border;
  final Color ink;
  final Color inkSoft;
  final Color inkMuted;
  final Color green;
  final Color greenDeep;
  final Color greenSoft;
  final Color greenTint;
  final Color amber;
  final Color amberSoft;
  final Color coral;
  final Color coralSoft;
  final Color lavender;
  final Color lavenderSoft;
  final Color skin;
  final Color hair;

  static const light = SqColors(
    background: Color(0xFFFBF8F1),
    surface: Color(0xFFFFFDF8),
    surfaceWarm: Color(0xFFF8EEDF),
    surfaceGreen: Color(0xFFE4EDDF),
    surfaceMuted: Color(0xFFF2EFE9),
    border: Color(0xFFECE3D4),
    ink: Color(0xFF1C241F),
    inkSoft: Color(0xFF3A433D),
    inkMuted: Color(0xFF6F756F),
    green: Color(0xFF4E8A57),
    greenDeep: Color(0xFF3D6F45),
    greenSoft: Color(0xFFA9C7A4),
    greenTint: Color(0xFFD7E6D3),
    amber: Color(0xFFF2B233),
    amberSoft: Color(0xFFFCEFD2),
    coral: Color(0xFFE2563F),
    coralSoft: Color(0xFFFBE2DA),
    lavender: Color(0xFF8E6CC9),
    lavenderSoft: Color(0xFFEDE5F7),
    skin: Color(0xFFF8D2B8),
    hair: Color(0xFF7A4A2B),
  );

  static const dark = SqColors(
    background: Color(0xFF141A16),
    surface: Color(0xFF1C2420),
    surfaceWarm: Color(0xFF262A22),
    surfaceGreen: Color(0xFF203024),
    surfaceMuted: Color(0xFF232925),
    border: Color(0xFF2F3832),
    ink: Color(0xFFF1EEE6),
    inkSoft: Color(0xFFD6D6CE),
    inkMuted: Color(0xFF9AA19A),
    green: Color(0xFF6DAE76),
    greenDeep: Color(0xFF4E8A57),
    greenSoft: Color(0xFF4F7A55),
    greenTint: Color(0xFF2A3D2E),
    amber: Color(0xFFF2B840),
    amberSoft: Color(0xFF3A3220),
    coral: Color(0xFFEE7560),
    coralSoft: Color(0xFF3E2722),
    lavender: Color(0xFFB396E6),
    lavenderSoft: Color(0xFF2E2840),
    skin: Color(0xFFF1C7AA),
    hair: Color(0xFF6B3F24),
  );

  @override
  SqColors copyWith() => this;

  @override
  SqColors lerp(ThemeExtension<SqColors>? other, double t) {
    if (other is! SqColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SqColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceWarm: l(surfaceWarm, other.surfaceWarm),
      surfaceGreen: l(surfaceGreen, other.surfaceGreen),
      surfaceMuted: l(surfaceMuted, other.surfaceMuted),
      border: l(border, other.border),
      ink: l(ink, other.ink),
      inkSoft: l(inkSoft, other.inkSoft),
      inkMuted: l(inkMuted, other.inkMuted),
      green: l(green, other.green),
      greenDeep: l(greenDeep, other.greenDeep),
      greenSoft: l(greenSoft, other.greenSoft),
      greenTint: l(greenTint, other.greenTint),
      amber: l(amber, other.amber),
      amberSoft: l(amberSoft, other.amberSoft),
      coral: l(coral, other.coral),
      coralSoft: l(coralSoft, other.coralSoft),
      lavender: l(lavender, other.lavender),
      lavenderSoft: l(lavenderSoft, other.lavenderSoft),
      skin: l(skin, other.skin),
      hair: l(hair, other.hair),
    );
  }
}

extension SqContext on BuildContext {
  SqColors get sq => Theme.of(this).extension<SqColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}

class AppTheme {
  static const display = 'Nunito';
  static const body = 'NunitoSans';

  static ThemeData light() => _build(SqColors.light, Brightness.light);
  static ThemeData dark() => _build(SqColors.dark, Brightness.dark);

  static ThemeData _build(SqColors c, Brightness b) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.green,
      brightness: b,
      primary: c.green,
      surface: c.background,
    );
    TextStyle d(double size, FontWeight w, {double h = 1.1}) => TextStyle(
          fontFamily: display,
          fontSize: size,
          fontWeight: w,
          height: h,
          color: c.ink,
          letterSpacing: -0.5,
        );
    TextStyle t(double size, FontWeight w, {Color? color, double h = 1.35}) =>
        TextStyle(
          fontFamily: body,
          fontSize: size,
          fontWeight: w,
          height: h,
          color: color ?? c.ink,
        );
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      fontFamily: body,
      extensions: [c],
      splashFactory: InkSparkle.splashFactory,
      textTheme: TextTheme(
        displayLarge: d(44, FontWeight.w900, h: 1.02),
        displayMedium: d(36, FontWeight.w900, h: 1.05),
        displaySmall: d(30, FontWeight.w900),
        headlineMedium: d(26, FontWeight.w800),
        headlineSmall: d(22, FontWeight.w800),
        titleLarge: d(20, FontWeight.w800, h: 1.2),
        titleMedium: t(17, FontWeight.w700),
        titleSmall: t(15, FontWeight.w700),
        bodyLarge: t(17, FontWeight.w500),
        bodyMedium: t(15, FontWeight.w500),
        bodySmall: t(13, FontWeight.w500, color: c.inkMuted),
        labelLarge: t(15, FontWeight.w700),
        labelMedium: t(13, FontWeight.w600, color: c.inkMuted),
        labelSmall: t(11.5, FontWeight.w700, color: c.inkMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.ink,
        contentTextStyle: t(14, FontWeight.w600, color: c.background),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: c.border,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : c.inkMuted),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? c.green : c.surfaceMuted),
        trackOutlineColor: WidgetStateProperty.all(c.border),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceGreen,
        hintStyle: t(16, FontWeight.w500, color: c.inkMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.greenSoft, width: 1.5),
        ),
      ),
    );
  }
}

/// Global light/dark switch so every screen can be previewed in both themes.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
