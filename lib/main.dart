import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tucu_free_tacc/screens/profile_screen.dart';
import 'package:tucu_free_tacc/screens/education_screen.dart';
import 'package:tucu_free_tacc/screens/tiendas_screen.dart';
import 'package:tucu_free_tacc/screens/explorar_screen.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = DevHttpOverrides();
  runApp(const TucuFreeTaccApp());
}

class TucuFreeTaccApp extends StatelessWidget {
  const TucuFreeTaccApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tucu free TACC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4285F4),
        ), // El azul principal de tu diseño
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(
          0xFFF8F9FA,
        ), // Fondo clarito de la app
      ),
      home: const MainNavigator(),
    );
  }
}

// Este widget maneja la navegación inferior
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  // Acá vamos a ir reemplazando estos textos por las pantallas reales que armemos
  static const List<Widget> _screens = <Widget>[
    ExplorarScreen(),
    TiendasScreen(),
    EducationScreen(),
    ProfileScreen(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // Fijo para que no se muevan los íconos
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Tiendas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Guia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(
          0xFF8C9EFF,
        ), // Color del ícono seleccionado (simulando tu diseño)
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
