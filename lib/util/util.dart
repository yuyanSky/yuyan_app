import 'dart:io';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yuyan_app/config/route_manager.dart';
import 'package:yuyan_app/config/service/api_repository.dart';
import 'package:yuyan_app/controller/global/upload_controller.dart';
import 'package:yuyan_app/controller/theme_controller.dart';
import 'package:yuyan_app/model/dashboard/quick_link_seri.dart';
import 'package:yuyan_app/model/document/toc/toc_seri.dart';
import 'package:yuyan_app/models/component/appUI.dart';

class Util {
  static Future<String> editorImageUploadCallback(File file) async {
    var res = await ApiRepository.postAttachFile(path: file.path);
    return res.url;
  }

  static futureWrap<T>(
    Future future, {
    Function(T) onData,
    Function(dynamic) onError,
  }) async {
    try {
      var data = await future;
      onData?.call(data);
    } catch (err) {
      onError?.call(err);
      debugPrint('futureWrap catch error: $err');
    }
  }

  static List<TreeNode> parseTocTree(List<TocSeri> data) {
    Map<String, TocSeri> map = {};
    data.forEach((toc) {
      map[toc.uuid] = toc;
    });

    Function(TreeNode, TocSeri) _parse;
    _parse = (TreeNode parent, TocSeri child) {
      var node = TreeNode(
        content: Text('${child.title}'),
        children: [],
      ); //确保children已经初始化了
      parent.children.add(node); //将自己添加进入父节点
      var nc = map[child.childUuid];
      if (nc != null) {
        //现在这个节点充当父节点
        //进行递归，优先处理子节点
        _parse(node, nc);
      }
      //第一个兄弟节点
      var sib = map[child.siblingUuid];
      while (sib != null) {
        var sibNode = TreeNode(
          content: Text('${sib.title}'),
          children: [],
        );
        parent.children.add(sibNode);
        var nc = map[sib.childUuid];
        if (nc != null) {
          _parse(sibNode, nc);
        }
        //下一个兄弟节点
        sib = map[sib.siblingUuid];
      }
    };

    var root = TreeNode(children: []);
    _parse(root, data.first);
    return root.children;
  }

