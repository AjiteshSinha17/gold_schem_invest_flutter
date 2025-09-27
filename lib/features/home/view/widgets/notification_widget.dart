import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rajakumari_scheme/core/constants/global_colors.dart';
import 'package:rajakumari_scheme/features/home/models/notification_model.dart';
import 'package:rajakumari_scheme/features/home/services/notification_service.dart';
//import 'package:rajakumari_scheme/utils/app_colors.dart';

class NotificationDrawer extends StatefulWidget {
  final String userId;
  const NotificationDrawer({super.key, required this.userId});

  @override
  State<NotificationDrawer> createState() => _NotificationDrawerState();
}

class _NotificationDrawerState extends State<NotificationDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  final NotificationService _notificationService = NotificationService();

  List<NotificationData> notifications = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();

    // Animation controller for slide transition (drawer-like effect)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // start off-screen (right)
      end: Offset.zero, // slide in to normal position
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _loadNotifications();
    _controller.forward(); // start animation
  }

  /// Load notifications from the service
  Future<void> _loadNotifications() async {
    setState(() => loading = true);
    try {
      final data = await _notificationService.fetchNotifications(widget.userId);
      setState(() => notifications = data);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  /// Show full notification details in a popup dialog
  void _showNotificationDetails(NotificationData notif) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white, // full white background for dialog
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Title
                Text(
                  notif.title.isNotEmpty ? notif.title : "Notification",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 8),

                // Notification Message
                Text(
                  notif.msg,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 8),

                // Show link only if it starts with https
                notif.link.isNotEmpty && notif.link.startsWith("https")
                    ? InkWell(
                        onTap: () => debugPrint("Open link: ${notif.link}"),
                        child: Text(
                          notif.link,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 8),

                // Created At Date
                Text(
                  "Created At: ${DateFormat("dd MMM yyyy, hh:mm a").format(notif.createdOn)}",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 12),

                // Close button
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.darkCharcoal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Scaffold(
        backgroundColor: AppColors.white, // ✅ Full white background
        appBar: AppBar(
          title: const Text(
            "Notifications",
            style: TextStyle(color: AppColors.darkCharcoal, fontSize: 22),
          ),
          backgroundColor: AppColors.primaryGold,
          elevation: 4, // subtle drop shadow for contrast
          actions: [
            // Refresh button only
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.darkCharcoal),
              onPressed: _loadNotifications,
            ),
          ],
        ),
        body: loading
            // Show loader when fetching
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              )
            // Show empty state if no notifications
            : notifications.isEmpty
                ? const Center(
                    child: Text(
                      "No notifications found",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  )
                // GridView for notifications
                : Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // ✅ 2-column grid
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return _notificationCard(notif);
                      },
                    ),
                  ),
      ),
    );
  }

  /// Builds each notification card (grid item)
  Widget _notificationCard(NotificationData notif) {
    return GestureDetector(
      onTap: () => _showNotificationDetails(notif),
      child: Card(
        color: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: Colors.black26,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Notification icon
              Icon(Icons.notifications_active,
                  color: AppColors.primaryGold, size: 36),

              const SizedBox(height: 8),

              // Title (single line)
              Text(
                notif.title.isNotEmpty ? notif.title : 'Notification',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 4),

              // Message preview (2 lines max)
              Text(
                notif.msg,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black54, height: 1.3),
              ),
              const SizedBox(height: 6),

              // Created date (short format)
              Text(
                DateFormat("dd MMM").format(notif.createdOn),
                style: const TextStyle(
                    fontSize: 12, color: AppColors.emeraldGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
