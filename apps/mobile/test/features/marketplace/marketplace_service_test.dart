import 'dart:io';

import 'package:agrilink_mobile/core/network/api_client.dart';
import 'package:agrilink_mobile/core/storage/token_storage.dart';
import 'package:agrilink_mobile/features/marketplace/data/services/marketplace_service.dart';
import 'package:agrilink_mobile/features/marketplace/presentation/marketplace_error_message.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temporaryDirectory;
  late ApiClient apiClient;
  late MarketplaceService service;
  late List<RequestOptions> requests;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'agrilink-listing-test-',
    );
    apiClient = ApiClient(
      tokenStorage: const TokenStorage(FlutterSecureStorage()),
    );
    requests = [];
    apiClient.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: {'data': _listingJson},
            ),
          );
        },
      ),
    );
    service = MarketplaceService(apiClient);
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  test('create sends PHP-compatible multipart images and boolean', () async {
    final first = await _image(temporaryDirectory, 'first.png');
    final second = await _image(temporaryDirectory, 'second.png');

    final listing = await service.createListing(
      categoryId: 4,
      title: ' Fresh produce ',
      description: ' Demo crop ',
      quantity: 12.5,
      unit: ' kg ',
      price: 350,
      district: ' Kandy ',
      location: ' Peradeniya ',
      latitude: 7.29,
      longitude: 80.63,
      isNegotiable: true,
      imagePaths: [first.path, second.path],
    );

    expect(listing.id, 99);
    expect(requests, hasLength(1));
    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/listings');

    final form = requests.single.data as FormData;
    final fields = Map<String, String>.fromEntries(form.fields);
    expect(fields['is_negotiable'], '1');
    expect(fields['title'], 'Fresh produce');
    expect(fields['latitude'], '7.29');
    expect(form.files.map((entry) => entry.key), ['images[]', 'images[]']);
  });

  test(
    'update uses method spoofing and PHP-compatible multipart values',
    () async {
      final added = await _image(temporaryDirectory, 'added.png');

      final listing = await service.updateListing(
        listingId: 99,
        categoryId: 4,
        title: 'Updated produce',
        description: 'Updated description',
        quantity: 15,
        unit: 'crates',
        price: 275.5,
        district: 'Matale',
        location: 'Dambulla',
        latitude: 7.87,
        longitude: 80.77,
        isNegotiable: false,
        newImagePaths: [added.path],
      );

      expect(listing.id, 99);
      expect(requests, hasLength(1));
      expect(requests.single.method, 'POST');
      expect(requests.single.path, '/listings/99');

      final form = requests.single.data as FormData;
      final fields = Map<String, String>.fromEntries(form.fields);
      expect(fields['_method'], 'PATCH');
      expect(fields['is_negotiable'], '0');
      expect(fields['location'], 'Dambulla');
      expect(form.files.single.key, 'images[]');
    },
  );

  test('validation errors expose the first useful field message', () {
    final options = RequestOptions(path: '/listings');
    final error = DioException.badResponse(
      statusCode: 422,
      requestOptions: options,
      response: Response<dynamic>(
        requestOptions: options,
        statusCode: 422,
        data: {
          'message': 'The given data was invalid.',
          'errors': {
            'images': ['The images field must be an array.'],
          },
        },
      ),
    );

    expect(
      marketplaceErrorMessage(error, fallback: 'Unable to save.'),
      'The images field must be an array.',
    );
  });
}

Future<File> _image(Directory directory, String name) {
  return File('${directory.path}/$name').writeAsBytes([137, 80, 78, 71]);
}

const _listingJson = <String, dynamic>{
  'id': 99,
  'title': 'Produce',
  'description': 'Description',
  'quantity': '10.00',
  'unit': 'kg',
  'price': '250.00',
  'is_negotiable': false,
  'district': 'Kandy',
  'location': 'Peradeniya',
  'latitude': '7.2900000',
  'longitude': '80.6300000',
  'status': 'active',
  'category': {'id': 4, 'name': 'Vegetables', 'slug': 'vegetables'},
  'seller': {'id': 7, 'name': 'Demo Seller'},
  'images': <dynamic>[],
  'created_at': '2026-08-23T00:00:00.000000Z',
};
