import 'dart:convert';

import 'package:exam_cell_staff/config/ip.dart';
import 'package:exam_cell_staff/login.dart';
import 'package:exam_cell_staff/screens/reports/report_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

class SelectHall extends StatefulWidget {
  const SelectHall({super.key});

  @override
  State<SelectHall> createState() => _SelectHallState();
}

class _SelectHallState extends State<SelectHall> {
  _SelectHallState() {
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
                onTap: () {},
                title: textView('Hall : ${_dataList[index].hall}', 15),
                leading: Column(
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
                trailing: TextButton.icon(
                    onPressed: () async {
                      final _sharedprif = await SharedPreferences.getInstance();
                      await _sharedprif.setInt('alloc_id', _dataList[index].id);
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (ctx) {
                        return ReportForm();
                      }));
                    },
                    icon: Icon(Icons.report),
                    label: textView('Report', 15)),
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
}


// import 'dart:io';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';

// class MalpracticeReportForm extends StatefulWidget {
//   const MalpracticeReportForm({super.key});

//   @override
//   State<MalpracticeReportForm> createState() => _MalpracticeReportFormState();
// }

// class _MalpracticeReportFormState extends State<MalpracticeReportForm> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   TextEditingController _textController = TextEditingController();
//   File? _selectedFile;
//   List<String> _students = ['Alice', 'Bob', 'Charlie'];
//   String _selectedStudent = 'Select';

//   @override
//   void initState() {
//     super.initState();
//     _textController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     _textController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       setState(() {
//         _selectedFile = File(result.files.single.path!);
//       });
//     }
//   }

//   void _submitForm() {
//     if (_formKey.currentState != null && _formKey.currentState!.validate()) {
//       // TODO: handle form submission
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Report Malpractice'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               ElevatedButton(
//                 child: Text(_selectedFile == null
//                     ? 'Select File'
//                     : 'Selected: ${_selectedFile!.path}'),
//                 onPressed: _selectFile,
//               ),
//               TextFormField(
//                 controller: _textController,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a description of the malpractice';
//                   }
//                   return null;
//                 },
//                 decoration: InputDecoration(
//                   labelText: 'Description',
//                 ),
//               ),
//               ElevatedButton(
//                 child: Text('Submit'),
//                 onPressed: _submitForm,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
