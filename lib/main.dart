import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; // Import novo
import 'theme/app_colors.dart';
import 'pages/login_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MonochromiaApp());
}

class MonochromiaApp extends StatelessWidget {
  const MonochromiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monochromia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.black,
        useMaterial3: true,
        // Configuração Global da Fonte Montserrat
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: AppColors.white,
            displayColor: AppColors.white,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.white,
          surface: AppColors.eerieBlack,
        ),
      ),
      home: const LoginPage(),
    );
  }
}