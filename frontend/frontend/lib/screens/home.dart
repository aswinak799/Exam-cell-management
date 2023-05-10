import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:frontend/login.dart';
import 'package:frontend/screens/notification/notification.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/screens/report.dart';
import 'package:frontend/screens/widgets/bottom_navigation.dart';
import 'package:frontend/screens/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static ValueNotifier<int> selectedIndexNotifire = ValueNotifier(0);
  final _pages = const [
    ProfileScreen(),
    NotificationScreen(),
    ReportScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        leading: Image.asset('asset/kmct.png'),
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
              final service = FlutterBackgroundService();
              service.invoke('stopService');
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
      bottomNavigationBar: const BottomNavigation(),
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
