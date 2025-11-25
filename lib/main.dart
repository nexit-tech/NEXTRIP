import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Importação apenas para o Google Maps (se necessário)
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'theme/app_colors.dart';
import 'pages/login_page.dart';
import 'pages/reset_password_page.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carrega variáveis de ambiente
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
    
    // Listener de Autenticação do Supabase
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      
      if (event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const ResetPasswordPage())
        );
      } else if (event == AuthChangeEvent.signedOut) {
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
      home: Supabase.instance.client.auth.currentUser != null 
          ? const HomePage() 
          : const LoginPage(),
    );
  }
}