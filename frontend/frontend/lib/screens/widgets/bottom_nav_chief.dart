import 'package:frontend/config/ip.dart';
import 'package:frontend/screens/chief_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:molten_navigationbar_flutter/molten_navigationbar_flutter.dart';

class BottomNavChief extends StatelessWidget {
  const BottomNavChief({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ChiefHome.selectedIndexNotifire,
      builder: (BuildContext ctx, int updatedindex, Widget? _) {
        return MoltenBottomNavigationBar(
          barColor: Colors.blue[100],
          selectedIndex: updatedindex,
          onTabChange: (clickedIndex) {
            ChiefHome.selectedIndexNotifire.value = clickedIndex;
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

          ],
        );
      },
    );
  }
}
