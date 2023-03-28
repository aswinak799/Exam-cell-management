import 'dart:convert';

import 'package:exam_cell_staff/config/ip.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:exam_cell_staff/login.dart';
import 'package:exam_cell_staff/screens/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class MyData {
  final int id;
  final String student;

  MyData({
    required this.id,
    required this.student,
  });
}

class ReportForm extends StatefulWidget {
  const ReportForm({super.key});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  _ReportFormState() {
    _getStudents();
  }
  final _formKey = GlobalKey<FormState>();
  final _textCntrl = TextEditingController();
  String _textFieldValue = '';
  int? _dropDownValue;
  File? _selectedFile;

  void _pickFile() async {
    final ImagePicker _picker = ImagePicker();
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    } else {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
        });
      }
    }
  }

  List<MyData> _dataList = [];

  Future<void> _getStudents() async {
    List<MyData> dataList = [];
    final _sharedprif = await SharedPreferences.getInstance();
    int alloc_id = _sharedprif.getInt('alloc_id') ?? 0;
    String idString = alloc_id.toString();
    int id = _sharedprif.getInt('id') ?? 0;
    String id_staff_String = id.toString();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://$MY_IP:8000/get_students'),
    );

    request.fields['alloc_id'] = idString;
    request.fields['staff_id'] = id_staff_String;

    var response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final data = json.decode(body);
      for (var data in data['students']) {
        dataList.add(MyData(
          id: data['id'],
          student: data['student'],
        ));
      }
      setState(() {
        _dataList = dataList;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Process form data here
      _textFieldValue = _textCntrl.text.toString();
      print('Text field value: $_textFieldValue');
      if (_selectedFile != null) {
        print('Selected file path: ${_selectedFile!.path}');
        _reportMalpractice();
      }
    }
  }

  void _reportMalpractice() async {
    if (_formKey.currentState!.validate()) {
      _textFieldValue = _textCntrl.text.toString();
      if (_selectedFile != null) {
        final _sharedprif = await SharedPreferences.getInstance();
        int alloc_id = _sharedprif.getInt('alloc_id') ?? 0;
        String idString = alloc_id.toString();
        int id = _sharedprif.getInt('id') ?? 0;
        String id_staff_String = id.toString();
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://$MY_IP:8000/report_mal_practice'),
        );
        var file =
            await http.MultipartFile.fromPath('image', _selectedFile!.path);
        request.files.add(file);
        request.fields['message'] = _textFieldValue;
        request.fields['alloc_id'] = idString;
        request.fields['staff_id'] = id_staff_String;
        request.fields['student_id'] = _dropDownValue.toString();

        var response = await request.send();
        if (response.statusCode == 200) {
          final body = await response.stream.bytesToString();
          final data = json.decode(body);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: textView(data['message'], 15),
            margin: const EdgeInsets.all(20),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.greenAccent,
          ));
          Navigator.of(context).pop();
        } else {
          final body = await response.stream.bytesToString();
          final data = json.decode(body);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: textView(data['message'], 15),
            margin: const EdgeInsets.all(20),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          padding: const EdgeInsets.all(38.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                textView('REPORT MALPRACTICE', 40),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  maxLength: 1000,
                  style: GoogleFonts.aladin(fontWeight: FontWeight.bold),
                  controller: _textCntrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelStyle: GoogleFonts.aladin(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    labelText: 'Message',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _textFieldValue = value!;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelStyle: GoogleFonts.aladin(),
                      border: OutlineInputBorder(),
                      labelText: 'Select an option',
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "Please select any student";
                      }
                    },
                    style: GoogleFonts.aladin(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    hint: textView(
                      'Select student',
                      15,
                    ),
                    items: _dataList.map((e) {
                      return DropdownMenuItem(
                        child: Text(
                          e.student,
                          style: GoogleFonts.aladin(fontSize: 12),
                        ),
                        value: e.id,
                      );
                    }).toList(),
                    onChanged: ((value) {
                      _dropDownValue = value;
                    })),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    ElevatedButton.icon(
                      label: textView(
                        'add File',
                        18,
                      ),
                      icon: Icon(Icons.add_a_photo),
                      onPressed: _pickFile,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.indigo),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white60),
                        overlayColor:
                            MaterialStateProperty.all(Colors.deepPurple),
                        shadowColor:
                            MaterialStateProperty.all(Colors.greenAccent),
                        elevation: MaterialStateProperty.all(20),
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(10)),
                        minimumSize:
                            MaterialStateProperty.all(const Size(150, 20)),
                        animationDuration: const Duration(
                          milliseconds: 2000,
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 25.0),
                    Text(_selectedFile != null ? '' : 'No file selected'),
                    SizedBox(height: 16.0),
                    _selectedFile != null
                        ? Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(_selectedFile!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text('Submit'),
                  onPressed: _submit,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.indigo),
                    foregroundColor: MaterialStateProperty.all(Colors.white60),
                    overlayColor: MaterialStateProperty.all(Colors.deepPurple),
                    shadowColor: MaterialStateProperty.all(Colors.greenAccent),
                    elevation: MaterialStateProperty.all(20),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(10)),
                    minimumSize: MaterialStateProperty.all(const Size(150, 20)),
                    animationDuration: const Duration(
                      milliseconds: 2000,
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
