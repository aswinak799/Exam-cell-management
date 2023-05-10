import 'package:frontend/config/ip.dart';
import 'package:frontend/screens/notification/allocation.dart';
import 'package:frontend/screens/notification/malpractice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

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
              text: 'ALLOCATION',
            ),
            Tab(
              text: 'MALPRACTICE',
            ),
          ],
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              Allocation(),
              MalPractice(),
            ],
          ),
        )
      ],
    );
  }
}