  static toast(String text) {
    BotToast.showCustomText(
      onlyOne: true,
      duration: Duration(seconds: 2),
      toastBuilder: (cancel) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: ThemeController.to.primarySwatchColor,
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(55, 0, 0, 0),
                offset: Offset(1, 2),
                blurRadius: 4,
              ),
            ],
            borderRadius: BorderRadius.circular(32.0),
          ),
          child: Text(
            "$text",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  static goUrl(String url) {
    MyRoute.webview('https://www.yuque.com' + url);
  }

  static launchURL(String url) {
    futureWrap(
      canLaunch(url),
      onData: (value) {
        if (value) {
          launch(url);
        } else {
          Util.toast('cannot open: $url');
        }
      },
    );
  }

  static handleQuickLinkNav(QuickLinkSeri link) {
    switch (link.type) {
      case 'Doc':
        // MyRoute.docDetail(bookId: link.targetId, slug: link);
        break;
      case 'Book':
        // MyRoute.bookDocs(link);
        break;
      case 'Group':
        // MyRoute.group(group: null);
        break;
      case 'User':
        // MyRoute.user(user: null);
        break;
      default:
        MyRoute.webview(link.url);
    }
  }

  static String genHeroTag() {
    String tag = DateTime.now().microsecondsSinceEpoch.toString();
    return tag;
  }

  static String timeCut(String time) {
    DateTime thatTime = DateTime.parse(time);
    DateTime nowTime = DateTime.now();
    var difference = nowTime.difference(thatTime);
    String passTime = (difference.inDays > 1)
        ? difference.inDays.toString() + " 天前"
        : (difference.inMinutes > 60)
            ? difference.inHours.toString() + " 小时前"
            : (difference.inMinutes > 1)
                ? difference.inMinutes.toString() + " 分钟前"
                : (difference.inSeconds > 1)
                    ? difference.inSeconds.toString() + " 秒前"
                    : "一瞬间前";
    return passTime;
  }

  static ossImg(String imgUrl) {
    final String suffix =
        "?x-oss-process=image%2Fresize%2Cm_fill%2Cw_120%2Ch_120%2Fformat%2Cpng";
    // 如果不包含某些关键词 则使用压缩模式
    if (imgUrl == null) {
      return null;
    }
    if (imgUrl.contains("dingtalk") ||
        imgUrl.contains("aliyuncs") ||
        imgUrl.contains("alipay") ||
        imgUrl.contains("assets/") ||
        imgUrl.contains("x-oss-process")) {
      return imgUrl;
    } else {
      return imgUrl + suffix;
    }
  }

  // static String clearText(String text) {
  //   // RegExp exp = new RegExp(r'<[^>]+>'); // html
  //   RegExp emojiReg = RegExp(
  //       r"\ud83c[\udf00-\udfff] | \ud83d[\udc00-\ude4f] | \ud83d[\ude80-\udeff]"); // emoji
  //   String ret = text.replaceAll(emojiReg, '').replaceAll('\n', '');
  //   return ret;
  // }

  static String stringClip(String str, int max, {bool ellipsis = false}) {
    var length = str.runes.length;
    if (length > max) {
      var result = runeSubstring(str, 0, max); //.substring(0, max);
      if (ellipsis) {
        result += '...';
      }
      return result;
    }
    return str;
  }

  //#35798 see https://github.com/dart-lang/sdk/issues/35798
  static String runeSubstring(String input, int start, int end) {
    return String.fromCharCodes(input.runes.toList().sublist(start, end));
  }

  static Widget animationTypeBuild({int type = 1, Widget child}) {
    switch (type) {
      case 1:
        return FadeInAnimation(child: child);
      case 2:
        return SlideAnimation(child: child);
      case 3:
        return ScaleAnimation(child: child);
      default:
        return FlipAnimation(child: child);
    }
  }

  // 使用参考：https://juejin.cn/post/6844903822028963847
  static showWindow({String title, @required Widget child}) {
    Get.dialog(
      SimpleDialog(
        contentPadding: EdgeInsets.only(left: 10, right: 10, bottom: 12),
        title: Row(
          children: [
            Text(
              title ?? 'Dialog',
              style: AppStyles.textStyleB,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.close),
                ),
              ),
            )
          ],
        ),
        titlePadding: EdgeInsets.fromLTRB(26, 8, 10, 0),
        backgroundColor: AppColors.background,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        children: [
          child,
        ],
      ),
    );
  }

  static String getUrlBaseNameWithSplash(String url) {
    return url.substring(url.lastIndexOf('/'));
  }
}

extension StringEx on String {
  static Map<String, String> eventType = {
    //前后端都不统一规范下，吐了>
    "updateDoc": "更新了文档",
    "publishDoc": "发布了文章",
    "update_doc": "更新了文档",
    "like_doc": "打赏了稻谷",
    "publish_doc": "发布了文章",
    "watch_book": "关注了知识库",
    "follow_user": "关注了雀友",
    "like_artboard": "给画板赞赏了稻谷",
    "upload_artboards": "更新了画板"
  };

  String transEvent() {
    return eventType[this] ?? '未知事件';
  }

  String clip(int max, {bool ellipsis = false}) {
    return Util.stringClip(this, max, ellipsis: ellipsis);
  }

  DateTime toDateTime() {
    return DateTime.tryParse(this);
  }
}

extension ListEx<T> on List<T> {
  T rand() {
    final _random = new Random();
    var item = this[_random.nextInt(this.length)];
    return item;
  }
}

extension NumEx<T extends num> on List<T> {
  T sum() {
    return this.reduce((a, b) => a + b);
  }
}

extension IterEx<T extends num> on Iterable<T> {
  T sum() {
    return this.reduce((a, b) => a + b);
  }
}
