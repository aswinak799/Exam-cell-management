import 'dart:convert';

import 'package:exam_cell_staff/config/LocalNotificationHelper.dart';
import 'package:exam_cell_staff/config/ip.dart';
import 'package:exam_cell_staff/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyData {
  final int id;
  final String hall;
  final String date;
  final String exam;
  final String slot;

  MyData({
    required this.id,
    required this.hall,
    required this.date,
    required this.exam,
    required this.slot,
  });
}

class Allocation extends StatefulWidget {
  const Allocation({super.key});

  @override
  State<Allocation> createState() => _AllocationState();
}

class _AllocationState extends State<Allocation> {
  _AllocationState() {
    getAllocation();
  }

  List<MyData> _dataList = [];

  Future<void> getAllocation() async {
    final _sharedprif = await SharedPreferences.getInstance();
    // String nameStaff = _sharedprif.getString('name').toString();
    int id = _sharedprif.getInt('id') ?? 0;
    String idString = id.toString();
    List<MyData> dataList = [];
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://$MY_IP:8000/get_allocation'));

    request.fields['id'] = idString;
    var response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final data = json.decode(body);
      for (var data in data['alloc_list']) {
        dataList.add(MyData(
          id: data['id'],
          hall: data['hall'],
          date: data['date'],
          exam: data['exam'],
          slot: data['slot'],
        ));
      }
      if (mounted) {
        setState(() {
          _dataList = dataList;
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
    return ListView.separated(
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                onTap: () {
                  bottomSheet(
                    _dataList[index].hall,
                    _dataList[index].date,
                    _dataList[index].exam,
                    _dataList[index].slot,
                  );
                },
                title: textView('Hall : ${_dataList[index].hall}', 15),
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.greenAccent,
                ),
                trailing: Column(
                  children: [
                    textView(
                      '${_dataList[index].slot} ',
                      13,
                    ),
                    textView(
                      '${_dataList[index].date} ',
                      13,
                    ),
                  ],
                ),
                subtitle: textView('${_dataList[index].exam} ', 13),
              ),
            ),
          );
        },
        separatorBuilder: ((context, index) {
          return SizedBox(
            height: 5,
          );
        }),
        itemCount: _dataList.length);
  }

  Future<void> bottomSheet(
    String hall,
    String date,
    String exam,
    String slot,
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
          height: 500,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 217, 221, 225),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              right: 25,
              left: 25,
              top: 50,
              bottom: 30,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    textView('DUTY ASSIGNED', 40),
                    textView('-------------', 40),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      leading: const Icon(Icons.room_preferences),
                      title: textView('$hall -- Hall', 20),
                      onTap: () => {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.event),
                      title: textView('$exam ', 20),
                      onTap: () => {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.date_range),
                      title: textView('$date --- $slot', 20),
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
