import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rajakumari_scheme/core/api_secrets/api_secrets.dart';
import 'package:rajakumari_scheme/core/global_widgets/custom_alert_box.dart';
import 'package:rajakumari_scheme/core/services/shared_pref_service.dart';
import 'package:rajakumari_scheme/core/config/app_config.dart';

class RegisterService {
  Future<Map<String, dynamic>?> register({
    required String name,
    required String mobileCode,
    required String mobile,
    required String email,
    required String password,
    required String storeId,
    required String executiveId,
    required String address1,
    String? address2,
    required String district,
    required String pincode,
    required String state,
    String? landmark,
    required String zoneId,
    String? panNo,
    String? panImage,
    String? aadharNo,
    String? aadharImage,
    required String nomineeName,
    required String nomineeRelationship,
    required String nomineeAddress,
    required BuildContext context,
  }) async {
    try {
      final url =
          '${ApiSecrets.baseUrl}/register.php?token=${ApiSecrets.token}'
          '&name=$name'
          '&mobile_code=$mobileCode'
          '&mobile=$mobile'
          '&email=$email'
          '&password=$password'
          '&store_id=$storeId'
          '&executive_id=$executiveId'
          '&address_1=$address1'
          '&address_2=${address2 ?? ''}'
          '&district=$district'
          '&pincode=$pincode'
          '&state=$state'
          '&landmark=${landmark ?? ''}'
          '&zone_id=$zoneId'
          '&pan_no=${panNo ?? ''}'
          '&pan_image=${panImage ?? ''}'
          '&aadhar_no=${aadharNo ?? ''}'
          '&aadhar_image=${aadharImage ?? ''}'
          '&nominee_name=$nomineeName'
          '&nominee_relationship=$nomineeRelationship'
          '&nominee_address=$nomineeAddress';

      final response = await http.get(
        Uri.parse(url),
        headers: {'x-app-version': AppConfig.appVersion},
      );
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        final status = jsonResponse['status'];
        final data = jsonResponse['data'];

        if (status == 'true' && data != null) {
          if (data is List && data.isNotEmpty) {
            final userData = data[0];
            final saved = await SharedPrefService.saveUserData(userData);

            if (!saved && context.mounted) {
              showGlassAlert(
                context,
                'Failed to save user data',
                AlertStatus.warning,
              );
            }

            return {
              'success': true,
              'data': userData,
              'message': 'User registered successfully',
            };
          }
        } else {
          throw jsonResponse['data'];
        }
      } else {
        throw jsonResponse['data'];
      }
    } catch (e) {
      throw e.toString();
    }
    return null;
  }
}
