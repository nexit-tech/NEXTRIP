import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:html' as html if (dart.library.io) 'package:app_v7_web/dummy_html.dart'; 

import 'theme/app_colors.dart';
import 'pages/login_page.dart';
import 'pages/reset_password_page.dart';
import 'pages/home_page.dart'; // Importante para redirecionar

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Configuração do Google Maps na Web
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

  // Inicialização do Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    debug: true,
  );

  // Inicialização do Stripe
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  await Stripe.instance.applySettings();

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
  
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Escuta eventos de Auth (Recuperação de senha, Logout, etc)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      
      if (event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const ResetPasswordPage())
        );
      } else if (event == AuthChangeEvent.signedOut) {
        // Se deslogar, garante que volta pro Login e limpa o histórico
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
      // --- AQUI É A MÁGICA DO "LEMBRAR DE MIM" ---
      // Verifica se já existe um usuário válido no cache do Supabase.
      // Se sim, vai direto pra Home. Se não, vai pro Login.
      home: Supabase.instance.client.auth.currentUser != null 
          ? const HomePage() 
          : const LoginPage(),
    );
  }
}