import 'dart:convert';

import 'package:frontend/config/ip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  _EditProfileState() {
    getProfile();
  }
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  String name = '';
  String sid = "";
  bool isLoading = true;

  Future<void> getProfile() async {
    final _sharedprif = await SharedPreferences.getInstance();
    String nameStaff = _sharedprif.getString('name').toString();
    int id = _sharedprif.getInt('id') ?? 0;
    String idString = id.toString();
    sid = idString;
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://$MY_IP:8000/get_staff'));

    request.fields['id'] = idString;
    var response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final data = json.decode(body);
      print(data['name']);
      print("***************************************");
      if (mounted) {
        setState(() {
          name = data['name'];
          _nameController.text = name;
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sever error'),
        margin: EdgeInsets.all(20),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.fromARGB(255, 255, 74, 64),
      ));
    }
  }

  Future<void> editProfile(String value) async {
    // final _sharedprif = await SharedPreferences.getInstance();
    // String nameStaff = _sharedprif.getString('name').toString();
    // int id = _sharedprif.getInt('id') ?? 0;
    // String idString = id.toString();
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://$MY_IP:8000/edit_staff_app'));

    request.fields['id'] = sid;
    request.fields['name'] = value;
    var response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            textView('Successfully Edited', 20),
          ],
        ),
        margin: const EdgeInsets.all(20),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.greenAccent,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sever error'),
        margin: EdgeInsets.all(20),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.fromARGB(255, 255, 74, 64),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading? loadingWidget() :
    Padding(
      padding: const EdgeInsets.all(40.0),
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        shadowColor: Colors.indigoAccent,
        clipBehavior: Clip.hardEdge,
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: textView(
                    'EDIT PROFILE',
                    30,
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  style: GoogleFonts.aladin(fontWeight: FontWeight.bold),
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelStyle: GoogleFonts.aladin(
                        fontWeight: FontWeight.bold, fontSize: 20),
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10.0),
                SizedBox(height: 20.0),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: textView(
                              'Exam Cell Kmct',
                              25,
                            ),
                            content: textView(
                              'Are you sure to change the name ?',
                              18,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  editProfile(_nameController.text
                                      .trim()); // Do something when OK is pressed
                                  Navigator.of(context).pop();
                                },
                                child: textView('OK', 15),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Do something when Cancel is pressed
                                  Navigator.of(context).pop();
                                },
                                child: textView('Cancel', 15),
                              ),
                            ],
                          );
                        },
                      ); // handle form submission
                    }
                  },
                  icon: Icon(Icons.edit),
                  label: textView('Edit', 25),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.indigo),
                    foregroundColor: MaterialStateProperty.all(Colors.black54),
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
                        borderRadius: BorderRadius.circular(18),
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
