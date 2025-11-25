import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html if (dart.library.io) 'package:app_v7_web/dummy_html.dart'; 

import 'theme/app_colors.dart';
import 'pages/login_page.dart';
import 'pages/reset_password_page.dart'; // <--- IMPORT DA NOVA PÁGINA

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  if (kIsWeb) {
    final mapsKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    if (mapsKey.isNotEmpty) {
      final script = html.ScriptElement()
        ..src = 'https://maps.googleapis.com/maps/api/js?key=$mapsKey'
        ..id = 'google-maps-script'
        ..async = true
        ..defer = true;
      html.document.head!.append(script);
    }
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    debug: true,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const MonochromiaApp());
}

class MonochromiaApp extends StatefulWidget {
  const MonochromiaApp({super.key});

  @override
  State<MonochromiaApp> createState() => _MonochromiaAppState();
}

class _MonochromiaAppState extends State<MonochromiaApp> {
  
  @override
  void initState() {
    super.initState();
    // --- OUVINTE DE EVENTOS DO SUPABASE ---
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      
      // Se o evento for recuperação de senha...
      if (event == AuthChangeEvent.passwordRecovery) {
        // ...Navega para a tela de Criar Nova Senha
        // Usamos o navigatorKey global ou contexto se disponível
        // Como estamos no main, vamos deixar o router lidar ou forçar a navegação
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const ResetPasswordPage())
        );
      }
    });
  }

  // Chave global para navegação sem contexto
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // <--- IMPORTANTE LIGAR ISSO
      title: 'NexTrip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.black,
        useMaterial3: true,
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