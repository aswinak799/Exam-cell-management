import 'dart:convert';
import 'package:frontend/screens/reports/view_report.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/config/ip.dart';
import 'package:frontend/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyData {
  final int id;
  final String hall;
  final String date;
  final String time;
  final String exam;
  final String slot;
  final String message;
  final String image;

  MyData({
    required this.id,
    required this.hall,
    required this.date,
    required this.time,
    required this.exam,
    required this.slot,
    required this.message,
    required this.image,
  });
}

class ReportList extends StatefulWidget {
  const ReportList({super.key});

  @override
  State<ReportList> createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  _ReportListState() {
    getReports();
  }
  List<MyData> _dataList = [];
  bool isLoading = true;

  Future<void> getReports() async {
    final _sharedprif = await SharedPreferences.getInstance();
    // String nameStaff = _sharedprif.getString('name').toString();
    int id = _sharedprif.getInt('id') ?? 0;
    String idString = id.toString();
    List<MyData> dataList = [];
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://$MY_IP:8000/get_reports'));

    request.fields['id'] = idString;
    var response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final data = json.decode(body);
      for (var data in data['report']) {
        dataList.add(MyData(
          id: data['id'],
          hall: data['hall'],
          date: data['date'],
          time: data['time'],
          exam: data['exam'],
          slot: data['slot'],
          message: data['message'],
          image: data['image'],
        ));
      }
      if (mounted) {
        setState(() {
          _dataList = dataList;
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: textView('Server Error', 20),
        margin: const EdgeInsets.all(20),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromARGB(255, 255, 74, 64),
      ));
      _sharedprif.clear();
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
        builder: ((ctx1) {
          return LoginPage();
        }),
      ), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading? loadingWidget() : Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ListView.separated(
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              shadowColor: Colors.indigoAccent,
              clipBehavior: Clip.hardEdge,
              child: ListTile(
                onTap: () {
                  bottomSheet(
                    _dataList[index].hall,
                    _dataList[index].date,
                    _dataList[index].exam,
                    _dataList[index].slot,
                    _dataList[index].message,
                    _dataList[index].time,
                  );
                },
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'http://$MY_IP:8000/${_dataList[index].image}'),
                  maxRadius: 20,
                ),
                subtitle: Column(
                  children: [
                    textView(
                      '${_dataList[index].hall}',
                      20,
                    ),
                    textView('${_dataList[index].date}', 15),
                    textView('${_dataList[index].slot}', 15),
                  ],
                ),
                trailing: Column(
                  children: [
                    IconButton(
                        onPressed: (() {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: ((context) {
                                return ViewReport(id: _dataList[index].id);
                              }),
                            ),
                          );
                        }),
                        icon: Icon(Icons.more))
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 5,
            );
          },
          itemCount: _dataList.length),
    );
  }

  Future<void> bottomSheet(
    String hall,
    String date,
    String exam,
    String slot,
    String message,
    String time,
  ) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
      ),
      elevation: 5,
      enableDrag: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 2000,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 217, 221, 225),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              right: 20,
              left: 20,
              top: 30,
              bottom: 30,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    textView('YOUR REPORT', 30),
                    textView('-------------', 30),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      focusColor: Colors.cyanAccent,
                      leading: const Icon(Icons.room_preferences),
                      title: textView('$hall -- Hall', 15),
                      onTap: () => {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.event),
                      title: textView('$exam ', 15),
                      onTap: () => {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.date_range),
                      title: textView('$date --- $slot', 15),
                      subtitle: textView(
                        'Time --- $time',
                        15,
                      ),
                      onTap: () => {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.message),
                      title: textView('Message :  $message', 15),
                      onTap: () => {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
