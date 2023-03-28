import 'package:exam_cell_staff/config/ip.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MalPractice extends StatefulWidget {
  const MalPractice({super.key});

  @override
  State<MalPractice> createState() => _MalPracticeState();
}

class _MalPracticeState extends State<MalPractice> {
  @override
  Widget build(BuildContext context) {
    return textView("Malpractice Notification", 30);
  }
}
