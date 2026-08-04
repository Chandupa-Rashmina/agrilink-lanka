import '../../../../core/network/api_client.dart';
import '../models/partner.dart';

class PartnerService {
  const PartnerService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Partner>> fetchPartners() async {
    final response = await _apiClient.dio.get<dynamic>('/partners');
    final responseData = response.data;

    if (responseData is! Map) {
      throw FormatException(
        'Partner response must be an object. Received: ${responseData.runtimeType}',
      );
    }

    final data = responseData['data'];

    if (data is! List) {
      throw FormatException(
        'Partner data must be a list. Received: ${data.runtimeType}',
      );
    }

    return data.map((item) {
      if (item is! Map) {
        throw FormatException(
          'Partner item must be an object. Received: ${item.runtimeType}',
        );
      }

      return Partner.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<Partner> createPartner({
    required String type,
    required String name,
    String? phone,
    String? email,
    String? address,
    String? district,
  }) async {
    final response = await _apiClient.dio.post<dynamic>(
      '/partners',
      data: {
        'type': type,
        'name': name,
        'phone': _nullable(phone),
        'email': _nullable(email),
        'address': _nullable(address),
        'district': _nullable(district),
        'is_active': true,
      },
    );

    final responseData = response.data;

    if (responseData is! Map || responseData['data'] is! Map) {
      throw const FormatException('Invalid create-partner response.');
    }

    return Partner.fromJson(
      Map<String, dynamic>.from(responseData['data'] as Map),
    );
  }

  String? _nullable(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}
