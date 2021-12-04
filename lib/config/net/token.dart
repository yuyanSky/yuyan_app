import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yuyan_app/config/app.dart';
import 'package:yuyan_app/config/net/base.dart';
import 'package:yuyan_app/config/storage_manager.dart';

class TokenJsonSeri {
  // APIv2 X-Auth-Token
  late String accessToken;

  // x-csrf-token
  late String cToken;
  // _yuque_session
  late String session;

  // cookie backup
  late String allCookie;

  TokenJsonSeri.fromJson(Map json) {
    if (json['error'] != null) {
      throw 'error: ${json['error']} ${json['error_description']}';
    }

    accessToken = json['access_token'];
    // try load from store
    allCookie = json['all_cookie'];
    session = json['session'];
    cToken = json['ctoken'];
  }

  loadCookies(String cookie) {
    allCookie = cookie;

    List<String> cookiesList =
        cookie.substring(0, cookie.length - 1).split(";");
    Map<String, String> cookieData = {};

    for (var cookie in cookiesList) {
      var arr = cookie.split("=");
      var key = arr[0].trim(), val = arr[1].trim();
      cookieData[key] = val;
    }

    debugPrint(cookieData['_yuque_session']);
    debugPrint(cookieData['_TRACERT_COOKIE__SESSION']);
    cToken = cookieData['yuque_ctoken']!;
    session = cookieData['_yuque_session']!;
  }

  loadCookies2(List<Cookie> cookies) {
    allCookie = cookies.map((k) => '${k.name}=${k.value}').join(';');
    cookies.forEach((cookie) {
      final n = cookie.name;
      final v = cookie.value;
      switch (n) {
        case "_yuque_session":
          session = v;
          break;
        case "yuque_ctoken":
          cToken = v;
          break;
      }
    });
  }

  String getCookie() {
    return '_yuque_session=$session;yuque_ctoken=$cToken;lang=zh-cn';
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'session': session,
        'ctoken': cToken,
        'all_cookie': allCookie,
      };
}

class TokenProvider extends BaseSaveJson<TokenJsonSeri> {
  bool get isLogin =>
      !isNullOrEmpty! && data.accessToken != null && data.session != null;

  @override
  String get key => 'token';

  @override
  TokenJsonSeri convert(json) {
    return TokenJsonSeri.fromJson(json);
  }
}

// used for api
// Header
// X-Auth-Token: access-token;
// Cookie: _yuque_session={};yuque_ctoken={};lang=zh-cn
// x-csrf-token: yuque_ctoken
mixin TokenMixin on BaseHttp {
  var token = App.tokenProvider;

  init() {
    super.init();
    debugPrint('init TokenMixin');
    setToken(token.data);
    token.addListener(() {
      debugPrint("!!!! change of token !!!!");
      setToken(token.data);
    });
  }

  setToken(TokenJsonSeri token) {
    options.headers['X-Auth-Token'] = token.accessToken;
    options.headers['Cookie'] = token.getCookie();
    options.headers['x-csrf-token'] = token.cToken;
  }
}

mixin OrganizationMixin on BaseHttp {
  // var spaceProvider = App.currentSpaceProvider;
  late String _defaultBaseUrl;

  init() {
    super.init();
    _defaultBaseUrl = options.baseUrl;
    debugPrint('_defaultBaseUrl => $_defaultBaseUrl');
    // 初始化orgSpace
    // debugPrint('init OrganizationMixin');
    // setOrgSpace(spaceProvider.data?.login);
    // spaceProvider.addListener(() {
    //   debugPrint('!!!! change of organization !!!!!');
    //   setOrgSpace(spaceProvider.data?.login);

    //   App.analytics.logEvent(
    //     name: 'change_org_space',
    //     parameters: spaceProvider.data?.toJson(),
    //   );
    // });
  }

  setOrgSpace(String space) {
    debugPrint("change namespace: $space");
    options.baseUrl = _defaultBaseUrl;
    // if (spaceProvider.isDefault) {
    //   options.baseUrl = _defaultBaseUrl;
    // } else {
    //   options.baseUrl = _defaultBaseUrl.replaceFirst("www", space);
    // }
  }
}
