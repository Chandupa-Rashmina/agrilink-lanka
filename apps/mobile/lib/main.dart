import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/marketplace/data/services/marketplace_service.dart';
import 'features/marketplace/presentation/providers/marketplace_providers.dart';
import 'features/marketplace/presentation/screens/marketplace_shell.dart';
import 'features/partners/data/services/partner_service.dart';
import 'features/partners/presentation/providers/partner_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const secureStorage = FlutterSecureStorage();
  const tokenStorage = TokenStorage(secureStorage);
  final apiClient = ApiClient(tokenStorage: tokenStorage);

  final authService = AuthService(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  runApp(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(authService),
        partnerServiceProvider.overrideWithValue(PartnerService(apiClient)),
        marketplaceServiceProvider.overrideWithValue(
          MarketplaceService(apiClient),
        ),
      ],
      child: AgriLinkBootstrap(apiClient: apiClient),
    ),
  );
}

class AgriLinkBootstrap extends ConsumerStatefulWidget {
  const AgriLinkBootstrap({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  ConsumerState<AgriLinkBootstrap> createState() => _AgriLinkBootstrapState();
}

class _AgriLinkBootstrapState extends ConsumerState<AgriLinkBootstrap> {
  @override
  void initState() {
    super.initState();
    widget.apiClient.onUnauthorized = () {
      return ref.read(authControllerProvider.notifier).expireSession();
    };
  }

  @override
  Widget build(BuildContext context) => const AgriLinkApp();
}

class AgriLinkApp extends ConsumerWidget {
  const AgriLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'AgriLink Lanka',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: auth.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, _) => const LoginScreen(),
        data: (state) => state.isAuthenticated
            ? const MarketplaceShell()
            : const LoginScreen(),
      ),
    );
  }
}
