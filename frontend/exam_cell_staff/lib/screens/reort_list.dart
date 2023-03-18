import 'package:flutter/material.dart';

class ReportList extends StatelessWidget {
  const ReportList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.separated(
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              shadowColor: Colors.indigoAccent,
              clipBehavior: Clip.hardEdge,
              color: Colors.white70,
              child: ListTile(
                title: Text('REPORT $index'),
                trailing:
                    IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 5,
            );
          },
          itemCount: 10),
    );
  }
}
