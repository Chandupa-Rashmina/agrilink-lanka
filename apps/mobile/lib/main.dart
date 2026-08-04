import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart' as provider;

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/partners/data/services/partner_service.dart';
import 'features/marketplace/data/services/marketplace_service.dart';
import 'features/partners/presentation/providers/partner_provider.dart';
import 'features/marketplace/presentation/providers/marketplace_providers.dart';
import 'features/marketplace/presentation/screens/marketplace_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const secureStorage = FlutterSecureStorage();
  const tokenStorage = TokenStorage(secureStorage);

  final apiClient = ApiClient(tokenStorage: tokenStorage);

  final authService = AuthService(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  final partnerService = PartnerService(apiClient);
  final marketplaceService = MarketplaceService(apiClient);
  final authProvider = AuthProvider(authService);

  apiClient.onUnauthorized = authProvider.expireSession;

  await authProvider.initialize();

  runApp(
    ProviderScope(
      overrides: [
        partnerServiceProvider.overrideWithValue(partnerService),
        marketplaceServiceProvider.overrideWithValue(marketplaceService),
      ],
      child: provider.MultiProvider(
        providers: [
          provider.Provider<ApiClient>.value(value: apiClient),
          provider.ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
          ),
        ],
        child: const AgriLinkApp(),
      ),
    ),
  );
}

class AgriLinkApp extends StatelessWidget {
  const AgriLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriLink Lanka',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: provider.Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (authProvider.isAuthenticated) {
            return const MarketplaceShell();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
