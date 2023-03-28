import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// const MY_IP = '192.168.71.152';
const MY_IP = '192.168.1.33';
// const MY_IP = '192.168.29.52';
// const MY_IP = '192.168.103.173';
// const MY_IP = '192.168.198.173';

Text textView(
  String txt,
  int size,
) {
  double myDouble = double.parse(size.toString());

  return Text(
    txt,
    style: GoogleFonts.aladin(
      fontWeight: FontWeight.bold,
      fontSize: myDouble,
    ),
  );
}
