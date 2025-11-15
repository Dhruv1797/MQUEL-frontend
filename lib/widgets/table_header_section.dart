import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/model/companyModel.dart';
import 'package:a2y_app/widgets/action_button_row.dart';
import 'package:a2y_app/controller/unified_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TabHeaderSection extends StatelessWidget {
  final bool showCompanies;
  final Function(bool) onTabChanged;
  final VoidCallback onInvitePressed;
  final VoidCallback onDownloadPressed;
  final VoidCallback onAddPressed;
  final CompanyModel? companyData;
  final UnifiedScreenController controller;

  const TabHeaderSection({
    super.key,
    required this.showCompanies,
    required this.onTabChanged,
    required this.onInvitePressed,
    required this.onDownloadPressed,
    required this.onAddPressed,
    this.companyData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildTabButtons(context)],
          ),
        ),
        ActionButtonsRow(
          showCompanies: showCompanies,
          onInvitePressed: onInvitePressed,
          onDownloadPressed: onDownloadPressed,
          onAddPressed: onAddPressed,
          isFromPerson: false,
          controller: controller,
        ),
      ],
    );
  }

  Widget _buildTabButtons(context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: SvgPicture.asset("assets/images/back_button.svg"),
        ),
        SizedBox(width: 14),

        Text(
          companyData?.displayOrgName ?? "All Data",
          style: TextStyle(
            fontFamily: globatInterFamily,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          showCompanies ? "All Companies" : "People",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: false,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          showCompanies
              ? "Here's a comprehensive list of all the companies for you to explore. Let's dive in and check them out!"
              : "List of people that we have met and needs continuous interaction from this company.",
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          softWrap: false,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Color.fromRGBO(121, 121, 121, 1),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
