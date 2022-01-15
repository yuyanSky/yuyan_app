import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info/package_info.dart';

// import 'package:webview_flutter/webview_flutter.dart' as web;
import 'package:yuyan_app/config/net/token.dart';
import 'package:yuyan_app/config/storage_manager.dart';
import 'package:yuyan_app/controller/home/personal/my_controller.dart';
import 'package:yuyan_app/controller/organization/organization_controller.dart';

class App {
  static TokenProvider tokenProvider = TokenProvider();
  static CurrSpaceProvider currentSpaceProvider = CurrSpaceProvider();
  static MyUserProvider userProvider = MyUserProvider();
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static PackageInfo version;

  static init() async {
    version = await PackageInfo.fromPlatform();

    await StorageManager.init();

    // web.WebView.platform = web.SurfaceAndroidWebView();

    // if(Platform.isAndroid){
    //   await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    // }

    analytics.logEvent(
      name: 'app_open',
      parameters: {
        'appName': version.appName,
        'version': version.version,
        'build': version.buildNumber,
        'package': version.packageName,
      },
    );
  }
}

class Config {
  static const String userAgent =
      r'Mozilla/5.0 AppleWebKit/537.36 Chrome/88.0.4324.181 Mobile Safari/537.36 Yuyan';
  static const String clientId = r'eeqJ55wPXkjEJZujqEQh';
  static const String clientSecret =
      r'cUqsOf2mnphsHKEpsJLHWXrsu8oPwtnBxPStbD9f';
  static const String iOStore =
      "https://apps.apple.com/cn/app/%E8%AF%AD%E7%87%95app/id1502617331";

  static get webview => InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          mediaPlaybackRequiresUserGesture: false,
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
        ),
        ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
        ),
      );
}
