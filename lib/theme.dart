import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class AppColors {
  // === Fundo da aplicação ===
  static const Color fundoBranco = Color(0xFFE6F1FD);
  // === Widgets / Caixas ===
  static const Color azulWidgetPrincipal = Color(0xBE1F51FF);
  static const Color azulWidgetSecundario = Color(0xBF5281F5);
  // === Texto ===
  static const Color textoPreto = Color(0xFF000000);
  static const Color textoBranco = Color(0xFFFFFFFF);
  static const Color azulEscuro = Color(0xBF0000FF);
}

final ColorScheme customColorScheme = ColorScheme(
  // === Tema Claro ===
  brightness: Brightness.light,
  // === Widget azul escuro ===
  primary: AppColors.azulWidgetPrincipal,
  onPrimary: AppColors.textoBranco,
  primaryContainer: AppColors.azulWidgetPrincipal, // Cor caixa
  onPrimaryContainer: AppColors.textoBranco, // Texto caixa
  // === Widget azul claro ===
  secondary: AppColors.azulEscuro, // Cor secundaria
  onSecondary: AppColors.textoBranco,
  secondaryContainer: AppColors.azulWidgetSecundario, // Cor caixa
  onSecondaryContainer: AppColors.textoBranco, // Texto caixa
  // === Fundo ===
  surface: AppColors.fundoBranco,
  onSurface: AppColors.textoPreto,
  // === Erro ===
  error: Colors.red,
  onError: Colors.white,
);

final TextTheme customTextTheme = GoogleFonts.oswaldTextTheme().copyWith(
  // === Texto Caixa Maior / Nome Hospital ===
  bodyLarge: GoogleFonts.ptSans(fontSize: 15, color: AppColors.textoBranco , fontWeight: FontWeight.bold),
  // === Texto Caixa Medio / localizão ===
  bodyMedium: GoogleFonts.ptSans(fontSize: 14, color: AppColors.textoBranco , fontWeight: FontWeight.normal),
  // === Texto Caixa Pequeno / Rating - Privado não Privado ===
  bodySmall: GoogleFonts.ptSans(fontSize: 12, color: AppColors.textoBranco , fontWeight: FontWeight.bold),
  // === Texto Fundo Grande / Titulo Pagina ===
  titleLarge: GoogleFonts.ptSans(fontSize: 24, color: AppColors.textoPreto , fontWeight: FontWeight.bold),
  // === Texto Fundo Pequeno / Subtitulo Pagina ===
  titleSmall: GoogleFonts.ptSans(fontSize: 12, color: AppColors.textoPreto , fontWeight: FontWeight.normal),
  // === Texto Fundo Medio / Titulo Secções Pagina ===
  titleMedium: GoogleFonts.ptSans(fontSize: 17, color: AppColors.textoPreto , fontWeight: FontWeight.bold),
  // === Texto NavBar / Paginas ===
  labelLarge: GoogleFonts.roboto(fontSize: 14, color: AppColors.azulEscuro , fontWeight: FontWeight.normal),
  // === Texto Botoes / Azul Escuro ===
  labelMedium: GoogleFonts.ptSans(fontSize: 13, color: AppColors.azulEscuro , fontWeight: FontWeight.bold),
);


ThemeData themeLight() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: customColorScheme,
    textTheme: customTextTheme,

    appBarTheme: AppBarTheme(
      backgroundColor: customColorScheme.primary,
      foregroundColor: customColorScheme.onPrimary,
      centerTitle: true,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: customColorScheme.surface,
      indicatorColor: Colors.transparent, // elimina o cilindro

      iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
        final isSelected = states.contains(MaterialState.selected);
        return IconThemeData(
          color: isSelected ? AppColors.azulEscuro : AppColors.azulEscuro.withOpacity(0.3),
          size: 24,
        );
      }),

      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
        final isSelected = states.contains(MaterialState.selected);
        return GoogleFonts.roboto(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: isSelected
              ? AppColors.azulEscuro
              : AppColors.azulEscuro.withOpacity(0.3),
        );
      }),
    ),
  );
}
