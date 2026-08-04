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

  Future<Partner> fetchPartner(int id) async {
    final response = await _apiClient.dio.get<dynamic>('/partners/$id');

    return _partnerFromResponse(
      response.data,
      errorMessage: 'Invalid partner-detail response.',
    );
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
      data: _payload(
        type: type,
        name: name,
        phone: phone,
        email: email,
        address: address,
        district: district,
        isActive: true,
      ),
    );

    return _partnerFromResponse(
      response.data,
      errorMessage: 'Invalid create-partner response.',
    );
  }

  Future<Partner> updatePartner({
    required int id,
    required String type,
    required String name,
    required bool isActive,
    String? phone,
    String? email,
    String? address,
    String? district,
  }) async {
    final response = await _apiClient.dio.put<dynamic>(
      '/partners/$id',
      data: _payload(
        type: type,
        name: name,
        phone: phone,
        email: email,
        address: address,
        district: district,
        isActive: isActive,
      ),
    );

    return _partnerFromResponse(
      response.data,
      errorMessage: 'Invalid update-partner response.',
    );
  }

  Future<void> deletePartner(int id) async {
    await _apiClient.dio.delete<void>('/partners/$id');
  }

  Partner _partnerFromResponse(
    dynamic responseData, {
    required String errorMessage,
  }) {
    if (responseData is! Map || responseData['data'] is! Map) {
      throw FormatException(errorMessage);
    }

    return Partner.fromJson(
      Map<String, dynamic>.from(responseData['data'] as Map),
    );
  }

  Map<String, dynamic> _payload({
    required String type,
    required String name,
    required bool isActive,
    String? phone,
    String? email,
    String? address,
    String? district,
  }) {
    return {
      'type': type,
      'name': name.trim(),
      'phone': _nullable(phone),
      'email': _nullable(email),
      'address': _nullable(address),
      'district': _nullable(district),
      'is_active': isActive,
    };
  }

  String? _nullable(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}
