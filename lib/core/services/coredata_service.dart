import 'dart:convert';
import 'package:rajakumari_scheme/core/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:rajakumari_scheme/core/api_secrets/api_secrets.dart';
import 'package:rajakumari_scheme/core/models/coredata_model.dart';
class CoreDataService {
  Future<CoreDataResponse> getCoreData() async {
    try {
      final url =
          '${ApiSecrets.baseUrl}/coredata.php?token=${ApiSecrets.token}';

      final response = await http.get(
        Uri.parse(url),
        headers: {'x-app-version': AppConfig.appVersion},
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Always attach HTTP status code for the UI
      jsonResponse['httpStatusCode'] = response.statusCode;

      if (response.statusCode == 200) {
        if (jsonResponse['status'] == false ||
            jsonResponse['status'] == 'false') {
          throw jsonResponse; // Pass error details to UI
        }
        return CoreDataResponse.fromJson(jsonResponse);
      } else {
        throw jsonResponse;
      }
    } catch (e) {
      if (e is Map<String, dynamic>) {
        rethrow; // Already a structured error
      }
      throw {
        'message': e.toString(),
        'httpStatusCode': 500,
      };
    }
  }
}
