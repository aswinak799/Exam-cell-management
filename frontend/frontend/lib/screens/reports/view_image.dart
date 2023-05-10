import 'package:frontend/config/ip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ViewImage extends StatelessWidget {
  const ViewImage({super.key, required this.image});
  final image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Image.network('http://$MY_IP:8000/$image'),
      )),
    );
  }
}
