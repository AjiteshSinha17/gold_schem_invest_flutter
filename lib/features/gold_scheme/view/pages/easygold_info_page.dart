import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rajakumari_scheme/core/services/auth_state_service.dart';
import 'package:rajakumari_scheme/features/authentication/view/pages/login_with_phone_page.dart';
import 'package:rajakumari_scheme/features/gold_scheme/view/pages/gold_schemes_page.dart';

class EasygoldInfoPage extends StatelessWidget {
  const EasygoldInfoPage({super.key});

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Login Required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please login to view our schemes',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginWithPhonePage()),
              );
            },
            icon: const Icon(Icons.login),
            label: const Text('Login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black, // Ensures good contrast on amber
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context.mounted) {
      Future.microtask(() {
        context.read<AuthStateService>().refreshAuthState();
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schemes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Colors.amber.shade600,
        foregroundColor: Colors.white,
      ),

      backgroundColor: Colors.white,
      body: Consumer<AuthStateService>(
        builder: (context, authState, child) {
          // Show login prompt if user is not logged in

          if (!authState.isLoggedIn && authState.userId.isEmpty) {
            return _buildLoginPrompt(context);
          }

          return Column(
            children: [
              const SizedBox(height: 80),
              Expanded(
                flex: 3,
                child: SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/easygoldinfo.jpeg',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GoldSchemesPage(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber.shade600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Text(
                          'Our Schemes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Icon(FeatherIcons.chevronRight, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
