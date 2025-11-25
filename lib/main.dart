import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
// O pacote universal_html evita erros na web/mobile
import 'package:universal_html/html.dart' as html;

import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Erro ao carregar .env: $e");
  }

  // Inicialização segura do Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl != null && supabaseKey != null) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      debug: false,
    );
  }

  // Google Maps na Web (Só roda se for Web)
  if (kIsWeb) {
    final mapsKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    if (mapsKey.isNotEmpty) {
      final script = html.ScriptElement()
        ..src = 'https://maps.googleapis.com/maps/api/js?key=$mapsKey'
        ..id = 'google-maps-script'
        ..async = true
        ..defer = true;
      html.document.head?.append(script);
    }
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXTRIP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: AppColors.black,
        primaryColor: AppColors.white,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.white,
          secondary: AppColors.white,
          background: AppColors.black,
        ),
        useMaterial3: true,
      ),
      home: const SplashPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // --- CORREÇÃO DO ERRO ---
    // Isso diz ao Flutter: "Termine de desenhar a tela preta PRIMEIRO, 
    // e só DEPOIS verifique o login". Isso evita o travamento do Navigator.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;

    // Obtém a sessão atual
    final session = Supabase.instance.client.auth.currentSession;
    
    // Navega para a página correta
    if (session != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tela preta instantânea enquanto decide para onde ir
    return const Scaffold(
      backgroundColor: AppColors.black,
      body: SizedBox.shrink(), 
    );
  }
}