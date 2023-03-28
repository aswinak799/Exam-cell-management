import 'package:exam_cell_staff/screens/chief_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavChief extends StatelessWidget {
  const BottomNavChief({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ChiefHome.selectedIndexNotifire,
      builder: (BuildContext ctx, int updatedindex, Widget? _) {
        return BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            backgroundColor: Colors.white60,
            elevation: 10,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 18.0,
            showUnselectedLabels: false,
            selectedLabelStyle: GoogleFonts.aladin(
              fontWeight: FontWeight.bold,
            ),
            currentIndex: updatedindex,
            onTap: (newIndex) {
              ChiefHome.selectedIndexNotifire.value = newIndex;
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
            ]);
      },
    );
  }
}
