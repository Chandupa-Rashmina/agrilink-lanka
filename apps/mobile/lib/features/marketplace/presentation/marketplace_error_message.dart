import 'package:dio/dio.dart';

String marketplaceErrorMessage(Object error, {required String fallback}) {
  if (error is FormatException && error.message.isNotEmpty) {
    return error.message;
  }

  if (error is DioException) {
    final data = error.response?.data;

    if (data is Map) {
      final errors = data['errors'];

      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
        }
      }

      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
  }

  return fallback;
}
