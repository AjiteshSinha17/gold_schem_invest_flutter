// Hive-based replacement of SharedPrefService
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SharedPrefService {
  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('Rajakumari');

    try {
      final storedData = _box.get(_userData);
      if (storedData != null && storedData is String) {
        json.decode(storedData); // validate JSON
      }
    } catch (e) {
      await _box.clear();
    }
  }

  static const String _userId = 'user_id';
  static const String _userName = 'user_name';
  static const String _userEmail = 'user_email';
  static const String _userMobile = 'user_mobile';
  static const String _userMobileCode = 'user_mobile_code';
  static const String _userLevel = 'user_level';
  static const String _userStatus = 'user_status';
  static const String _userProfileImage = 'user_profile_image';
  static const String _userData = 'user_data';
  static const String _userloggedstatus = 'user_logged_status';

  static const String _address1 = 'address_1';
  static const String _address2 = 'address_2';
  static const String _landmark = 'landmark';
  static const String _state = 'state';
  static const String _district = 'district';
  static const String _pincode = 'pincode';
  static const String _panNo = 'pan_no';
  static const String _panImage = 'pan_image';
  static const String _aadharNo = 'aadhar_no';
  static const String _aadharImage = 'aadhar_image';
  static const String _nomineeName = 'nominee_name';
  static const String _nomineeRelation = 'nominee_relationship';
  static const String _nomineeAddress = 'nominee_address';

  static bool getUserLoggedStatus() {
    final val = _box.get(_userloggedstatus, defaultValue: false);
    return val;
  }

  static String getUserId() => _box.get(_userId)?.toString() ?? '';
  static String getUserName() => _box.get(_userName)?.toString() ?? '';
  static String getUserEmail() => _box.get(_userEmail)?.toString() ?? '';
  static String getUserMobile() => _box.get(_userMobile)?.toString() ?? '';
  static String getUserMobileCode() =>
      _box.get(_userMobileCode)?.toString() ?? '';
  static String getUserLevel() => _box.get(_userLevel)?.toString() ?? '';
  static String getUserStatus() => _box.get(_userStatus)?.toString() ?? '';
  static String getUserProfileImage() =>
      _box.get(_userProfileImage)?.toString() ?? '';

  static String getAddress1() => _box.get(_address1)?.toString() ?? '';
  static String getAddress2() => _box.get(_address2)?.toString() ?? '';
  static String getLandmark() => _box.get(_landmark)?.toString() ?? '';
  static String getState() => _box.get(_state)?.toString() ?? '';
  static String getDistrict() => _box.get(_district)?.toString() ?? '';
  static String getPincode() => _box.get(_pincode)?.toString() ?? '';
  static String getPanNo() => _box.get(_panNo)?.toString() ?? '';
  static String getPanImage() => _box.get(_panImage)?.toString() ?? '';
  static String getAadharNo() => _box.get(_aadharNo)?.toString() ?? '';
  static String getAadharImage() => _box.get(_aadharImage)?.toString() ?? '';
  static String getNomineeName() => _box.get(_nomineeName)?.toString() ?? '';
  static String getNomineeRelation() =>
      _box.get(_nomineeRelation)?.toString() ?? '';
  static String getNomineeAddress() =>
      _box.get(_nomineeAddress)?.toString() ?? '';

  static Map<String, dynamic>? getUserData() {
    try {
      final String? data = _box.get(_userData);
      if (data == null || data.isEmpty) return null;
      return json.decode(data);
    } catch (e) {
      _box.delete(_userData);
      return null;
    }
  }

  static Future<bool> setUserLoggedStatus(bool value) async =>
      await _box.put(_userloggedstatus, value).then((_) => true);
  static Future<bool> setUserId(String value) async =>
      await _box.put(_userId, value).then((_) => true);
  static Future<bool> setUserName(String value) async =>
      await _box.put(_userName, value).then((_) => true);
  static Future<bool> setUserEmail(String value) async =>
      await _box.put(_userEmail, value).then((_) => true);
  static Future<bool> setUserMobile(String value) async =>
      await _box.put(_userMobile, value).then((_) => true);
  static Future<bool> setUserMobileCode(String value) async =>
      await _box.put(_userMobileCode, value).then((_) => true);
  static Future<bool> setUserLevel(String value) async =>
      await _box.put(_userLevel, value).then((_) => true);
  static Future<bool> setUserStatus(String value) async =>
      await _box.put(_userStatus, value).then((_) => true);
  static Future<bool> setUserProfileImage(String value) async =>
      await _box.put(_userProfileImage, value).then((_) => true);

  static Future<bool> setAddress1(String value) async =>
      await _box.put(_address1, value).then((_) => true);
  static Future<bool> setAddress2(String value) async =>
      await _box.put(_address2, value).then((_) => true);
  static Future<bool> setLandmark(String value) async =>
      await _box.put(_landmark, value).then((_) => true);
  static Future<bool> setState(String value) async =>
      await _box.put(_state, value).then((_) => true);
  static Future<bool> setDistrict(String value) async =>
      await _box.put(_district, value).then((_) => true);
  static Future<bool> setPincode(String value) async =>
      await _box.put(_pincode, value).then((_) => true);
  static Future<bool> setPanNo(String value) async =>
      await _box.put(_panNo, value).then((_) => true);
  static Future<bool> setPanImage(String value) async =>
      await _box.put(_panImage, value).then((_) => true);
  static Future<bool> setAadharNo(String value) async =>
      await _box.put(_aadharNo, value).then((_) => true);
  static Future<bool> setAadharImage(String value) async =>
      await _box.put(_aadharImage, value).then((_) => true);
  static Future<bool> setNomineeName(String value) async =>
      await _box.put(_nomineeName, value).then((_) => true);
  static Future<bool> setNomineeRelation(String value) async =>
      await _box.put(_nomineeRelation, value).then((_) => true);
  static Future<bool> setNomineeAddress(String value) async =>
      await _box.put(_nomineeAddress, value).then((_) => true);
  static Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = json.encode(userData);

      final Map<String, dynamic> flatData = {
        _userId: userData['user_id'] ?? '',
        _userName: userData['name'] ?? '',
        _userEmail: userData['email'] ?? '',
        _userMobile: userData['mobile'] ?? '',
        _userMobileCode: userData['mobile_code'] ?? '',
        _userLevel: userData['user_level'] ?? '',
        _userStatus: userData['status'] ?? '',
        _userProfileImage: userData['profile_image'] ?? '',
        _userData: jsonString,
      };
      // Optional fields
      if (userData['address_1'] != null) {
        flatData[_address1] = userData['address_1'];
      }
      if (userData['address_2'] != null) {
        flatData[_address2] = userData['address_2'];
      }
      if (userData['landmark'] != null) {
        flatData[_landmark] = userData['landmark'];
      }
      if (userData['state'] != null) flatData[_state] = userData['state'];
      if (userData['district'] != null) {
        flatData[_district] = userData['district'];
      }
      if (userData['pincode'] != null) flatData[_pincode] = userData['pincode'];
      if (userData['pan_no'] != null) flatData[_panNo] = userData['pan_no'];
      if (userData['pan_image'] != null) {
        flatData[_panImage] = userData['pan_image'];
      }
      if (userData['aadhar_no'] != null) {
        flatData[_aadharNo] = userData['aadhar_no'];
      }
      if (userData['aadhar_image'] != null) {
        flatData[_aadharImage] = userData['aadhar_image'];
      }
      if (userData['nominee_name'] != null) {
        flatData[_nomineeName] = userData['nominee_name'];
      }
      if (userData['nominee_relationship'] != null) {
        flatData[_nomineeRelation] = userData['nominee_relationship'];
      }
      if (userData['nominee_address'] != null) {
        flatData[_nomineeAddress] = userData['nominee_address'];
      }

      await _box.putAll(flatData);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateUserProfile({
    String? userName,
    String? userEmail,
    String? userMobile,
    String? userMobileCode,
    String? profileImage,
  }) async {
    try {
      final userData = getUserData();
      if (userData == null) return false;

      if (userName != null) {
        userData['name'] = userName;
        await setUserName(userName);
      }
      if (userEmail != null) {
        userData['email'] = userEmail;
        await setUserEmail(userEmail);
      }
      if (userMobile != null) {
        userData['mobile'] = userMobile;
        await setUserMobile(userMobile);
      }
      if (userMobileCode != null) {
        userData['mobile_code'] = userMobileCode;
        await setUserMobileCode(userMobileCode);
      }
      if (profileImage != null) {
        userData['profile_image'] = profileImage;
        await setUserProfileImage(profileImage);
      }

      return await _box.put(_userData, json.encode(userData)).then((_) => true);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> clearUserData() async {
    try {
      await _box.delete(_userId);
      await _box.delete(_userName);
      await _box.delete(_userEmail);
      await _box.delete(_userMobile);
      await _box.delete(_userMobileCode);
      await _box.delete(_userLevel);
      await _box.delete(_userStatus);
      await _box.delete(_userProfileImage);
      await _box.delete(_userData);

      await _box.delete(_address1);
      await _box.delete(_address2);
      await _box.delete(_landmark);
      await _box.delete(_state);
      await _box.delete(_district);
      await _box.delete(_pincode);
      await _box.delete(_panNo);
      await _box.delete(_panImage);
      await _box.delete(_aadharNo);
      await _box.delete(_aadharImage);
      await _box.delete(_nomineeName);
      await _box.delete(_nomineeRelation);
      await _box.delete(_nomineeAddress);

      return true;
    } catch (e) {
      return false;
    }
  }


}
