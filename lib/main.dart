import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:ulin_atuhfront/providers/user_provider.dart';
import 'package:ulin_atuhfront/screens/search_page.dart';
import 'screens/intro_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_page.dart';
import 'screens/all_destinations_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userProvider = UserProvider();
  await userProvider.loadUserFromPrefs();

  runApp(
    ChangeNotifierProvider<UserProvider>.value(
      value: userProvider,
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ulin Atuh',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false, // Opsional: menghilangkan banner debug

      // 2. Gunakan initialRoute dan routes untuk mengatur alur navigasi
      initialRoute: '/', // Rute awal aplikasi adalah IntroPage
      routes: {
        '/': (context) => const IntroPage(), // Rute '/' akan menampilkan IntroPage
        '/login': (context) => const LoginPage(), // Rute '/login' akan menampilkan LoginPage
        '/signup': (context) => const SignUpPage(), // Rute '/signup' akan menampilkan SignUpPage
        '/home': (context) => const HomePage(), // Rute '/home' akan menampilkan HomeScreen
        '/search': (context) => const SearchPage(),
        '/all_destinations': (context) => const AllDestinationsPage(), // Rute untuk halaman semua destinasi
      },
    );
  }
}