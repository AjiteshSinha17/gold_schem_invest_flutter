// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rajakumari_scheme/core/constants/global_colors.dart';
import 'package:rajakumari_scheme/features/gold_scheme/controllers/scheme_list_controller.dart';
import 'package:rajakumari_scheme/features/gold_scheme/models/scheme_model.dart';
import 'package:rajakumari_scheme/features/gold_scheme/view/pages/scheme_invest_page.dart';
// import 'package:rajakumari_scheme/theme/app_colors.dart';

class GoldSchemesPage extends StatefulWidget {
  const GoldSchemesPage({super.key});

  @override
  State<GoldSchemesPage> createState() => _GoldSchemesPageState();
}

class _GoldSchemesPageState extends State<GoldSchemesPage> {
  final SchemeListController _controller = SchemeListController();
  bool _isLoading = true;
  List<SchemeModel> _schemes = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

  Future<void> _loadSchemes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await _controller.getSchemeList();

      if (response.status == 'true' && response.data.isNotEmpty) {
        setState(() {
          _schemes = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No schemes available';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load schemes';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Our Schemes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: Image.asset('assets/images/loading.gif'));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadSchemes, child: const Text('Retry')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSchemes,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(), // smooth scroll effect
        padding: const EdgeInsets.all(20.0),
        itemCount: _schemes.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildWarningMessage();
          }
          final scheme = _schemes[index - 1];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(bottom: 24),
            child: GestureDetector(
              onTap: () => _openSchemeDetails(scheme),
              child: _buildSchemeCardFromModel(scheme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGold.withOpacity(0.25), AppColors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline, 
            color: Colors.redAccent,
            size: 50,
          ),
          const SizedBox(height: 16),
          Text(
            'Before you join a scheme, follow all on-screen instructions carefully.\n\n'
            'Do NOT close the app or payment gateway until a success/failure message appears.\n\n'
            'Avoid exiting the app abruptly if issues occur.',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCardFromModel(SchemeModel scheme) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.white.withOpacity(0.65),
                  AppColors.metallicSilver.withOpacity(0.25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  scheme.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "${scheme.noMonths} months",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "₹ ${scheme.instalmentAmt}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSchemeDetails(SchemeModel scheme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _SchemeDetailsPage(scheme: scheme),
      ),
    );
  }
}

class _SchemeDetailsPage extends StatelessWidget {
  final SchemeModel scheme;
  const _SchemeDetailsPage({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(scheme.name.toUpperCase()),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _infoTile(Icons.calendar_month_outlined, "Duration",
                "${scheme.noMonths} months"),
            _infoTile(Icons.payments_outlined, "Monthly Payment",
                "₹ ${scheme.instalmentAmt}"),
            _infoTile(Icons.savings_outlined, "Total Paid",
                "₹ ${scheme.totalInstalmentAmt}"),
            _infoTile(
                Icons.card_giftcard_outlined, "Bonus", "₹ ${scheme.bonusAmt}"),
            _infoTile(Icons.account_balance_wallet_outlined, "Total Benefit",
                "₹ ${scheme.totalAmt}"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SchemeInvestPage(
                      schemeId: scheme.id,
                      amount: scheme.instalmentAmt,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                backgroundColor: AppColors.primaryGold,
                elevation: 8,
                shadowColor: AppColors.primaryGold.withOpacity(0.5),
              ),
              child: const Text(
                "Join Scheme",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    final List<Color> iconColors = [
      AppColors.primaryGold,
      AppColors.emeraldGreen,
      Colors.deepOrange.shade600,
      Colors.indigo.shade600,
    ];
    final Color randomColor =
        iconColors[Random().nextInt(iconColors.length)];

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, AppColors.metallicSilver.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: randomColor, size: 30),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkCharcoal,
            ),
          ),
        ],
      ),
    );
  }
}
