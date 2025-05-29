import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myapp/src/home_screen.dart';
import 'package:provider/provider.dart';

import 'package:myapp/src/theme_notifier.dart';
import 'package:myapp/src/login_screen.dart';
import 'package:myapp/src/notification_screen.dart';
import 'package:myapp/src/calendar_screen.dart';
import 'package:myapp/src/profile_screen.dart';
import 'components/bottom_nav_bar.dart';
import 'components/usuario_model.dart'; // Modelo do usuário

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  final romanticTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.pink,
    scaffoldBackgroundColor: Colors.white,
    cardColor: const Color(0xFFFFE5E0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFADCD9),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFE5738A)),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFE5738A),
      secondary: Color(0xFFF8BBD0),
      surface: Color(0xFFFADCD9),
    ),
    dividerColor: const Color(0xFFE8B9B2),
    bottomAppBarTheme: const BottomAppBarTheme(color: Color(0xFFE8B9B2)),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(romanticTheme),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme.themeData,
          home: const LoginScreen(), // Inicialmente mostra o login
        );
      },
    );
  }
}

// MainPage agora recebe o usuário logado
class MainPage extends StatefulWidget {
  final UsuarioModel usuarioLogado;

  const MainPage({super.key, required this.usuarioLogado});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    if (widget.usuarioLogado.conexao != null) {
      _pages = [
        CheckListScreen(conexaoId: widget.usuarioLogado.conexao!),
        const NotificationScreen(),
        CalendarScreen(conexaoId: widget.usuarioLogado.conexao!),
        ProfileScreen(conexaoId: widget.usuarioLogado.conexao!),
      ];
    } else {
      _pages = [
        const Center(child: Text('Nenhuma conexão ativa')),
        const NotificationScreen(),
        const Center(child: Text('Nenhuma conexão ativa')),
        const Center(child: Text('Perfil indisponível')),
      ];
    }
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: PageView(
          controller: _pageController,
          children: _pages,
          onPageChanged: (index) => setState(() => _selectedIndex = index),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
