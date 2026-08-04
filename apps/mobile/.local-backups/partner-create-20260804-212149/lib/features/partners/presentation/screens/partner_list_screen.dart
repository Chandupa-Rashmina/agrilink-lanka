import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import '../../../auth/presentation/auth_provider.dart';
import '../providers/partner_provider.dart';

class PartnerListScreen extends ConsumerWidget {
  const PartnerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partnerList = ref.watch(partnerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partners'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(partnerListProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: partnerList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _PartnerErrorView(
          message: _errorMessage(error),
          onRetry: () {
            ref.invalidate(partnerListProvider);
          },
        ),
        data: (partners) {
          if (partners.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(partnerListProvider);
                await ref.read(partnerListProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Icon(Icons.people_outline, size: 64),
                  SizedBox(height: 16),
                  Center(child: Text('No farmers or suppliers found.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(partnerListProvider);
              await ref.read(partnerListProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: partners.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final partner = partners[index];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        partner.type == 'farmer'
                            ? Icons.agriculture
                            : Icons.local_shipping,
                      ),
                    ),
                    title: Text(partner.name),
                    subtitle: Text(
                      [
                        partner.type,
                        if (partner.district != null) partner.district!,
                        if (partner.phone != null) partner.phone!,
                      ].join(' • '),
                    ),
                    trailing: partner.isActive
                        ? const Icon(Icons.check_circle_outline)
                        : const Icon(Icons.block),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  static String _errorMessage(Object error) {
    final message = error.toString();

    if (message.contains('401')) {
      return 'Your login has expired. Please sign in again.';
    }

    return 'Unable to load partners. Check the server connection.';
  }
}

class _PartnerErrorView extends StatelessWidget {
  const _PartnerErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
