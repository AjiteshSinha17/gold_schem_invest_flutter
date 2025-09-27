import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rajakumari_scheme/core/api_secrets/api_secrets.dart';
import 'package:rajakumari_scheme/core/controllers/executive_list_controller.dart';
import 'package:rajakumari_scheme/core/controllers/store_list_controller.dart';
import 'package:rajakumari_scheme/core/controllers/zone_list_controller.dart';
import 'package:rajakumari_scheme/core/global_widgets/custom_alert_box.dart';
import 'package:rajakumari_scheme/core/models/executive_model.dart';
import 'package:rajakumari_scheme/core/models/store_model.dart';
import 'package:rajakumari_scheme/core/models/zone_model.dart';
import 'package:rajakumari_scheme/core/services/auth_state_service.dart';
import 'package:rajakumari_scheme/core/services/shared_pref_service.dart';

import 'package:rajakumari_scheme/features/authentication/services/register_service.dart';
import 'package:rajakumari_scheme/features/authentication/view/widgets/text_field_widget.dart';

import 'package:rajakumari_scheme/features/home/view/pages/main_scaffold.dart';

class NomineeRelationshipOption {
  final String value;
  final String displayText;

  const NomineeRelationshipOption({
    required this.value,
    required this.displayText,
  });
}

class RegisterPage extends StatefulWidget {
  final String countryCode;
  final String mobile;
  const RegisterPage({
    super.key,
    required this.countryCode,
    required this.mobile,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _storeListController = StoreListController();
  final _zoneListController = ZoneListController();
  final _executiveListController = ExecutiveListController();
  StoreModel? _selectedStore;
  ZoneModel? _selectedZone;
  ExecutiveModel? _selectedExecutive;
  late final AuthStateService _authStateService;
  // Controllers for all form fields
  final TextEditingController _nameController = TextEditingController();
  late final String _selectedCountryCode;
  final List<String> _countryCodes = ['91', '1', '44', '61', '81', '86'];
  late final TextEditingController _mobileController;
  bool _isLoggedIn = false;
  bool _navigated = false;
  @override
  void initState() {
    super.initState();

    _authStateService = context.read<AuthStateService>();
    _authStateService.addListener(_onAuthStateChanged);

    _selectedCountryCode = widget.countryCode;
    _mobileController = TextEditingController(text: widget.mobile);

    _loadData();
  }

  void _onAuthStateChanged() {
    setState(() {
      _isLoggedIn = context.read<AuthStateService>().isLoggedIn;
    });
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _storeListController.fetchStoreList(),
        _zoneListController.fetchZoneList(),
        _executiveListController.fetchExecutiveList(),
      ]);

      setState(() {}); // Trigger rebuild to show data in dropdowns
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _storeIdController = TextEditingController();
  final TextEditingController _executiveIdController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _zoneIdController = TextEditingController();
  final TextEditingController _panNoController = TextEditingController();
  final TextEditingController _aadharNoController = TextEditingController();
  final TextEditingController _nomineeNameController = TextEditingController();
  final TextEditingController _nomineeRelationshipController =
      TextEditingController();
  final TextEditingController _nomineeAddressController =
      TextEditingController();

  // For file uploads
  File? _panImageFile;
  String? _panImagePath;
  File? _aadharImageFile;
  String? _aadharImagePath;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Track form progress
  int _currentStep = 0;
  final List<String> _stepTitles = [
    'Personal',
    'Address',
    'Documents',
    'Nominee',
  ];

  final ImagePicker _imagePicker = ImagePicker();

  final List<NomineeRelationshipOption> _nomineeRelationshipOptions = const [
    NomineeRelationshipOption(
      value: 'parent',
      displayText: 'Parent (Father or Mother)',
    ),
    NomineeRelationshipOption(
      value: 'spouse',
      displayText: 'Spouse (Husband or Wife)',
    ),
    NomineeRelationshipOption(
      value: 'child',
      displayText: 'Child (Son or Daughter)',
    ),
    NomineeRelationshipOption(
      value: 'sibling',
      displayText: 'Sibling (Brother or Sister)',
    ),
    NomineeRelationshipOption(value: 'guardian', displayText: 'Legal Guardian'),
    NomineeRelationshipOption(value: 'other', displayText: 'Other'),
  ];
  NomineeRelationshipOption? _selectedNomineeRelationship;
  @override
  void dispose() {
    // Dispose all controllers
    _authStateService.removeListener(_onAuthStateChanged);
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _storeIdController.dispose();
    _executiveIdController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    _landmarkController.dispose();
    _zoneIdController.dispose();
    _panNoController.dispose();
    _aadharNoController.dispose();
    _nomineeNameController.dispose();
    _nomineeRelationshipController.dispose();
    _nomineeAddressController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await RegisterService().register(
        context: context,
        name: _nameController.text,
        mobileCode: _selectedCountryCode,
        mobile: _mobileController.text,
        email: _emailController.text,
        password: _passwordController.text,
        storeId: _selectedStore?.id ?? '',
        executiveId: _selectedExecutive?.userId ?? '',
        address1: _address1Controller.text,
        address2: _address2Controller.text,
        district: _districtController.text,
        pincode: _pincodeController.text,
        state: _stateController.text,
        landmark: _landmarkController.text,
        zoneId: _selectedZone?.id ?? '',
        panNo: _panNoController.text,
        panImage: _panImagePath,
        aadharNo: _aadharNoController.text,
        aadharImage: _aadharImagePath,
        nomineeName: _nomineeNameController.text,
        nomineeRelationship: _nomineeRelationshipController.text,
        nomineeAddress: _nomineeAddressController.text,
      );

      if (response?['success'] == true) {
        if (!mounted) return;

        showGlassAlert(
          context,
          response?['message'] ?? 'Registered!',
          AlertStatus.success,
        );
        await Future.delayed(const Duration(seconds: 1), () async {
          if (response != null) {
            await SharedPrefService.setUserLoggedStatus(true);
            await SharedPrefService.setUserId(
              response['data']['user_id'].toString(),
            );
            await SharedPrefService.setUserName(
              response['data']['user_id'].toString(),
            );
            await SharedPrefService.setUserProfileImage(
              (response['profile_image'] ?? '').toString(),
            );
            await SharedPrefService.setUserLoggedStatus(true);

            await _authStateService.refreshAuthState();
          }
        });
      } else {
        showGlassAlert(
          context,
          response?['message'] ?? 'Registration failed',
          AlertStatus.error,
        );
      }
    } catch (e) {
      showGlassAlert(context, e.toString(), AlertStatus.error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoggedIn = _authStateService.isLoggedIn;
        });
      }
    }
  }

  // Method to handle next step
  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  // Method to handle previous step
  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  // Method to show image picker options
  void _showImagePickerOptions(BuildContext context, bool isPanCard) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select ${isPanCard ? 'PAN Card' : 'Aadhar Card'} Image',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.black54,
                ),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isPanCard);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.black54,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isPanCard);
                },
              ),
              if ((isPanCard && _panImageFile != null) ||
                  (!isPanCard && _aadharImageFile != null))
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      if (isPanCard) {
                        _panImageFile = null;
                        _panImagePath = null;
                      } else {
                        _aadharImageFile = null;
                        _aadharImagePath = null;
                      }
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Method to pick image from camera or gallery
  Future<void> _pickImage(ImageSource source, bool isPanCard) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70, // Reduce image quality to save space
      );

      if (pickedFile != null) {
        setState(() {
          if (isPanCard) {
            _panImageFile = File(pickedFile.path);
            final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
            final imageName = '$timestamp${pickedFile.name}';
            _panImagePath = imageName;
            uploadImage(_panImageFile!, _panImagePath!);
          } else {
            _aadharImageFile = File(pickedFile.path);
            final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
            final imageName = '$timestamp${pickedFile.name}';
            _aadharImagePath = imageName;
            uploadImage(_aadharImageFile!, _aadharImagePath!);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        showGlassAlert(context, 'Error picking image', AlertStatus.error);
      }
    }
  }

  Future<void> uploadImage(File imageFile, String imageUrl) async {
    var url = Uri.parse('${ApiSecrets.baseUrl}/save-document.php');

    try {
      var request = http.MultipartRequest('POST', url);
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: imageUrl,
      );
      request.files.add(multipartFile);

      var response = await request.send();
    } catch (e) {
      log("Error uploading image: $e");
    }
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final smallScreen = constraints.maxWidth < 360;
          final stepSize = smallScreen ? 24.0 : 32.0;
          final fontSize = smallScreen ? 11.0 : 13.0;
          final labelSize = smallScreen ? 8.0 : 10.0;
          final horizontalSpacing = smallScreen ? 2.0 : 4.0;

          return Column(
            children: [
              // Step circles with connecting lines
              Row(
                children: List.generate(_stepTitles.length * 2 - 1, (index) {
                  // If even index, render circle, otherwise render line
                  if (index.isEven) {
                    final stepIndex = index ~/ 2;
                    final isActive = stepIndex <= _currentStep;
                    final isCurrent = stepIndex == _currentStep;

                    return Container(
                      width: stepSize,
                      height: stepSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? Colors.amber : Colors.white,
                        border: Border.all(
                          color:
                              isActive
                                  ? Colors.amber.shade700
                                  : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        boxShadow:
                            isCurrent
                                ? [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            color:
                                isActive ? Colors.white : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    );
                  } else {
                    // This is a connecting line
                    final lineIndex = index ~/ 2;
                    final isActive = lineIndex < _currentStep;

                    return Expanded(
                      child: Container(
                        height: 1.5,
                        color: isActive ? Colors.amber : Colors.grey.shade300,
                      ),
                    );
                  }
                }),
              ),

              const SizedBox(height: 8),

              // Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_stepTitles.length, (index) {
                  final isCurrent = index == _currentStep;
                  final isActive = index <= _currentStep;

                  return Container(
                    alignment:
                        index == 0
                            ? Alignment.centerLeft
                            : index == _stepTitles.length - 1
                            ? Alignment.centerRight
                            : Alignment.center,

                    child: Text(
                      _stepTitles[index],
                      style: TextStyle(
                        fontSize: labelSize,
                        color:
                            isCurrent
                                ? Colors.amber.shade900
                                : isActive
                                ? Colors.grey.shade700
                                : Colors.grey.shade500,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: _nameController,
          ),

          CustomTextField(
            label: 'Mobile Number',
            controller: _mobileController,
            enabled: false,
          ),

          CustomTextField(
            label: 'Email',
            hint: 'Enter your email address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),

          CustomTextField(
            label: 'Password',
            hint: 'Enter password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.grey.shade600,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          // Store Dropdown
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 8),
                  child: Text(
                    'Select Store',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF444444),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<StoreModel>(
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      hint: const Text('Select a store'),
                      value: _selectedStore,
                      items:
                          _storeListController.storeList.map((
                            StoreModel store,
                          ) {
                            return DropdownMenuItem<StoreModel>(
                              value: store,
                              child: Text(store.storeName),
                            );
                          }).toList(),
                      onChanged: (StoreModel? newValue) {
                        setState(() {
                          _selectedStore = newValue;
                          _storeIdController.text = newValue?.id ?? '';
                          // Reset executive selection when store changes
                          _selectedExecutive = null;
                          _executiveIdController.text = '';
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Executive Dropdown
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 8),
                  child: Text(
                    'Select Executive',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF444444),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ExecutiveModel>(
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      hint: const Text('Select an executive'),
                      value: _selectedExecutive,
                      items:
                          _executiveListController.executiveList.map((
                            ExecutiveModel executive,
                          ) {
                            return DropdownMenuItem<ExecutiveModel>(
                              value: executive,
                              child: Text(executive.name),
                            );
                          }).toList(),
                      onChanged: (ExecutiveModel? newValue) {
                        setState(() {
                          _selectedExecutive = newValue;
                          _executiveIdController.text = newValue?.userId ?? '';
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Address Line 1',
            hint: 'Enter your address',
            controller: _address1Controller,
          ),

          CustomTextField(
            label: 'Address Line 2',
            hint: 'Enter additional address details',
            controller: _address2Controller,
            isMandatory: false,
          ),

          CustomTextField(label: 'District', controller: _districtController),

          CustomTextField(
            label: 'Pincode',
            controller: _pincodeController,
            keyboardType: TextInputType.number,
          ),

          CustomTextField(label: 'State', controller: _stateController),

          CustomTextField(
            label: 'Landmark',
            controller: _landmarkController,
            isMandatory: false,
          ),

          // Zone Dropdown
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 8),
                  child: Text(
                    'Select Zone',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF444444),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ZoneModel>(
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      hint: const Text('Select a zone'),
                      value: _selectedZone,
                      items:
                          _zoneListController.zoneList.map((ZoneModel zone) {
                            return DropdownMenuItem<ZoneModel>(
                              value: zone,
                              child: Text(zone.name),
                            );
                          }).toList(),
                      onChanged: (ZoneModel? newValue) {
                        setState(() {
                          _selectedZone = newValue;
                          _zoneIdController.text = newValue?.id ?? '';
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          CustomTextField(
            label: 'PAN Number',
            hint: 'Enter your PAN number',
            controller: _panNoController,
            isMandatory: false,
          ),

          // PAN Image Upload
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 8),
                  child: Text(
                    'PAN Card Image',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF444444),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showImagePickerOptions(context, true),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child:
                        _panImageFile != null
                            ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _panImageFile!,
                                    width: double.infinity,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      color: Colors.black54,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.file_upload_outlined,
                                    size: 28,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to upload PAN Card image',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),

          CustomTextField(
            label: 'Aadhar Number',
            hint: 'Enter your Aadhar number',
            controller: _aadharNoController,
            keyboardType: TextInputType.number,
            isMandatory: false,
          ),

          // Aadhar Image Upload
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 8),
                  child: Text(
                    'Aadhar Card Image',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF444444),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showImagePickerOptions(context, false),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child:
                        _aadharImageFile != null
                            ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _aadharImageFile!,
                                    width: double.infinity,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      color: Colors.black54,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.file_upload_outlined,
                                    size: 28,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to upload Aadhar Card image',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNomineeStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Nominee Name',
            hint: 'Enter nominee name',
            controller: _nomineeNameController,
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 8),
                  child: Text(
                    'Nominee Relationship',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF444444),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<NomineeRelationshipOption>(
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      hint: const Text('Select relationship'),
                      value: _selectedNomineeRelationship,
                      items:
                          _nomineeRelationshipOptions.map((option) {
                            return DropdownMenuItem<NomineeRelationshipOption>(
                              value: option,
                              child: Text(option.displayText),
                            );
                          }).toList(),
                      onChanged: (NomineeRelationshipOption? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedNomineeRelationship = newValue;
                            _nomineeRelationshipController.text =
                                newValue.value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          CustomTextField(
            label: 'Nominee Address',
            hint: 'Enter nominee address',
            controller: _nomineeAddressController,
            maxLines: 3,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn && !_navigated) {
      _navigated = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(), () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => MainScaffold()),
            (route) => false,
          );
        });
      });
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Colors.amber.shade600,
        foregroundColor: Colors.white,
      ),

      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            Column(
              children: [
                _buildStepIndicator(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_currentStep == 0) _buildPersonalInfoStep(),
                        if (_currentStep == 1) _buildAddressStep(),
                        if (_currentStep == 2) _buildDocumentsStep(),
                        if (_currentStep == 3) _buildNomineeStep(),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: Row(
                            children: [
                              if (_currentStep > 0)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _prevStep,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      side: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      foregroundColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                    child: Text(
                                      'Previous',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              if (_currentStep > 0) const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      _currentStep < _stepTitles.length - 1
                                          ? _nextStep
                                          : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor:
                                        Colors
                                            .black, // Ensures good contrast on amber
                                    minimumSize: const Size(100, 44),
                                    elevation: 4,
                                    shadowColor: Colors.amber.shade200,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),

                                  child: Text(
                                    _currentStep < _stepTitles.length - 1
                                        ? 'Continue'
                                        : 'Register',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Processing...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
