import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/marketplace_providers.dart';

class InquiriesScreen extends ConsumerWidget {
  const InquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiries = ref.watch(inquiriesProvider);

    return inquiries.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: FilledButton(
          onPressed: () => ref.invalidate(inquiriesProvider),
          child: const Text('Retry'),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No inquiries yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final inquiry = items[index];

            return Card(
              child: ExpansionTile(
                title: Text(inquiry.listingTitle),
                subtitle: Text('${inquiry.buyerName} • ${inquiry.status}'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(inquiry.message),
                  ),
                  if (inquiry.buyerEmail.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(inquiry.buyerEmail),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await ref
                                .read(marketplaceServiceProvider)
                                .updateInquiry(
                                  inquiryId: inquiry.id,
                                  status: 'rejected',
                                );
                            ref.invalidate(inquiriesProvider);
                          },
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            await ref
                                .read(marketplaceServiceProvider)
                                .updateInquiry(
                                  inquiryId: inquiry.id,
                                  status: 'accepted',
                                );
                            ref.invalidate(inquiriesProvider);
                          },
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
