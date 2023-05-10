import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/config/ip.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MalData {
  final String image;
  final String date;
  final String hall;
  final int status;

  MalData({
    required this.image,
    required this.date,
    required this.hall,
    required this.status,
  });
}

class MalPractice extends StatefulWidget {
  const MalPractice({super.key});

  @override
  State<MalPractice> createState() => _MalPracticeState();
}

class _MalPracticeState extends State<MalPractice> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  List<MalData> _dataList = [];
  bool _isData =false;
  void initState() {
    super.initState();
    _getNotification();

    // Create an animation controller with duration of 300ms
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Create a scale animation
    _scaleAnimation = Tween<double>(begin: 0, end: 1.1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getNotification() async {
    final _sharedprif = await SharedPreferences.getInstance();
    int id = _sharedprif.getInt('id') ?? 0;
    String idString = id.toString();
    List<MalData> dataList = [];
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://$MY_IP:8000/get_mal_notification'));
    request.fields['id'] = idString;
    var response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final data = json.decode(body);

      // print("*********************************");

      for (var val in data['result']) {
        print(val);

        dataList.add(MalData(
          image: val[2],
          date: val[1],
          hall: val[7],
          status: val[3],
        ));
      }

      print("**********************************");
      if (mounted) {
        setState(() {
          _dataList = dataList;
          if (_dataList.length==0){
              _isData=true;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isData?Center(child: textView("No malpractice today", 25)) : ListView.separated(
        itemBuilder: (context, index) {
          return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: ListTile(
                title: textView("${_dataList[index].hall}", 30),
                leading: CircleAvatar(radius:20,
                    backgroundImage: NetworkImage(
                        "http://$MY_IP:8000/media/malimg/${_dataList[index].image}")
                ),
                subtitle: textView(_dataList[index].date, 15),
                // subtitle: textView(_dataList[index], 15),
              onTap: (){
                _controller.forward();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ScaleTransition(
                      scale: _scaleAnimation,
                      child: AlertDialog(backgroundColor: Colors.blue[100],
                        content:  ScaleTransition(
                            scale: _scaleAnimation,
                            child: Image.network("http://$MY_IP:8000/media/malimg/${_dataList[index].image}")),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {

                              Navigator.of(context).pop();
                              _controller.reverse();

                            },
                            child: textView('Close',22),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 5,
          );
        },
        itemCount: _dataList.length);
  }
}
