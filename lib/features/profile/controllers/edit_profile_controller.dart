import 'package:flutter/material.dart';
import 'package:rajakumari_scheme/core/api_secrets/api_secrets.dart';
import 'package:rajakumari_scheme/core/controllers/executive_list_controller.dart';
import 'package:rajakumari_scheme/core/controllers/store_list_controller.dart';
import 'package:rajakumari_scheme/core/controllers/zone_list_controller.dart';
import 'package:rajakumari_scheme/core/global_widgets/custom_alert_box.dart';
import 'package:rajakumari_scheme/core/models/executive_model.dart';
import 'package:rajakumari_scheme/core/models/store_model.dart';
import 'package:rajakumari_scheme/core/models/zone_model.dart';
import 'package:rajakumari_scheme/core/services/shared_pref_service.dart';
import 'package:rajakumari_scheme/features/profile/services/edit_profile_service.dart';

class EditProfileController extends ChangeNotifier {
  final EditProfileService _editProfileService = EditProfileService();
  final StoreListController _storeListController = StoreListController();
  final ZoneListController _zoneListController = ZoneListController();
  final ExecutiveListController _executiveListController =
      ExecutiveListController();

  // State variables
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Selected values for dropdowns
  StoreModel? _selectedStore;
  StoreModel? get selectedStore => _selectedStore;

  ZoneModel? _selectedZone;
  ZoneModel? get selectedZone => _selectedZone;

  ExecutiveModel? _selectedExecutive;
  ExecutiveModel? get selectedExecutive => _selectedExecutive;

  // Getter methods for lists
  List<StoreModel> get storeList => _storeListController.storeList;
  List<ZoneModel> get zoneList => _zoneListController.zoneList;
  List<ExecutiveModel> get executiveList =>
      _executiveListController.executiveList;

  // Initialize controller
  Future<void> init() async {
    try {
      await Future.wait([
        _storeListController.fetchStoreList(),
        _zoneListController.fetchZoneList(),
        _executiveListController.fetchExecutiveList(),
      ]);

      // Set initial values from shared preferences
      final userData = SharedPrefService.getUserData();
      if (userData != null) {
        // Set store
        _selectedStore = _storeListController.storeList.firstWhere(
          (store) => store.id == userData['store_id'],
          orElse: () => _storeListController.storeList.first,
        );

        // Set zone
        _selectedZone = _zoneListController.zoneList.firstWhere(
          (zone) => zone.id == userData['zone_id'],
          orElse: () => _zoneListController.zoneList.first,
        );

        // Set executive
        _selectedExecutive = _executiveListController.executiveList.firstWhere(
          (executive) => executive.userId == userData['executive_id'],
          orElse: () => _executiveListController.executiveList.first,
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error initializing edit profile controller: $e');
    }
  }

  // Update selected store
  void setSelectedStore(StoreModel? store) {
    _selectedStore = store;
    notifyListeners();
  }

  // Update selected zone
  void setSelectedZone(ZoneModel? zone) {
    _selectedZone = zone;
    notifyListeners();
  }

  // Update selected executive
  void setSelectedExecutive(ExecutiveModel? executive) {
    _selectedExecutive = executive;
    notifyListeners();
  }

  // Update profile
  Future<bool> updateProfile({
    required String name,
    required String mobileCode,
    required String mobile,
    required String email,
    required String password,
    required String address1,
    required String address2,
    required String district,
    required String pincode,
    required String state,
    required String landmark,
    required String panNo,
    required String panImage,
    required String aadharNo,
    required String aadharImage,
    required String nomineeName,
    required String nomineeRelationship,
    required String nomineeAddress,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = SharedPrefService.getUserId();
      final result = await _editProfileService.updateProfile(
        context: context,
        token: ApiSecrets.token,
        name: name,
        mobileCode: mobileCode,
        mobile: mobile,
        email: email,
        password: password,
        storeId: _selectedStore?.id ?? '',
        executiveId: _selectedExecutive?.userId ?? '',
        address1: address1,
        address2: address2,
        district: district,
        pincode: pincode,
        state: state,
        landmark: landmark,
        zoneId: _selectedZone?.id ?? '',
        panNo: panNo,
        panImage: panImage,
        aadharNo: aadharNo,
        aadharImage: aadharImage,
        nomineeName: nomineeName,
        nomineeRelationship: nomineeRelationship,
        nomineeAddress: nomineeAddress,
        userId: userId,
      );

      if (result) {
        showGlassAlert(
          context,
          'Profile updated successfully',
          AlertStatus.success,
        );
      } else {
        showGlassAlert(
          context,
          'Failed to update profile',
          AlertStatus.warning,
        );
      }

      return result;
    } catch (e) {
      showGlassAlert(
        context,
        'Error updating profile: $e',
        AlertStatus.warning,
      );

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
