import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_extend/share_extend.dart';
import 'package:yuyan_app/config/app.dart';
import 'package:yuyan_app/config/route_manager.dart';
import 'package:yuyan_app/config/service/api_repository.dart';
import 'package:yuyan_app/config/viewstate/view_state.dart';
import 'package:yuyan_app/config/viewstate/view_state_widget.dart';
import 'package:yuyan_app/controller/app/theme_controller.dart';
import 'package:yuyan_app/controller/organization/doc/doc_controller.dart';
import 'package:yuyan_app/model/user/user.dart';
import 'package:yuyan_app/util/styles/app_ui.dart';
import 'package:yuyan_app/util/util.dart';
import 'package:yuyan_app/views/widget/menu_item.dart';
import 'package:yuyan_app/views/widget/user_widget.dart';

import 'widget/doc_comment_widget.dart';
import 'widget/icon_button_widget.dart';

class DocDetailWebviewPage extends StatefulWidget {
  final String login;
  final String book;
  final int bookId;
  final String slug;

  const DocDetailWebviewPage({
    Key key,
    this.book,
    this.bookId,
    this.login,
    this.slug,
  }) : super(key: key);

  @override
  _DocDetailWebviewPageState createState() => _DocDetailWebviewPageState();
}

class _DocDetailWebviewPageState extends State<DocDetailWebviewPage> {
  final _param = 'view=doc_embed&from=yuyan&title=1&outline=1&enable_sw=false';

  String get tag => '${widget.login}/${widget.login}/${widget.slug}';

  String get embedUrl {
    return docUrl + '?' + _param;
  }

  String get docUrl {
    return 'https://www.yuque.com/${widget.login}/${widget.book}/${widget.slug}';
  }

  InAppWebViewController _webViewController;
  PullToRefreshController _pullToRefreshController;

  var visible = false.obs;
  var canScrollTop = false.obs;
  var minScrollHeight = 2000;
  var title = '文档详情'.obs;
  var showUser = true.obs;
  var fontSize = 15.0.obs;

  @override
  void initState() {
    super.initState();

    _pullToRefreshController = PullToRefreshController(
      onRefresh: () {
        _webViewController?.reload();
        debugPrint('refresh event !');
      },
    );

    Get.put(
      DocDetailController(
        bookId: widget.bookId,
        slug: widget.slug,
      ),
      tag: tag,
    );

    App.analytics.logEvent(
      name: 'view_doc_detail',
      parameters: {
        'type': 'webview',
        'url': docUrl,
      },
    );
  }

  Future<void> _injectJavascript() async {
    await _webViewController.evaluateJavascript(
      source: 'document.body.style.padding="16px";',
    );
    final js = '''
document.querySelectorAll('img[src]')
  .forEach(function (item) {
		console.log(item);
		item.onclick = function () {
			window.flutter_inappwebview.callHandler('showImage', item.outerHTML);
		};
});
    '''; // type: javascript
    await _webViewController.evaluateJavascript(source: js);
  }

