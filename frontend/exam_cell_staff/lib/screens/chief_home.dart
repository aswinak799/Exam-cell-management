import 'package:exam_cell_staff/login.dart';
import 'package:exam_cell_staff/screens/notification/notification.dart';
import 'package:exam_cell_staff/screens/profile.dart';
import 'package:exam_cell_staff/screens/widgets/bottom_nav_chief.dart';
import 'package:exam_cell_staff/screens/widgets/bottom_navigation.dart';
import 'package:exam_cell_staff/screens/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChiefHome extends StatelessWidget {
  const ChiefHome({super.key});
  static ValueNotifier<int> selectedIndexNotifire = ValueNotifier(0);
  final _pages = const [
    ProfileScreen(),
    NotificationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(
          child: Text(
            'KMCT EXAM CELL',
            style: GoogleFonts.aladin(
              fontWeight: FontWeight.bold,
              color: Colors.white60,
            ),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              final _sharedprif = await SharedPreferences.getInstance();
              await _sharedprif.clear();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                builder: ((ctx1) {
                  return LoginPage();
                }),
              ), (route) => false);
            },
            icon: Icon(Icons.logout),
            label: Text('logout'),
          )
        ],
      ),
      drawer: DrawerNav(),
      bottomNavigationBar: const BottomNavChief(),
      body: SafeArea(
          child: ValueListenableBuilder(
        valueListenable: selectedIndexNotifire,
        builder: (BuildContext context, int value, _) {
          return _pages[value];
        },
      )),
    );
  }
}
