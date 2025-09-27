import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rajakumari_scheme/core/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:rajakumari_scheme/core/api_secrets/api_secrets.dart';
import 'package:rajakumari_scheme/features/home/models/store_model.dart';

class StoreListService {
  /// Fetches store list data from the API
  ///
  /// Returns a [StoreResponse] object containing the store list data
  /// Throws an exception if the API call fails
  Future<StoreResponse> getStoreList(BuildContext context) async {
    try {
      final url =
          '${ApiSecrets.baseUrl}/list-store.php?token=${ApiSecrets.token}';

      final response = await http.get(
        Uri.parse(url),
        headers: {'x-app-version': AppConfig.appVersion},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        return StoreResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load store list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load store list: $e');
    }
  }

  /// Get the full image URL for a store image
  String getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    final path = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '${ApiSecrets.imageBaseUrl}$path';
  }
}
