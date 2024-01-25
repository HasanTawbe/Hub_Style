import 'package:flutter/material.dart';

class Circle extends StatelessWidget {
  const Circle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 10,
        width: 10,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white54,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 3),
              )
            ]),
      ),
    );
  }
}
