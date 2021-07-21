import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:yuyan_app/config/app.dart';
import 'package:yuyan_app/config/route_manager.dart';
import 'package:yuyan_app/controller/home/personal/my_controller.dart';
import 'package:yuyan_app/controller/app/version_controller.dart';
import 'package:yuyan_app/views/widget/animation.dart';
import 'package:yuyan_app/views/widget/editor/comment_widget.dart';
import 'package:yuyan_app/views/widget/setting_item.dart';

import 'widget/user_info_card_widget.dart';

class PersonalCenterTab extends StatefulWidget {
  PersonalCenterTab({Key key}) : super(key: key);

  @override
  _PersonalCenterTabState createState() => _PersonalCenterTabState();
}

class _PersonalCenterTabState extends State<PersonalCenterTab> {
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用 _controller.dispose
    _controller.dispose();
    super.dispose();
  }

  _buildBackground(ThemeData theme) {
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

  @override
  Widget build(BuildContext context) {
    // analytics.logEvent(name: 'my_page', parameters: {'name': '/MyPage'});
    List<Widget> widgetList = [
      Container(
        child: GetBuilder<MyUserController>(
          builder: (c) => c.builder(
            (state) => MyInfoCardWidget(info: state.data),
          ),
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: _SettingListWidget(),
        ),
      ),
    ];
    // getVersion();

    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          // 背景图形
          _buildBackground(theme),

          Positioned(
            top: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 56,
              child: ListView.builder(
                  // controller: _controller,
                  itemCount: widgetList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return widgetList[index];
                  }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimationColumnWidget(
      children: [
        SettingItemWidget(
          title: "我的收藏",
          imgAsset: "collections",
          namedRoute: RouteName.myMark,
        ),
        SettingItemWidget(
          title: "关注知识库",
          imgAsset: "follow_book",
          namedRoute: RouteName.myFollowBook,
        ),
        SettingItemWidget(
          title: "我的讨论",
          imgAsset: "topics",
          namedRoute: RouteName.myTopic,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 10,
          color: Color.fromRGBO(0, 0, 0, 0.03),
        ),
        SettingItemWidget(
          title: "意见与反馈",
          imgAsset: "suggest",
          namedRoute: RouteName.mySuggest,
        ),
        SettingItemWidget(
          title: "关于语燕",
          imgAsset: "about",
          namedRoute: RouteName.myAbout,
        ),
        GetBuilder<VersionController>(
          builder: (c) => SettingItemWidget(
            title: "设置",
            imgAsset: "setting",
            namedRoute: RouteName.mySetting,
            badge: !c.isLatest,
          ),
        ),
        if (kDebugMode)
          GestureDetector(
            onTap: () {
              Get.to(
                () => CommentPageTest(),
              );
              // final avatarUrl =
              //     "https://cdn.nlark.com/yuque/0/2020/png/164272/1581178391840-avatar/dfd33ab4-7115-4fce-b504-faeb9d3ca24d.png";
              // Get.to(GroupPage(
              //   group: GroupSeri(
              //     id: 2616655,
              //     name: "Redhome",
              //     description: "没有内容的哦",
              //     avatarUrl: avatarUrl,
              //   ),
              // ));
            },
            child: AbsorbPointer(
              child: SettingItemWidget(
                title: "测试",
                imgAsset: "about",
              ),
            ),
          ),
      ],
    );
  }
}

class CommentPageTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AppBar'),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton(
            onPressed: () {
              App.analytics.logEvent(name: 'test_event').catchError((err) {
                debugPrint('onError: $err');
              });
            },
            child: Text('TEST'),
          ),
          TextButton(
            onPressed: () {
              showMaterialModalBottomSheet(
                context: context,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                builder: (_) => CommentModalSheet(
                  onPublish: (mark) async {
                    debugPrint('result: $mark');
                    return false;
                  },
                ),
              );
            },
            child: Text('Comment'),
          ),
        ],
      ),
    );
  }
}
