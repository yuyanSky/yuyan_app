import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yuyan_app/config/route_manager.dart';
import 'package:yuyan_app/controller/home/personal/my_controller.dart';
import 'package:yuyan_app/model/user/mine/mine_seri.dart';
import 'package:yuyan_app/util/styles/app_ui.dart';
import 'package:yuyan_app/util/util.dart';
import 'package:yuyan_app/views/widget/animation.dart';
import 'package:yuyan_app/views/widget/user_widget.dart';

class MyInfoCardWidget extends StatelessWidget {
  final MineSeri info;

  MyInfoCardWidget({
    Key key,
    @required this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tag = Util.genHeroTag();
    double leftMargin = MediaQuery.of(context).size.width * 0.075;
    double descriptionWidth =
        MediaQuery.of(context).size.width - leftMargin * 3.6 - 95;
    return Container(
      margin: EdgeInsets.only(
        top: 84,
        left: leftMargin,
        right: leftMargin,
        bottom: leftMargin,
      ),
      padding: EdgeInsets.only(
        left: leftMargin * 0.8,
        right: leftMargin * 0.8,
        top: 14,
        bottom: 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(55, 0, 0, 0),
            offset: Offset(1, 2),
            blurRadius: 4,
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              MyRoute.user(
                user: info.toUserLite(),
                heroTag: tag,
              );
            },
            child: AnimationRowWidget(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 16),
                Hero(
                  tag: tag,
                  child: UserAvatarWidget(
                    avatar: info.avatarUrl,
                    height: 60,
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  height: 84,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 33,
                        width: descriptionWidth,
                        margin: EdgeInsets.only(left: 2),
                        child: Row(
                          children: [
                            Text(
                              "${info.name}",
                              textAlign: TextAlign.center,
                              style: AppStyles.textStyleA,
                            ),
                            UserMemberIconWidget().onlyIf(info.isPaid),
                          ],
                        ),
                      ),
                      Container(
                        width: descriptionWidth,
                        margin: EdgeInsets.only(left: 3),
                        child: Text(
                          "${info.description ?? '笔墨待识君'}",
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          style: AppStyles.countTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          MyInfoNumberWidget(info: info),
        ],
      ),
    );
  }
}

class MyInfoNumberWidget extends StatelessWidget {
  final MineSeri info;

  MyInfoNumberWidget({
    Key key,
    @required this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var groupNumer = Get.find<MyGroupController>().value.data?.length ?? 0;
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        child: AnimationRowWidget(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InfoNumberItemWidget(
              title: "团队",
              number: Get.find<MyGroupController>().value.data?.length ?? 0,
              namedRoute: RouteName.myGroup,
            ),
            InfoNumberItemWidget(
              title: "知识库",
              // number: Get.find<MyBookController>().value.data?.length ?? 0,
              number: info.booksCount,
              namedRoute: RouteName.myRepos,
            ),
            InfoNumberItemWidget(
              title: "关注了",
              // number: Get.find<MyFollowingController>().value.data?.length ?? 0,
              number: info.followingCount,
              namedRoute: RouteName.myFollowing,
            ),
            InfoNumberItemWidget(
              title: "关注者",
              // number: Get.find<MyFollowerController>().value.data?.length ?? 0,
              number: info.followersCount,
              namedRoute: RouteName.myFollower,
            ),
          ],
        ),
      ),
    );
  }
}

class InfoNumberItemWidget extends StatelessWidget {
  final String title;
  final int number;
  final String namedRoute;

  InfoNumberItemWidget({
    Key key,
    this.title,
    this.number,
    this.namedRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.172,
      child: InkWell(
        onTap: () {
          if (namedRoute != null) {
            Get.toNamed(namedRoute);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "$number",
              textAlign: TextAlign.center,
              style: AppStyles.countStyle,
            ),
            Text(
              "$title",
              textAlign: TextAlign.center,
              style: AppStyles.countTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
