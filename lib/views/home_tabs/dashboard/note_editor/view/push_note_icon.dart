import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yuyan_app/util/util.dart';

class PushNoteIcon extends StatelessWidget {
  final void Function() onPressed;
  const PushNoteIcon({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.send_sharp,
        color: Colors.white,
      ),
      label: Text(
        '发布',
        style: Get.theme.primaryTextTheme.bodyText1,
      ),
    );
  }
}
