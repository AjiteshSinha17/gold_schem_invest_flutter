// ignore_for_file: deprecated_member_use

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rajakumari_scheme/core/constants/global_colors.dart';
import 'package:rajakumari_scheme/core/models/coredata_model.dart';
import 'package:rajakumari_scheme/core/services/auth_state_service.dart';
import 'package:rajakumari_scheme/features/contact/view/pages/contact_page.dart';
import 'package:rajakumari_scheme/features/gold_scheme/view/pages/easygold_info_page.dart';
import 'package:rajakumari_scheme/features/home/view/pages/goldrate/gold_rate_page.dart';
import 'package:rajakumari_scheme/features/home/view/pages/storesPage/store_page.dart';
import 'package:rajakumari_scheme/features/home/view/widgets/banner_widget.dart';
import 'package:rajakumari_scheme/features/home/view/widgets/gold_card_widget.dart';
import 'package:rajakumari_scheme/features/home/view/widgets/notification_widget.dart';
import 'package:rajakumari_scheme/features/schedule_visit/view/pages/Schedule_visit_page.dart';

class HomePage extends StatelessWidget {
  final CoreData? coreData;

  const HomePage({super.key, this.coreData});

  @override
  Widget build(BuildContext context) {
    final AuthStateService authStateService = AuthStateService();
    final isCompact = MediaQuery.of(context).size.width < 320;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 242, 252, 246),
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFFD4A017),
              elevation: 2,
              pinned: true,
              title: Row(
                children: [
                  if (coreData?.minLogo != null && coreData!.minLogo.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(
                        'https://rajakumarischeme.com/admin/${coreData!.minLogo}',
                        height: 34,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(width: 32, height: 32),
                      ),
                    ),
                  Text(
                    coreData?.siteTitle ?? 'Gold Scheme',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: isCompact ? 20 : 22,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              actions: [
                authStateService.isLoggedIn &&
                        authStateService.userId.isNotEmpty
                    ? IconButton(
                        icon:  Icon(MdiIcons.bellOutline, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (_, __, ___) => NotificationDrawer(
                                userId: authStateService.userId,
                              ),
                              transitionsBuilder: (_, animation, __, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      )
                    : const SizedBox(),
              ],
            ),

            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                const BannerWidget(),
                const SizedBox(height: 16),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(
                      color: Color(0xFFD4A017),
                      width: 1.5,
                    ),
                  ),
                  elevation: 6,
                  shadowColor: AppColors.primaryGold.withOpacity(0.4),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              MdiIcons.pin,
                              size: 20,
                              color: const Color.fromARGB(255, 255, 0, 0),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "Total Gold Rate",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4A017),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GoldCardWidget(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

                    final List<Map<String, dynamic>> services = [
                      {
                        "icon": MdiIcons.gold,
                        "color": Colors.amber[800],
                        "label": "Gold Rate",
                        "page": const GoldRatePage(),
                      },
                      {
                        "icon": MdiIcons.storefrontOutline,
                        "color": Colors.deepPurple,
                        "label": "Stores",
                        "page": const StoresPage(),
                      },
                      {
                        "icon": MdiIcons.bookOpenPageVariantOutline,
                        "color": Colors.blueAccent,
                        "label": "Schemes",
                        "page": EasygoldInfoPage(),
                      },
                      {
                        "icon": MdiIcons.phoneClassic,
                        "color": Colors.green,
                        "label": "Contact",
                        "page": ContactPage(coreData: coreData),
                      },
                      {
                        "icon": MdiIcons.calendarPlus,
                        "color": Colors.redAccent,
                        "label": "Schedule Visit",
                        "page": const ScheduleVisitPage(),
                      },
                    ];

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 300 + (index * 80)),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: _ServiceIcon(
                            icon: services[index]["icon"],
                            color: services[index]["color"],
                            label: services[index]["label"],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => services[index]["page"],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceIcon extends StatefulWidget {
  final IconData icon;
  final Color? color;
  final String label;
  final Function()? onTap;

  const _ServiceIcon({
    required this.icon,
    this.color,
    required this.label,
    this.onTap,
  });

  @override
  State<_ServiceIcon> createState() => _ServiceIconState();
}

class _ServiceIconState extends State<_ServiceIcon> {
  double _elevation = 2;

  void _onTapDown(_) => setState(() => _elevation = 6);
  void _onTapUp(_) => setState(() => _elevation = 2);

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 320;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => _elevation = 2),
      child: AnimatedPhysicalModel(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        elevation: _elevation,
        color: Colors.transparent,
        shadowColor: AppColors.primaryGold.withOpacity(0.4),
        borderRadius: BorderRadius.circular(isCompact ? 14 : 18),
        shape: BoxShape.rectangle,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF7E27E),
                Color(0xFFB0BEC5),
              ],
            ),
            borderRadius: BorderRadius.circular(isCompact ? 14 : 18),
            border: Border.all(
              color: const Color(0xFFD4A017),
              width: 1.3,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: isCompact ? 30 : 36,
                  color: widget.color ?? AppColors.primaryGold,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: isCompact ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
