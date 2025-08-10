// lib/main.dart
import 'package:denemeye_devam/repositories/category_repository.dart';
import 'package:denemeye_devam/viewmodels/appointments_viewmodel.dart';
import 'package:denemeye_devam/viewmodels/auth_viewmodel.dart';
import 'package:denemeye_devam/viewmodels/dashboard_viewmodel.dart';
import 'package:denemeye_devam/viewmodels/favorites_viewmodel.dart';
import 'package:denemeye_devam/viewmodels/search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/screens/root_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/home_page.dart';
import 'package:denemeye_devam/viewmodels/comments_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr', null);

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // --- DEĞİŞİKLİK BURADA BAŞLIYOR ---

  // 1. Supabase client'ı bir değişkene alalım.
  final supabaseClient = Supabase.instance.client;

  // 2. Bu client'ı kullanarak Repository'mizi oluşturalım.
  final categoryRepository = CategoryRepository(supabaseClient);

  // 3. Şimdi her şeyi Provider'lara verelim.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CommentsViewModel()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => AppointmentsViewModel()),

        // 4. DashboardViewModel'i oluştururken, yukarıda yarattığımız
        //    categoryRepository NESNESİNİ içine paslıyoruz.
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(categoryRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    final bool isLoggedIn = session != null;

    return MaterialApp(
      title: 'Salon Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      home: isLoggedIn ? const RootScreen() : const HomePage(),
    );
  }
}