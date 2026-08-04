import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/partner.dart';
import '../../data/services/partner_service.dart';

final partnerServiceProvider = Provider<PartnerService>((ref) {
  throw StateError('PartnerService has not been configured.');
});

final partnerListProvider = FutureProvider<List<Partner>>((ref) async {
  final partnerService = ref.watch(partnerServiceProvider);

  try {
    return await partnerService.fetchPartners();
  } catch (error, stackTrace) {
    debugPrint('Partner request failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    rethrow;
  }
});
