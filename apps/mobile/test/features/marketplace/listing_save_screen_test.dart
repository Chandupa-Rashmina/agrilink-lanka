import 'package:agrilink_mobile/core/network/api_client.dart';
import 'package:agrilink_mobile/core/storage/token_storage.dart';
import 'package:agrilink_mobile/features/marketplace/data/models/listing.dart';
import 'package:agrilink_mobile/features/marketplace/data/services/marketplace_service.dart';
import 'package:agrilink_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:agrilink_mobile/features/marketplace/presentation/screens/create_listing_screen.dart';
import 'package:agrilink_mobile/features/marketplace/presentation/screens/edit_listing_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('create failure shows validation error and resets loading', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const CreateListingScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vegetables').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title *'),
      'Demo crop',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantity *'),
      '10',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Price per unit (LKR) *'),
      '250',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'District *'),
      'Kandy',
    );

    await tester.scrollUntilVisible(
      find.text('Publish Listing'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Publish Listing'));
    await tester.pumpAndSettle();

    expect(find.text('The title has already been taken.'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
    expect(find.text('Publish Listing'), findsOneWidget);
  });

  testWidgets('edit failure stays open, shows error, and resets loading', (
    tester,
  ) async {
    await tester.pumpWidget(_app(EditListingScreen(listing: _listing)));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('The title has already been taken.'), findsOneWidget);
    expect(find.text('Edit Listing'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
    expect(find.text('Save Changes'), findsOneWidget);
  });
}

Widget _app(Widget child) {
  final apiClient = ApiClient(
    tokenStorage: const TokenStorage(FlutterSecureStorage()),
  );
  apiClient.dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path == '/categories') {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'data': [
                  {'id': 4, 'name': 'Vegetables', 'slug': 'vegetables'},
                ],
              },
            ),
          );
          return;
        }

        handler.reject(
          DioException.badResponse(
            statusCode: 422,
            requestOptions: options,
            response: Response<dynamic>(
              requestOptions: options,
              statusCode: 422,
              data: {
                'message': 'The given data was invalid.',
                'errors': {
                  'title': ['The title has already been taken.'],
                },
              },
            ),
          ),
        );
      },
    ),
  );

  return ProviderScope(
    overrides: [
      marketplaceServiceProvider.overrideWithValue(
        MarketplaceService(apiClient),
      ),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

const _listing = MarketplaceListing(
  id: 99,
  title: 'Produce',
  description: 'Description',
  quantity: 10,
  unit: 'kg',
  price: 250,
  isNegotiable: true,
  district: 'Kandy',
  status: 'active',
  categoryId: 4,
  categoryName: 'Vegetables',
  sellerId: 7,
  sellerName: 'Demo Seller',
  images: [],
  location: 'Peradeniya',
  latitude: 7.29,
  longitude: 80.63,
);
