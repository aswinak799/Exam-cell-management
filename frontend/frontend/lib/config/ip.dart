import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// const MY_IP = '192.168.188.152';
// const MY_IP = '192.168.1.33';
const MY_IP = '192.168.29.52';


// const MY_IP = '192.168.58.173';
// const MY_IP = '192.168.198.173';
// const MY_IP = '192.168.230.173';

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

Padding loadingWidget() {
  return Padding(
    padding: const EdgeInsets.only(top: 250,bottom: 250,left: 140,right: 140),
    child: CircularProgressIndicator(
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      strokeWidth: 6.0,


    ),
  );
}
