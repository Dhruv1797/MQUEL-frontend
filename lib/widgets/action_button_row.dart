import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/provider/user_provider.dart';
import 'package:a2y_app/controller/unified_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ActionButtonsRow extends StatelessWidget {
  final bool showCompanies;
  final VoidCallback onInvitePressed;
  final VoidCallback onDownloadPressed;
  final VoidCallback onAddPressed;
  final bool isFromPerson;
  final UnifiedScreenController controller;

  const ActionButtonsRow({
    super.key,
    required this.showCompanies,
    required this.onInvitePressed,
    required this.onDownloadPressed,
    required this.onAddPressed,
    required this.isFromPerson,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final isUserRole = userProvider.role == 'USER';

        return Row(
          children: [
            if (!showCompanies) ...[
              _buildExportButton(isDisabled: isUserRole),
              const SizedBox(width: 10),
            ],
            _buildAddButton(),
          ],
        );
      },
    );
  }

  Widget _buildInviteButton({bool isDisabled = false}) {
    return ElevatedButton(
      style: isDisabled ? _getDisabledButtonStyle() : _getPrimaryButtonStyle(),
      onPressed: isDisabled ? null : onInvitePressed,
      child: const Text(
        'invite',
        style: TextStyle(
          fontFamily: globatInterFamily,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildDownloadButton({bool isDisabled = false}) {
    return ElevatedButton.icon(
      style: isDisabled
          ? _getDisabledButtonStyle()
          : _getSecondaryButtonStyle(),
      onPressed: isDisabled ? null : onDownloadPressed,
      icon: SvgPicture.asset(
        "assets/images/download.svg",
        colorFilter: isDisabled
            ? const ColorFilter.mode(Colors.grey, BlendMode.srcIn)
            : null,
      ),
      label: const Text(
        "Download",
        style: TextStyle(
          fontFamily: globatInterFamily,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildExportButton({bool isDisabled = false}) {
    return Builder(
      builder: (context) => ElevatedButton.icon(
        style: isDisabled
            ? _getDisabledButtonStyle()
            : _getSecondaryButtonStyle(),
        onPressed: isDisabled
            ? null
            : () => controller.exportSelectedPeopleToExcel(context),
        icon: Icon(
          Icons.file_download,
          color: isDisabled ? Colors.grey : const Color(0xFF6B7280),
          size: 20,
        ),
        label: const Text(
          "Export Selected",
          style: TextStyle(
            fontFamily: globatInterFamily,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      style: _getPrimaryButtonStyle(),
      onPressed: onAddPressed,
      icon: SvgPicture.asset("assets/images/cloud-upload.svg"),
      label: Text(
        showCompanies
            ? "Upload Companies"
            : controller.selectedPersonTabIndex == 0
            ? "Upload Attendees"
            : "Upload Persona",
        style: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }

  ButtonStyle _getSecondaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(
          color: Color.fromRGBO(204, 204, 204, 1),
          width: 1,
        ),
      ),
    );
  }

  ButtonStyle _getPrimaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  ButtonStyle _getDisabledButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.grey.shade300,
      foregroundColor: Colors.grey.shade600,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
    );
  }
}
