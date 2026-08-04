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
}
