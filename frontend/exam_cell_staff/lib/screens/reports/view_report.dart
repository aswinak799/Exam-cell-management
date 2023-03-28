import 'dart:convert';
import 'package:exam_cell_staff/screens/reports/view_image.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'package:exam_cell_staff/config/ip.dart';
import 'package:exam_cell_staff/login.dart';
import 'package:exam_cell_staff/screens/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewReport extends StatefulWidget {
  final int id;
  const ViewReport({Key? key, required this.id}) : super(key: key);

  @override
  State<ViewReport> createState() => _ViewReportState();
}

class _ViewReportState extends State<ViewReport> {
  late int mid;
  late String image;
  bool img = false;
  String? hall;
  String? student;
  String? regNo;
  String? date;
  String? time;
  String? message;
  String? slot;
  String? exam;
  @override
  void initState() {
    super.initState();
    mid = widget.id;
    getReport(mid);
  }

  Future<void> getReport(id) async {
    String idString = id.toString();

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://$MY_IP:8000/get_report'));

    request.fields['id'] = idString;
    var response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final data = json.decode(body);
      print(data['student']);
      setState(() {
        image = data['image'];
        hall = data['hall'];
        student = data['student'];
        regNo = data['reg_no'];
        date = data['date'];
        time = data['time'];
        message = data['message'];
        slot = data['slot'];
        exam = data['exam'];
        if (data['image'] != null) {
          img = true;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: textView('Server Error', 20),
        margin: const EdgeInsets.all(20),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromARGB(255, 255, 74, 64),
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            textView('View Report', 30),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 300,
                  child: img
                      ? Image.network('http://$MY_IP:8000/$image')
                      : textView('no image', 10),
                ),
                SizedBox(
                  width: 35,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    children: [
                      textView('Hall --- $hall', 30),
                      SizedBox(
                        height: 30,
                      ),
                      textView('Student --- $student', 15),
                      textView('Register No --- $regNo', 15),
                      SizedBox(
                        height: 25,
                      ),
                      textView('Date --- $date', 15),
                      textView('Time --- $time', 15),
                      textView('Slot --- $slot', 15),
                      SizedBox(
                        height: 30,
                      ),
                      ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (ctx) {
                              return ViewImage(image: image);
                            }));
                          },
                          icon: Icon(Icons.image),
                          label: textView('View Image', 20))
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Card(
              child: ListTile(
                  subtitle: Center(child: textView('Message : $message', 20))),
            ),
            Card(
              child: ListTile(
                  subtitle: Center(child: textView('Exam : $exam', 17))),
            ),
          ],
        ),
      )),
    );
  }
}
