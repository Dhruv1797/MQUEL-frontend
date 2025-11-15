import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/provider/user_provider.dart';
import 'package:a2y_app/widgets/company_add_dialog.dart';
import 'package:a2y_app/controller/company_dasboard_controller.dart';
import 'package:a2y_app/widgets/company_dashboard_table_section.dart';
import 'package:a2y_app/widgets/invite_dialog.dart';
import 'package:a2y_app/widgets/custom_app_bar.dart';
import 'package:a2y_app/screens/unfied_screen.dart';
import 'package:a2y_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  _CompanyDashboardScreenState createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  late CompanyDashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CompanyDashboardController();
  }

  Future<void> _showAddCompanyDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CompanyCooldownDialog(isEditMode: false),
    );

    if (result == true) {
      _controller.onCompanyAdded();
    }
  }

  void _onInvitePressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InviteDialog(isCompanyInvite: true);
      },
    );
  }

  void _navigateToUnifiedScreen(List<int> participantIds) {
    goToNextScreenPush(
      context,
      UnifiedScreen(initialParticipantFilter: participantIds),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        onNotificationTap: (participantIds) {
          _navigateToUnifiedScreen(participantIds);
        },
      ),
      body: RefreshIndicator(
        onRefresh: _controller.refreshCompanies,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: Color.fromRGBO(228, 228, 228, 1),
                  ),
                  top: BorderSide(
                    width: 1,
                    color: Color.fromRGBO(228, 228, 228, 1),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 25,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            final displayName =
                                userProvider.firstName.isNotEmpty
                                ? userProvider.firstName
                                : userProvider.fullName.isNotEmpty
                                ? userProvider.fullName
                                : 'User';

                            return Text(
                              'Welcome, $displayName',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                                fontFamily: 'Inter',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _onInvitePressed,
                          icon: const Icon(
                            Icons.person_add_outlined,
                            size: 18,
                            color: Colors.black,
                          ),
                          label: const Text(
                            'Invite',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: globatInterFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(
                              color: Color.fromRGBO(208, 213, 221, 1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _showAddCompanyDialog(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Client'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: CompanyTableSection(controller: _controller),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
