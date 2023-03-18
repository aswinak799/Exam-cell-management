import 'package:exam_cell_staff/screens/new_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:exam_cell_staff/screens/reort_list.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
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
              text: 'REPORTS',
            ),
            Tab(
              text: 'REPORTING',
            ),
          ],
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              ReportList(),
              NewReport(),
            ],
          ),
        )
      ],
    );
  }
}
// import 'package:flutter/material.dart';

// class ReportScreen extends StatefulWidget {
//   const ReportScreen({super.key});

//   @override
//   State<ReportScreen> createState() => _ReportScreenState();
// }

// class _ScreenCategoryState extends State<ScreenCategory>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   @override
//   void initState() {
//     _tabController = TabController(length: 2, vsync: this);

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(
//               text: 'INCOME',
//             ),
//             Tab(
//               text: 'EXPENCE',
//             ),
//           ],
//           labelColor: Colors.black87,
//           unselectedLabelColor: Colors.grey,
//         ),
//         Expanded(
//           child: TabBarView(
//             controller: _tabController,
//             children: const [
//               ReportList(),
//               ExpenceList(),
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }
