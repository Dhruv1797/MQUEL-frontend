import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/provider/user_provider.dart' show UserProvider;
import 'package:a2y_app/widgets/logout_dialog.dart';
import 'package:a2y_app/screens/user_profile_details_screen.dart';
import 'package:a2y_app/widgets/widgets.dart';
import 'package:a2y_app/widgets/notification_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(List<int>)? onNotificationTap;
  final bool showNotifications;

  const CustomAppBar({
    super.key,
    this.onNotificationTap,
    this.showNotifications = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      titleSpacing: 24,
      title: const Text(
        'M.QUE.L',
        style: TextStyle(
          fontSize: 24,
          fontFamily: globatMaganteFamily,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            children: [
              if (showNotifications) ...[
                _buildNotificationPanel(context),
                const SizedBox(width: 20),
              ],
              GestureDetector(
                onTap: () {
                  goToNextScreenPush(context, UserProfileScreen());
                },
                child: _buildProfileSection(context),
              ),
              const SizedBox(width: 30),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const LogoutDialog();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationPanel(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userId = userProvider.userId ?? 41;

        return NotificationPanel(
          userId: userId,
          onNotificationTap: (participantIds) {
            onNotificationTap?.call(participantIds);
          },
        );
      },
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final displayName = userProvider.fullName.isNotEmpty
            ? userProvider.fullName
            : userProvider.firstName.isNotEmpty
            ? userProvider.firstName
            : 'User';

        final userRole = userProvider.role.isNotEmpty
            ? userProvider.role
            : 'Guest';

        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/profile_icon.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  userRole,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
