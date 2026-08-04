import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/inquiry.dart';
import '../providers/marketplace_providers.dart';

class InquiriesScreen extends ConsumerWidget {
  const InquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Buying'),
              Tab(text: 'Selling'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _InquiryList(
                  inquiries: ref.watch(buyerInquiriesProvider),
                  sellerActions: false,
                ),
                _InquiryList(
                  inquiries: ref.watch(sellerInquiriesProvider),
                  sellerActions: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InquiryList extends ConsumerWidget {
  const _InquiryList({required this.inquiries, required this.sellerActions});

  final AsyncValue<List<MarketplaceInquiry>> inquiries;
  final bool sellerActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return inquiries.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: FilledButton(
          onPressed: () {
            ref.invalidate(
              sellerActions ? sellerInquiriesProvider : buyerInquiriesProvider,
            );
          },
          child: const Text('Retry'),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Text(
              sellerActions
                  ? 'No buyer inquiries yet.'
                  : 'You have not contacted any sellers.',
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final provider = sellerActions
                ? sellerInquiriesProvider
                : buyerInquiriesProvider;
            ref.invalidate(provider);
            await ref.read(provider.future);
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final inquiry = items[index];
              final contactName = sellerActions
                  ? inquiry.buyerName
                  : inquiry.sellerName;
              final contactPhone = sellerActions
                  ? inquiry.buyerPhone
                  : inquiry.sellerPhone;
              final contactEmail = sellerActions
                  ? inquiry.buyerEmail
                  : inquiry.sellerEmail;

              return Card(
                child: ExpansionTile(
                  title: Text(inquiry.listingTitle),
                  subtitle: Text('$contactName • ${inquiry.status}'),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(inquiry.message),
                    ),
                    const SizedBox(height: 8),
                    if (contactPhone.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Phone: $contactPhone'),
                      ),
                    if (contactEmail.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Email: $contactEmail'),
                      ),
                    if (sellerActions && inquiry.status == 'pending') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _update(ref, inquiry.id, 'rejected'),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: () =>
                                  _update(ref, inquiry.id, 'accepted'),
                              child: const Text('Accept'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _update(WidgetRef ref, int inquiryId, String status) async {
    await ref
        .read(marketplaceServiceProvider)
        .updateInquiry(inquiryId: inquiryId, status: status);
    ref.invalidate(sellerInquiriesProvider);
    ref.invalidate(buyerInquiriesProvider);
  }
}
