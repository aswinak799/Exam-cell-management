import 'package:exam_cell_staff/screens/profile/edit_profile.dart';
import 'package:exam_cell_staff/screens/profile/view_profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  // static ValueNotifier<int> selectedContainerNotifire = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          labelStyle: GoogleFonts.aladin(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'PROFILE',
            ),
            Tab(
              text: 'EDIT',
            ),
          ],
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              ViewProfile(),
              EditProfile(),
            ],
          ),
        )
      ],
    );
  }
}