  Widget _buildMoreAction() {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: () {
            MyRoute.webview(docUrl);
          },
          child: MenuItemWidget(
            iconData: Icons.open_in_browser,
            title: '打开网页版',
          ),
        ),
        PopupMenuItem(
          value: () {
            Util.launchURL(docUrl);
          },
          child: MenuItemWidget(
            iconData: Icons.open_in_new,
            title: '从浏览器打开',
          ),
        ),
        PopupMenuItem(
          value: () {
            FlutterClipboard.copy(docUrl).then((_) {
              Util.toast('已复制');
            });
          },
          child: MenuItemWidget(
            iconData: Icons.link,
            title: '复制文档链接',
          ),
        ),
        PopupMenuItem(
          value: () {
            MyRoute.webview(docUrl + '/markdown');
          },
          child: MenuItemWidget(
            iconData: Icons.chrome_reader_mode,
            title: 'Markdown',
          ),
        ),
        PopupMenuItem(
          value: () {
            Future.delayed(1.seconds, () {
              Util.toast('❤ 感谢你的反馈');
            });
          },
          child: MenuItemWidget(
            iconData: Icons.report,
            title: '举报文档',
          ),
        ),
        PopupMenuItem(
          value: () {
            ShareExtend.share(
              '我在【语燕】分享了语雀文档「${title.value}」快来瞧瞧！ $docUrl',
              'text',
            );
          },
          child: MenuItemWidget(
            iconData: Icons.share,
            title: '分享',
          ),
        ),
        if (kDebugMode)
          PopupMenuItem(
            value: _changeFontSize,
            child: MenuItemWidget(
              iconData: Icons.format_size,
              title: '字体大小',
            ),
          ),
      ],
      onSelected: (_) => _?.call(),
    );
  }

  @override
  Widget build(BuildContext context) {
    int _y = 0;
    final docBody = InAppWebView(
      // initialUrl: embedUrl,
      initialUrlRequest: URLRequest(url: Uri.parse(embedUrl)),
      pullToRefreshController: _pullToRefreshController,
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
        ),
      ),
      onWebViewCreated: (c) {
        _webViewController = c;
        c.addJavaScriptHandler(
          handlerName: 'showImage',
          callback: (args) {
            final frag = htmlparser.parseFragment(args.first);
            final attr = frag.nodes.first.attributes;
            final img = attr['data-raw-src'];
            Util.showImage(img);
          },
        );
      },
      onTitleChanged: (_, title) {
        this.title.value = title;
        debugPrint('title => $title');
      },
      onScrollChanged: (_, x, y) {
        var delta = y - _y;
        if (y > 100) {
          if (delta > 3) {
            showUser.value = false;
          } else if (delta < -3) {
            showUser.value = true;
          }
        }
        _y = y;
        canScrollTop.value = (y > minScrollHeight);
        // debugPrint('_y => $y');
      },
      onProgressChanged: (_, progress) {
        debugPrint('progress: $progress');
      },
      onDownloadStart: (_, url) {
        debugPrint('download => $url');
      },
      shouldOverrideUrlLoading: (_, req) async {
        debugPrint('override request => $req');
        if (req.request.url.toString().endsWith(_param)) {
          // return ShouldOverrideUrlLoadingAction.ALLOW;
          return NavigationActionPolicy.ALLOW;
        }
        const blockUrl = 'https://tracert.alipay.com/';
        if (req.request.url.toString().startsWith(blockUrl)) {
          // return ShouldOverrideUrlLoadingAction.CANCEL;
          return NavigationActionPolicy.CANCEL;
        }
        MyRoute.webview(req.request.url.toString());
        return NavigationActionPolicy.CANCEL;
        // return ShouldOverrideUrlLoadingAction.ALLOW;
      },
      onCreateWindow: (_, req) async {
        debugPrint('create window: $req');
        return false;
      },
      onLoadError: (_, url, code, msg) {
        debugPrint('load $url: $code $msg');
      },
      onLoadHttpError: (_, url, code, msg) {
        debugPrint('load $url: $code $msg');
      },
      onLoadStart: (_, url) {
        visible.value = false;
        debugPrint('loadStart => $url');
      },
      onLoadStop: (_, url) async {
        _pullToRefreshController.endRefreshing();
        debugPrint('loadStop => $url');
        await _injectJavascript();
        // 延迟 100 毫秒，等待 JavaScript 执行效果
        Future.delayed(100.milliseconds, () {
          visible.value = true;
          _webViewController.getContentHeight().then((h) {
            debugPrint('contentHeight => $h');
            if (h > minScrollHeight) {
              minScrollHeight = h ~/ 10;
            }
          });
        });
      },
    );

    return Theme(
      data: ThemeData(primaryColor: Colors.white),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: GetBuilder<DocDetailController>(
            tag: tag,
            builder: (c) => c.stateBuilder(
              onError: (err) => Text('${err.title}'),
              onLoading: Text('${title.value}'),
              animation: false,
              onIdle: () {
                title.value = c.value.title;
                final elseif = Align(
                  child: Text('${title.value}'),
                  alignment: Alignment.centerLeft,
                );
                return Obx(
                  () => _buildUserBar(
                    c.value.user,
                    c.value.updatedAt,
                  ).onlyIf(
                    showUser.value,
                    elseif: () => elseif,
                  ),
                );
              },
            ),
          ),
          actions: [
            // GestureDetector(
            //   onTap: () {
            //     showMaterialModalBottomSheet(
            //       context: context,
            //       builder: (_) {
            //         return Container(
            //           margin: const EdgeInsets.all(8),
            //           padding: const EdgeInsets.all(8),
            //           child: GetBuilder<DocDetailController>(
            //             tag: tag,
            //             builder: (c) => c.stateBuilder(
            //               onIdle: () => Column(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: [
            //                   Text('标签'),
            //                   GetBuilder<DocTagController>(
            //                     init: DocTagController(c.value.id),
            //                     tag: tag,
            //                     builder: (c) => c.stateBuilder(
            //                       onError: (err) => SizedBox.shrink(),
            //                       onLoading: SizedBox.shrink(),
            //                       onEmpty: Text(''),
            //                       onIdle: () => Row(
            //                         children: c.value.mapWidget(
            //                           (item) => Text('${item.title}'),
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                   Divider(),
            //                   Row(
            //                     children: [
            //                       Text(
            //                         '${c.value.wordCount}',
            //                         style: AppStyles.textStyleA,
            //                       ),
            //                       Text('字', style: AppStyles.textStyleC),
            //                     ],
            //                   ),
            //                   // Text('${c.value}'),
            //                   Divider(),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         );
            //       },
            //     );
            //   },
            //   child: Icon(Icons.info),
            // ),
            _buildMoreAction(),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(
                () => IndexedStack(
                  index: visible.value ? 1 : 0,
                  children: [
                    ViewLoadingWidget(),
                    Stack(
                      children: [
                        Positioned.fill(child: docBody),
                        PositionedDirectional(
                          bottom: 16,
                          end: 16,
                          width: 32,
                          height: 32,
                          child: IconButton(
                            iconSize: 32,
                            icon: Icon(FontAwesomeIcons.arrowAltCircleUp),
                            color: ThemeController.to.primarySwatchColor,
                            onPressed: () {
                              _webViewController?.scrollTo(
                                  x: 0, y: 0, animated: true);
                            },
                          ).onlyIf(canScrollTop.value),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBar(
    UserSeri user,
    String updatedAt,
  ) {
    return Container(
      height: 44,
      margin: EdgeInsets.only(right: 3),
      child: GestureDetector(
        onTap: () {
          MyRoute.user(
            user: user.toUserLiteSeri(),
            heroTag: tag,
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: tag,
              child: UserAvatarWidget(
                avatar: user.avatarUrl,
              ),
            ),
            Expanded(
              child: Container(
                height: 44,
                margin: EdgeInsets.only(left: 14, bottom: 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user.name}",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: AppStyles.textStyleBB,
                    ),
                    SizedBox(height: 2),
                    Text(
                      "更新于 ${Util.timeCut(updatedAt)}",
                      textAlign: TextAlign.center,
                      style: AppStyles.textStyleCC,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return GetBuilder<DocDetailController>(
      tag: tag,
      builder: (detail) => detail.stateBuilder(
        onLoading: SizedBox.shrink(),
        onError: (err) => Text('${err.title}'),
        onIdle: () {
          Get.lazyPut(() => DocCommentsController(detail.value.id), tag: tag);
          final commentBar = GetBuilder<DocCommentsController>(
            tag: tag,
            builder: (c) => c.stateBuilder(
              onLoading: SizedBox.shrink(),
              onEmpty: SizedBox.shrink(),
              onIdle: () => __commentInfo(c),
              onError: (err) {
                if (err.type == ViewErrorType.api) {
                  return __commentInfo(c);
                }
                return Text('${err.title}');
              },
            ),
          );

          return Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(25, 0, 0, 0),
                  offset: Offset(1, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(child: commentBar),
                LikeAnimButtonWidget(
                  initValue: ApiRepository.getIfLike(
                    targetId: detail.value.id,
                    targetType: 'Doc',
                  ),
                  onTap: (value) => _handleAction(
                    ApiRepository.doLike(
                      target: detail.value.id,
                      type: 'Doc',
                      unlike: !value,
                    ),
                  ),
                ),
                StarAnimButtonWidget(
                  key: Key('star_anim_button'),
                  initValue: ApiRepository.getIfMark(
                    targetId: detail.value.id,
                    targetType: 'Doc',
                  ),
                  onTap: (value) => _handleAction(
                    ApiRepository.toggleMark(
                      targetId: detail.value.id,
                      targetType: 'Doc',
                      marked: !value,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _handleAction(Future future) {
    return futureResolver(
      future,
      onData: (_) => true,
      onError: (e) {
        Util.toast('出错了: $e');
        return false;
      },
    );
  }

  Widget __commentInfo(DocCommentsController c) {
    return GestureDetector(
      onTap: () {
        if (GetUtils.isNullOrBlank(c.value?.meta)) {
          return;
        }
        showBarModalBottomSheet(
          context: context,
          builder: (_) {
            return DocCommentsWidget(
              scrollController: ModalScrollController.of(_),
              tag: tag,
            );
          },
        );
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              Icons.edit,
              size: 15,
              color: AppColors.primaryText,
            ),
          ),
          Text(
            "评论已关闭".onlyIf(
              GetUtils.isNull(c.value?.meta),
              elseif: () => "${c.comments.length} 人评论 说点什么呢⋯⋯",
            ),
            style: TextStyle(
              color: AppColors.primaryText,
              fontFamily: "sans_bold",
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  _changeFontSize() {
    var changer = (String query, double value) {
      return 'document.querySelector("$query")'
          '.style.fontSize="${value.toInt()}px"';
    };

    showMaterialModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: 200,
          child: Obx(
            () => Slider(
              divisions: 36,
              value: fontSize.value,
              label: '${fontSize.value.toInt()}',
              min: 12,
              max: 48,
              onChanged: (double value) {
                debugPrint('value => $value');
                fontSize.value = value;
                _webViewController.evaluateJavascript(
                  source: changer('.lake-engine-view', fontSize.value),
                );
                _webViewController.evaluateJavascript(
                  source: changer('.CodeMirror', fontSize.value),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
