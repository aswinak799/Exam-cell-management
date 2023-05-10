import 'package:frontend/config/ip.dart';
import 'package:frontend/screens/home.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:molten_navigationbar_flutter/molten_navigationbar_flutter.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HomeScreen.selectedIndexNotifire,
      builder: (BuildContext ctx, int updatedindex, Widget? _) {
        return MoltenBottomNavigationBar(
          barColor: Colors.blue[100],
          selectedIndex: updatedindex,
          onTabChange: (clickedIndex) {
            HomeScreen.selectedIndexNotifire.value = clickedIndex;
          },duration: Duration(milliseconds: 400),
          tabs: [
            MoltenTab(
              icon: Icon(Icons.home_filled),
              title: textView('Home', 15),
            ),
            MoltenTab(
              icon: Icon(Icons.notifications),
              title: textView('Notifications', 15),
            ),
            MoltenTab(
              icon: Icon(Icons.report),
              title: textView('Report', 15),
            ),
          ],
        );

      },
    );
  }
}



