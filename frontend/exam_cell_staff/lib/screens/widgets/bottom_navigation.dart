import 'package:exam_cell_staff/screens/home.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HomeScreen.selectedIndexNotifire,
      builder: (BuildContext ctx, int updatedindex, Widget? _) {
        return BottomNavigationBar(
            backgroundColor: Colors.white38,
            elevation: 10,
            type: BottomNavigationBarType.shifting,
            selectedItemColor: Colors.indigoAccent[400],
            unselectedItemColor: Colors.grey,
            selectedFontSize: 18.0,
            showUnselectedLabels: false,
            selectedLabelStyle: GoogleFonts.aladin(
              fontWeight: FontWeight.bold,
            ),
            currentIndex: updatedindex,
            onTap: (newIndex) {
              HomeScreen.selectedIndexNotifire.value = newIndex;
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: "Notification",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.report),
                label: "Report",
              )
            ]);
      },
    );
  }
}
