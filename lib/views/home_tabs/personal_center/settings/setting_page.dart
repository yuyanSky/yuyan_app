import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yuyan_app/config/app.dart';
import 'package:yuyan_app/controller/app/theme_controller.dart';
import 'package:yuyan_app/controller/app/version_controller.dart';
import 'package:yuyan_app/util/util.dart';
import 'package:yuyan_app/views/entrance/login/login_page.dart';
import 'package:yuyan_app/views/home_tabs/personal_center/widget/one_tile.dart';

class SettingPage extends StatefulWidget {
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  checkVersion() {
    if ((Platform.isIOS)) {}
    Get.find<VersionController>().checkVersion(context);
  }

  @override
  Widget build(BuildContext context) {
    var version = Get.find<VersionController>();
    debugPrint('version check: latest: ${version.isLatest}');
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          // ChangeColorTile(),
          SettingTile(
            title: '神奇按键',
            icon: Icons.insert_emoticon,
            onTap: ThemeController.to.changeThemeColor,
          ),
          Obx(() {
            return SettingTile(
              title: '检查更新',
              icon: Icons.vertical_align_top,
              onTap: checkVersion,
              ifBadge: !version.isLatest,
            );
          }),
          SettingTile(
            title: '退出登录',
            icon: Icons.power_settings_new,
            onTap: () async {
              Util.showConfirmDialog(context, content: "确认要退出登录 ?",
                  confirmCallback: () async {
                App.analytics.logEvent(
                  name: 'logout',
                  parameters: {
                    'login': App.userProvider.data!.login,
                    'name': App.userProvider.data!.name,
                  },
                );

                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                CookieManager cookieManager = CookieManager();
                await cookieManager.clearCookies();
                Navigator.of(context).pushAndRemoveUntil(
                    new MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage(),
                    ),
                    (Route route) => route == null);
              });
            },
          ),
        ],
      ),
    );
  }
}
