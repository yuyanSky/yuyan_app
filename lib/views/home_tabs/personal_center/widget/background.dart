import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

buildBackground(ThemeData theme) {
  return Positioned(
    top: 0,
    child: ClipPath(
      clipper: ArcClipper(),
      child: Container(
        height: Get.height * 0.33,
        width: Get.width,
        decoration: BoxDecoration(
          color: theme.primaryColor,
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.primaryColor.withAlpha(60),
            ],
            begin: FractionalOffset(0, 0),
            end: FractionalOffset(0, 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(55, 0, 0, 0),
              offset: Offset(1, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    ),
  );
}
