// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:io';

import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:rajakumari_scheme/core/api_secrets/api_secrets.dart';
import 'package:rajakumari_scheme/core/services/auth_state_service.dart';
import 'package:rajakumari_scheme/core/services/shared_pref_service.dart';
import 'package:rajakumari_scheme/features/profile/controllers/profile_delete_controller.dart';
import 'package:rajakumari_scheme/features/profile/view/pages/edit_profile_page.dart';
import 'package:rajakumari_scheme/features/profile/view/pages/local_transaction_history.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileDeleteController _deleteController = ProfileDeleteController();
  final AuthStateService _authStateService = AuthStateService();
  String userName = '';
  String userMobile = '';
  String userId = '';
  String profileImage = '';
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Fetch user data from SharedPrefService
    userName = SharedPrefService.getUserName();
    userMobile = SharedPrefService.getUserMobile();
    userId = SharedPrefService.getUserId();
    profileImage = SharedPrefService.getUserProfileImage();

    // Default image if profile image is empty
    imageUrl =
        profileImage.isNotEmpty
            ? profileImage
            : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=random&color=fff&size=60';

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Colors.amber.shade600,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Profile Image
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                FeatherIcons.user,
                                color: Colors.amber,
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Camera Icon Button
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: () {
                          _showProfilePictureOptions(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(
                            FeatherIcons.camera,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Profile Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userMobile,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: RK-$userId',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildProfileOption(
            icon: FeatherIcons.edit,
            title: 'Transaction history',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocalTransactionHistory(),
                ),
              );

              // Refresh data if profile was updated
              if (result == true) {
                _loadUserData();
              }
            },
          ),
          // Profile Options
          const SizedBox(height: 8),
          _buildProfileOption(
            icon: FeatherIcons.edit,
            title: 'Edit Profile',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );

              // Refresh data if profile was updated
              if (result == true) {
                _loadUserData();
              }
            },
          ),

          _buildProfileOption(
            icon: FeatherIcons.trash2,
            title: 'Delete Profile',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Delete Profile'),
                    content: const Text(
                      'Are you sure you want to delete your profile? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _deleteController.deleteProfile(
                            context,
                            userId,
                          );
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            isDanger: true,
          ),
          _buildProfileOption(
            icon: FeatherIcons.logOut,
            title: 'Logout',
            isLast: true,
            isDanger: true,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    title: Column(
                      children: const [
                        Icon(
                          Icons.exit_to_app_rounded,
                          size: 30,
                          color: Colors.redAccent,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Confirm Logout',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    content: const Text(
                      'Are you sure you want to logout?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            245,
                            131,
                            131,
                          ),
                        ),
                        onPressed: () async {
                          await _authStateService.logout();
                          if (mounted) {
                            Navigator.pop(context); // Close dialog
                          }
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

        
        ],
      ),
    );
  }

  // Method to show profile picture options dialog
  void _showProfilePictureOptions(BuildContext context) {
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
              ListTile(
                leading: const Icon(FeatherIcons.camera, color: Colors.black54),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(context, ImageSource.camera, userId);
                },
              ),
              ListTile(
                leading: const Icon(FeatherIcons.image, color: Colors.black54),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(context, ImageSource.gallery, userId);
                },
              ),
              if (profileImage.isNotEmpty)
                ListTile(
                  leading: const Icon(FeatherIcons.trash2, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmRemovePhoto(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Method to pick image from camera or gallery
  Future<void> pickImage(
    BuildContext context,
    ImageSource source,
    String userId,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70, // Reduce image quality to save space
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final imageName = '$timestamp${pickedFile.name}';

        await uploadImage(imageFile, imageName, userId);
      }
    } catch (e) {
      log("Error picking image: $e");
      if (!context.mounted) return;

      Fluttertoast.showToast(
        msg: 'Failed to pick image. Please check app permissions.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
      );
    }
  }

  // Method to upload image to server
  Future<void> uploadImage(
    File imageFile,
    String imageUrl,
    String userId,
  ) async {
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

      if (response.statusCode == 200) {
        await updateDp(imageUrl, userId);
      }
    } catch (e) {
      log("Error uploading image: $e");
    }
  }

  // Method to update profile picture in the database
  Future<void> updateDp(String imageUrl, String userId) async {
    final apiUrl =
        '${ApiSecrets.baseUrl}/index.php?token=${ApiSecrets.token}&user_id=$userId&profile_image=$imageUrl';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        log("Profile picture updated successfully");

        // Update profile image in shared preferences
        await SharedPrefService.setUserProfileImage(imageUrl);

        // Refresh profile data
        _loadUserData();
      }
    } catch (e) {
      log("Error updating profile picture: $e");
    }
  }

  // Method to confirm removing profile photo
  void _confirmRemovePhoto(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Photo'),
          content: const Text(
            'Are you sure you want to remove your profile photo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // Remove profile photo by setting empty string
                await updateDp('', userId);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : const Color(0xFFEEEEEE),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDanger
                        ? Colors.red.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDanger ? Colors.red : Colors.black54,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const Icon(
              FeatherIcons.chevronRight,
              color: Colors.black45,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
