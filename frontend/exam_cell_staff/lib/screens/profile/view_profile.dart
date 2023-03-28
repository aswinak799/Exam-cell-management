import 'dart:convert';
import 'package:exam_cell_staff/config/LocalNotificationHelper.dart';
import 'package:exam_cell_staff/config/ip.dart';
import 'package:exam_cell_staff/login.dart';
import 'package:exam_cell_staff/screens/notification/allocation.dart';
import 'package:exam_cell_staff/screens/profile/change_password.dart';
import 'package:exam_cell_staff/screens/profile/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  _ViewProfileState() {
    viewProfile();
  }
  late final NotificationService notificationService;
  @override
  void initState() {
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();

    super.initState();
  }

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Allocation()));
      });

  Future<void> notify() async {
    await notificationService.showLocalNotification(
        id: 0,
        title: "EXAMCELL KMCT",
        body: "YOU WHERE ALLOCATED NEW DUTY",
        payload: "You just took water! Huurray!");
  }

  String name = "";
  String dept = "";
  String type = "";
  String ktuID = "";
  // final _name = TextEditingController();
  // final _formKey1 = GlobalKey<FormState>();
  Future<void> viewProfile() async {
    final _sharedprif = await SharedPreferences.getInstance();
    String nameStaff = _sharedprif.getString('name').toString();
    int id = _sharedprif.getInt('id') ?? 0;
    String idString = id.toString();
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://$MY_IP:8000/get_staff'));

    request.fields['id'] = idString;
    var response = await request.send();
    if (response.statusCode == 200) {
      notify();
      final body = await response.stream.bytesToString();
      final data = json.decode(body);
      if (mounted) {
        setState(() {
          name = data['name'];
          dept = data['dept'];
          ktuID = data['ktu_id'];
          type = data['type'];
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sever error'),
        margin: EdgeInsets.all(20),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.fromARGB(255, 255, 74, 64),
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
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          shadowColor: Colors.indigoAccent,
          clipBehavior: Clip.hardEdge,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                maxRadius: 50,
                backgroundImage: NetworkImage(
                    'http://$MY_IP:8000/media/4cea42da8523fa2ca17a60574042d169.png '),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department),
                  Text(
                    name,
                    style: GoogleFonts.aladin(
                      fontSize: 40.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_fire_department),
                  Text(
                    ktuID,
                    style: GoogleFonts.aladin(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_fire_department),
                  Text(
                    type,
                    style: GoogleFonts.aladin(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_fire_department),
                  SizedBox(width: 8.0),
                  Text(
                    'Department Of $dept',
                    style: GoogleFonts.aladin(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) {
                        return ChangePassword();
                      },
                    ),
                  ); // showBottomSheet(context);
                },
                icon: Icon(Icons.edit),
                label: textView('Change Password', 25),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.indigo),
                  foregroundColor: MaterialStateProperty.all(Colors.black54),
                  overlayColor: MaterialStateProperty.all(Colors.deepPurple),
                  shadowColor: MaterialStateProperty.all(Colors.greenAccent),
                  elevation: MaterialStateProperty.all(20),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
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
    );
  }
}
