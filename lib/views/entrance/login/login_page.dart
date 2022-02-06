import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yuyan_app/controller/home/login_controller.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _completer = Completer<WebViewController>();
  late final LoginController login;

  @override
  void initState() {
    super.initState();
    login = Get.put(LoginController(_completer.future));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "登录语雀",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: WebView(
        initialUrl: login.authUrl,
        onWebViewCreated: (controller) {
          _completer.complete(controller);
        },
        onPageFinished: login.onUrlChanged,
        onPageStarted: login.onUrlChanged,
        onProgress: (progress) {},
        onWebResourceError: (err) {},
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );

    // return GetBuilder<LoginController>(
    //   builder: (c) => Scaffold(
    //     // userAgent: Config.userAgent,
    //     // url: c.authUrl,
    //     body: WebView(
    //       onWebViewCreated: (controller) {},
    //       initialUrl: c.authUrl,
    //     ),
    //     appBar: AppBar(
    //       backgroundColor: Colors.white,
    //       title: Text(
    //         "登录语雀",
    //         style: TextStyle(
    //           color: Colors.black,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
