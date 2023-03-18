import 'package:exam_cell_staff/config/ip.dart';
import 'package:exam_cell_staff/main.dart';
import 'package:exam_cell_staff/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCntrlr = TextEditingController();
  final _passwdCntrlr = TextEditingController();

  @override
  void dispose() {
    _userCntrlr.dispose();
    _passwdCntrlr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 229, 234),
      body: SafeArea(
          child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.only(
            right: 30.0,
            left: 30,
            top: 120,
            bottom: 30,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 30, bottom: 10),
                  child: Image.asset('asset/kmct.png'),
                ),
                Center(
                  child: textView(
                    'LOGIN',
                    30,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _userCntrlr,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Username';
                    } else if (!RegExp(r'^KTU-F\d{3,}$').hasMatch(value)) {
                      return 'Please enter a valid value (e.g. KTU-F123)';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  obscureText: true,
                  controller: _passwdCntrlr,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (!RegExp(
                            r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).{8,}$')
                        .hasMatch(value)) {
                      return 'Enter a valid value (e.g. Abcd@123 8 characters must)';
                    }

                    return null;
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      String username = _userCntrlr.text.toString();
                      String passwd = _passwdCntrlr.text.toString();
                      login(
                        username,
                        passwd,
                        context,
                      ); // handle form submission
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: textView('Login', 25),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.indigo),
                    foregroundColor: MaterialStateProperty.all(Colors.black54),
                    overlayColor: MaterialStateProperty.all(Colors.deepPurple),
                    shadowColor: MaterialStateProperty.all(Colors.greenAccent),
                    elevation: MaterialStateProperty.all(20),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(10)),
                    minimumSize: MaterialStateProperty.all(
                        const Size(double.maxFinite, 20)),
                    animationDuration: const Duration(
                      milliseconds: 5000,
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
      )),
    );
  }

  //
  Future<void> login(String username, String password, BuildContext ctx) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://$MY_IP:8000/staff_login'));
    final Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
    };
    request.headers.addAll(headers);

    request.fields['username'] = username;
    request.fields['password'] = password;
    var response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final data = json.decode(body);
      final _sharedPref = await SharedPreferences.getInstance();
      await _sharedPref.setBool(SAVE_KEY_NAME, true);
      await _sharedPref.setInt('id', data['id']);
      await _sharedPref.setString('name', data['name']);
      await _sharedPref.setString('type', data['type']);
      Navigator.of(ctx).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) {
            return HomeScreen();
          },
        ),
      );
    } else {
      const error = "Incorrect Username Or Password";
      //Snackbar.
      // ignore: prefer_const_constructors
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: textView(error, 15),
        margin: const EdgeInsets.all(20),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ));
    }
  }
}
//

// import 'package:exam_cell_staff/config/ip.dart';
// import 'package:flutter/material.dart';

// class NewReport extends StatefulWidget {
//   const NewReport({super.key});

//   @override
//   State<NewReport> createState() => _NewReportState();
// }

// class _NewReportState extends State<NewReport> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20.0),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Center(
//               child: textView(
//                 'LOGIN',
//                 30,
//               ),
//             ),
//             SizedBox(height: 20.0),
//             TextFormField(
//               controller: _emailController,
//               decoration: InputDecoration(
//                 labelText: 'Email',
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your email';
//                 } else if (!RegExp(r'^KTU-F\d{3,}$').hasMatch(value)) {
//                   return 'Please enter a valid value (e.g. KTU-F123)';
//                 }
//                 return null;
//               },
//             ),
//             SizedBox(height: 10.0),
//             TextFormField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your password';
//                 } else if (!RegExp(
//                         r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).{8,}$')
//                     .hasMatch(value)) {
//                   return 'Enter a valid value (e.g. Abcd@123 8 characters must)';
//                 }

//                 return null;
//               },
//             ),
//             SizedBox(height: 20.0),
//             ElevatedButton(
//               onPressed: () {
//                 if (_formKey.currentState != null &&
//                     _formKey.currentState!.validate()) {
//                   // handle form submission
//                 }
//               },
//               child: Text(
//                 'Login',
//                 style: TextStyle(
//                   fontSize: 20.0,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
