import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/provider/user_provider.dart';
import 'package:a2y_app/widgets/custom_app_bar.dart';
import 'package:a2y_app/controller/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:a2y_app/widgets/data_table_container.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late UserProfileController _controller;
  late int _adminId;

  @override
  void initState() {
    super.initState();
    _controller = UserProfileController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _adminId = userProvider.userId;
      _controller.initialize(_adminId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProfileController>.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: CustomAppBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
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
                  child: _buildBackButton(),
                ),
              ),
              const SizedBox(height: 24),
              _buildUserProfile(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 10,
                ),
                child: _buildMembersSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset("assets/images/back_button.svg"),
          const SizedBox(width: 15),
          const Text(
            'Profile',
            style: TextStyle(
              fontFamily: globatInterFamily,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: const Color.fromRGBO(229, 231, 235, 1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 1),
                blurRadius: 3,
                color: const Color.fromRGBO(0, 0, 0, 0.1),
              ),
              BoxShadow(
                offset: const Offset(0, 1),
                blurRadius: 2,
                color: const Color.fromRGBO(0, 0, 0, 0.06),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      userProvider.fullName.isNotEmpty
                          ? userProvider.fullName
                          : 'User Profile',
                      style: const TextStyle(
                        fontFamily: globatInterFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Divider(height: 1, color: const Color.fromRGBO(229, 231, 235, 1)),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'First Name',
                          style: const TextStyle(
                            fontFamily: globatInterFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(107, 114, 128, 1),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            userProvider.firstName.isNotEmpty
                                ? userProvider.firstName
                                : 'N/A',
                            style: const TextStyle(
                              fontFamily: globatInterFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: const TextStyle(
                            fontFamily: globatInterFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(107, 114, 128, 1),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            userProvider.email.isNotEmpty
                                ? userProvider.email
                                : 'N/A',
                            style: const TextStyle(
                              fontFamily: globatInterFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Role',
                          style: const TextStyle(
                            fontFamily: globatInterFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(107, 114, 128, 1),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: userProvider.role == 'ADMIN'
                                ? const Color.fromRGBO(212, 255, 212, 1)
                                : const Color.fromRGBO(255, 212, 212, 1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: userProvider.role == 'ADMIN'
                                  ? const Color.fromRGBO(21, 142, 19, 0.3)
                                  : const Color.fromRGBO(142, 21, 19, 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: userProvider.role == 'ADMIN'
                                      ? const Color.fromRGBO(21, 142, 19, 1)
                                      : const Color.fromRGBO(142, 21, 19, 1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  userProvider.role.isNotEmpty
                                      ? userProvider.role
                                      : 'N/A',
                                  style: TextStyle(
                                    fontFamily: globatInterFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: userProvider.role == 'ADMIN'
                                        ? const Color.fromRGBO(21, 142, 19, 1)
                                        : const Color.fromRGBO(142, 21, 19, 1),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMembersSection() {
    return Consumer<UserProfileController>(
      builder: (context, controller, child) {
        return SizedBox(
          height: 600,
          child: controller.tableData.isEmpty && !controller.isLoading
              ? _buildNoDataWidget(controller)
              : DataTableContainer(
                  isFromCompanyDasboardScreen: false,
                  isFromUserProfile: true,
                  isFromPersonScreen: false,
                  isFromUnfiedScreen: false,
                  userProfileController: controller,

                  isFromProfile: true,
                  isLoading: controller.isLoading,
                  errorMessage: controller.errorMessage,
                  data: controller.tableData,
                  columns: controller.getColumns(context),
                  currentPage: controller.currentPage,
                  totalPages: controller.totalPages,
                  showCompanies: false,
                  hasActiveFilter: controller.hasActiveFilter,
                  sortColumnKey: controller.sortColumnKey,
                  sortAscending: controller.sortAscending,
                  onSearchChanged: controller.onSearchChanged,
                  onPageChanged: controller.onPageChanged,
                  onRowTap: controller.onRowTap,
                  onSelectionChanged: controller.onSelectionChanged,
                  onSort: controller.onSort,
                  onFilterPressed: controller.onFilterPressed,
                  onRefreshPressed: () => controller.onRefreshPressed(_adminId),
                  onRetryPressed: () => controller.onRetryPressed(_adminId),
                  onClearFilters: controller.onClearFilters,
                  showAddInteractionButton: false,
                ),
        );
      },
    );
  }

  Widget _buildNoDataWidget(UserProfileController controller) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[300]!.withOpacity(0.3),
                      Colors.grey[400]!.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.people_outline,
                  size: 48,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Members Invited',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You haven\'t invited any members yet. Start inviting team members to collaborate.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () =>
                    controller.loadInvitedUsersWithAdminId(_adminId),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'Refresh',
                  style: TextStyle(
                    fontFamily: globatInterFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  side: BorderSide(
                    color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
