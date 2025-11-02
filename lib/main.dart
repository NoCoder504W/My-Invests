import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// Models
import 'models/portfolio.dart';
import 'models/institution.dart';
import 'models/account.dart';
import 'models/asset.dart';
import 'models/account_type.dart';

// Providers
import 'providers/portfolio_provider.dart';
import 'providers/settings_provider.dart';

// Screens
import 'screens/dashboard_screen.dart';
import 'screens/welcome_screen.dart';

// Utils
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialiser Hive
  await Hive.initFlutter();

  // 2. Enregistrer les Adapters générés
  Hive.registerAdapter(PortfolioAdapter());
  Hive.registerAdapter(InstitutionAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(AssetAdapter());
  Hive.registerAdapter(AccountTypeAdapter());

  // 3. Ouvrir les boîtes de stockage
  await Hive.openBox<Portfolio>('portfolio_box');
  // await Hive.openBox('settings_box'); // Pour les futurs paramètres

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<PortfolioProvider>(
        builder: (context, portfolioProvider, child) {
          return MaterialApp(
            title: 'Portefeuille',
            theme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
            home: portfolioProvider.portfolio != null
                ? const DashboardScreen()
                : const WelcomeScreen(),
          );
        },
      ),
    );
  }
}
