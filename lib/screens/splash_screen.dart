// ignore_for_file: camel_case_types, duplicate_ignore

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hub_style/reusable_widgets/circle.dart';
import 'package:hub_style/reusable_widgets/reusable_widget.dart';
import 'package:hub_style/screens/home_screen.dart';
import '../utils/color_utils.dart';

// ignore: camel_case_types
class Splash_Screen extends StatefulWidget {
  const Splash_Screen({Key? key}) : super(key: key);

  @override
  State<Splash_Screen> createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _dot1Animation;
  late Animation<double> _dot2Animation;
  late Animation<double> _dot3Animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _dot1Animation =
        Tween<double>(begin: 1, end: 2).animate(_animationController);
    _dot2Animation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0),
      ),
    );
    _dot3Animation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0),
      ),
    );

    // Start the timer to navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringtoColor("535353"),
              hexStringtoColor("373737"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20.0,
              MediaQuery.of(context).size.height * 0.1,
              20.0,
              0,
            ),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 150,
                ),
                Center(
                  child: logoWidget("assets/images/StyleHubLogo.png"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _dot1Animation.value,
                          child: child,
                        );
                      },
                      child: const Circle(),
                    ),
                    const SizedBox(width: 20),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _dot2Animation.value,
                          child: child,
                        );
                      },
                      child: const Circle(),
                    ),
                    const SizedBox(width: 20),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _dot3Animation.value,
                          child: child,
                        );
                      },
                      child: const Circle(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
