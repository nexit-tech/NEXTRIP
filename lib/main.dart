import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
// O pacote universal_html evita erros na web/mobile ao usar html.window
import 'package:universal_html/html.dart' as html;

import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Tenta carregar o arquivo .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("CRÍTICO: Erro ao carregar .env: $e");
    // Não paramos aqui, pois as variáveis podem vir do ambiente (sistema) em produção
  }

  // 2. Busca as chaves
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];
  final mapsKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  // 3. VERIFICAÇÃO DE SEGURANÇA (O Pulo do Gato para evitar tela preta)
  if (supabaseUrl == null || supabaseKey == null) {
    // Se faltar chave, rodamos um app de erro visual para você saber o que houve
    runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "ERRO FATAL:\n\nAs chaves do Supabase não foram encontradas.\n\nVerifique se o arquivo .env existe na raiz e se contém SUPABASE_URL e SUPABASE_ANON_KEY.",
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
    return; // Encerra a execução aqui para não travar lá embaixo
  }

  // 4. Se chegou aqui, as chaves existem. Inicializa o Supabase.
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
    debug: kDebugMode, // Ativa logs apenas em modo debug
  );

  // 5. Google Maps na Web (Só roda se for Web e tiver chave)
  if (kIsWeb && mapsKey != null && mapsKey.isNotEmpty) {
    final script = html.ScriptElement()
      ..src = 'https://maps.googleapis.com/maps/api/js?key=$mapsKey'
      ..id = 'google-maps-script'
      ..async = true
      ..defer = true;
    html.document.head?.append(script);
  }

  // 6. Ajuste da barra de status (transparente)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // 7. Roda o App Principal
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
    // Garante que a verificação de auth ocorra após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    // Pequeno delay artificial para garantir que o Supabase carregou a sessão do disco
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    try {
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Se der erro no Supabase aqui, manda pro login por segurança
      debugPrint("Erro na verificação de sessão: $e");
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        // Adicionei um loading para você saber que o app está pensando e não travado
        child: CircularProgressIndicator(
          color: AppColors.white,
        ),
      ), 
    );
  }
}