import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/category.dart';
import '../models/inquiry.dart';
import '../models/listing.dart';

class MarketplaceService {
  const MarketplaceService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<MarketplaceCategory>> fetchCategories() async {
    final response = await _apiClient.dio.get<dynamic>('/categories');
    final data = _dataList(response.data);

    return data
        .map(
          (item) => MarketplaceCategory.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<List<MarketplaceListing>> fetchListings({
    String? search,
    int? categoryId,
    String? district,
  }) async {
    final response = await _apiClient.dio.get<dynamic>(
      '/listings',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'category_id': ?categoryId,
        if (district != null && district.trim().isNotEmpty)
          'district': district.trim(),
      },
    );

    return _parseListings(response.data);
  }

  Future<List<MarketplaceListing>> fetchMyListings() async {
    final response = await _apiClient.dio.get<dynamic>('/my-listings');
    return _parseListings(response.data);
  }

  Future<List<MarketplaceListing>> fetchFavorites() async {
    final response = await _apiClient.dio.get<dynamic>('/favorites');
    return _parseListings(response.data);
  }

  Future<List<MarketplaceInquiry>> fetchInquiries() async {
    final response = await _apiClient.dio.get<dynamic>('/inquiries');
    final root = response.data;

    if (root is! Map || root['data'] is! Map) {
      throw const FormatException('Invalid inquiry response.');
    }

    final paginator = Map<String, dynamic>.from(root['data'] as Map);
    final data = paginator['data'];

    if (data is! List) {
      throw const FormatException('Invalid inquiry list.');
    }

    return data
        .map(
          (item) => MarketplaceInquiry.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<MarketplaceListing> createListing({
    required int categoryId,
    required String title,
    required double quantity,
    required String unit,
    required double price,
    required String district,
    required bool isNegotiable,
    String? description,
    String? location,
    String? imagePath,
  }) async {
    final form = FormData.fromMap({
      'category_id': categoryId,
      'title': title.trim(),
      'description': _nullable(description),
      'quantity': quantity,
      'unit': unit.trim(),
      'price': price,
      'district': district.trim(),
      'location': _nullable(location),
      'is_negotiable': isNegotiable ? 1 : 0,
      if (imagePath != null)
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
    });

    final response = await _apiClient.dio.post<dynamic>(
      '/listings',
      data: form,
    );

    return _parseListing(response.data);
  }

  Future<void> sendInquiry({
    required int listingId,
    required String message,
  }) async {
    await _apiClient.dio.post<dynamic>(
      '/listings/$listingId/inquiries',
      data: {'message': message.trim()},
    );
  }

  Future<void> addFavorite(int listingId) async {
    await _apiClient.dio.post<dynamic>('/favorites/$listingId');
  }

  Future<void> removeFavorite(int listingId) async {
    await _apiClient.dio.delete<dynamic>('/favorites/$listingId');
  }

  Future<MarketplaceListing> markSold(int listingId) async {
    final response = await _apiClient.dio.post<dynamic>(
      '/listings/$listingId/sold',
    );

    return _parseListing(response.data);
  }

  Future<void> deleteListing(int listingId) async {
    await _apiClient.dio.delete<dynamic>('/listings/$listingId');
  }

  Future<void> updateInquiry({
    required int inquiryId,
    required String status,
  }) async {
    await _apiClient.dio.patch<dynamic>(
      '/inquiries/$inquiryId',
      data: {'status': status},
    );
  }

  List<MarketplaceListing> _parseListings(dynamic responseData) {
    final data = _dataList(responseData);

    return data
        .map(
          (item) => MarketplaceListing.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  MarketplaceListing _parseListing(dynamic responseData) {
    if (responseData is! Map || responseData['data'] is! Map) {
      throw const FormatException('Invalid listing response.');
    }

    return MarketplaceListing.fromJson(
      Map<String, dynamic>.from(responseData['data'] as Map),
    );
  }

  List<dynamic> _dataList(dynamic responseData) {
    if (responseData is! Map || responseData['data'] is! List) {
      throw const FormatException('Invalid list response.');
    }

    return responseData['data'] as List<dynamic>;
  }

  String? _nullable(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
