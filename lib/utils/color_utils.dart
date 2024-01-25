import 'package:flutter/material.dart';

// A function to convert a given hex string to a Color object
hexStringtoColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  // Parse the hex string as an integer with base 16 (hexadecimal) and return the corresponding Color object
  return Color(int.parse(hexColor, radix: 16));
}
