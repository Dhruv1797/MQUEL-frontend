import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:a2y_app/constants/global_var.dart';

class PeopleScreenHeader extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onBackPressed;
  final VoidCallback onDownloadPressed;
  final VoidCallback onAddDataPressed;

  const PeopleScreenHeader({
    super.key,
    required this.title,
    required this.description,
    required this.onBackPressed,
    required this.onDownloadPressed,
    required this.onAddDataPressed,
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
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.black,
                    iconSize: 30,
                    onPressed: onBackPressed,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        fontFamily: globatInterFamily,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                description,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                softWrap: false,
                style: const TextStyle(
                  fontFamily: globatInterFamily,
                  color: Color.fromRGBO(121, 121, 121, 1),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Color.fromRGBO(204, 204, 204, 1),
                    width: 1,
                  ),
                ),
              ),
              onPressed: onDownloadPressed,
              icon: SvgPicture.asset("assets/images/download.svg"),
              label: const Text("Download"),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onAddDataPressed,
              icon: SvgPicture.asset("assets/images/add.svg"),
              label: const Text(
                "Add Data",
                style: TextStyle(
                  fontFamily: globatInterFamily,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PeopleScreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const PeopleScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      elevation: 0,
      toolbarHeight: 70,
      titleSpacing: 24,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        'M.QUE.L',
        style: TextStyle(
          fontSize: 24,
          fontFamily: globatInterFamily,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24),
          child: Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.white,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/notify.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              const SizedBox(width: 20),
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ashutosh',
                    style: TextStyle(
                      fontFamily: globatInterFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'admin',
                    style: TextStyle(
                      fontFamily: globatInterFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 30),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class PeopleSearchAndFilter extends StatelessWidget {
  final VoidCallback onSortPressed;
  final ValueChanged<String>? onSearchChanged;

  const PeopleSearchAndFilter({
    super.key,
    required this.onSortPressed,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromRGBO(204, 204, 204, 1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 400,
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                isCollapsed: true,
                isDense: true,
                hintText: "Search company",
                hintStyle: const TextStyle(
                  fontFamily: globatInterFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color.fromRGBO(166, 166, 166, 1),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(
                  color: Color.fromRGBO(204, 204, 204, 1),
                  width: 1,
                ),
              ),
            ),
            onPressed: onSortPressed,
            icon: SvgPicture.asset("assets/images/filter.svg"),
            label: const Text("Sort by"),
          ),
        ],
      ),
    );
  }
}
