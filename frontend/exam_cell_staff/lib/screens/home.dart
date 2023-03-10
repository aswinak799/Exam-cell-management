import 'package:exam_cell_staff/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
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
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50.0,
              ),
              SizedBox(height: 16.0),
              Text(
                'Jhon',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Software Developer',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on),
                  SizedBox(width: 8.0),
                  Text(
                    'New York, NY',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.mail),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.phone),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.person_add),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
