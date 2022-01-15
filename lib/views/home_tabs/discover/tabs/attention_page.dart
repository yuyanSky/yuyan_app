import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:yuyan_app/controller/home/attend_controller.dart';
import 'package:yuyan_app/model/user/events/event_seri.dart';
import 'package:yuyan_app/util/styles/app_ui.dart';
import 'package:yuyan_app/views/component/nothing_page.dart';
import 'package:yuyan_app/views/widget/event/affair.dart';

class AttentionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GetBuilder<AttendController>(
        builder: (c) {
          return SmartRefresher(
            controller: c.refreshController,
            onRefresh: c.onRefreshCallback,
            enablePullUp: !c.isEmptyState,
            onLoading: c.onLoadMoreCallback,
            child: c.builder(
              (state) {
                List<EventSeri> data = state!.data!;
                return ListView.builder(
                  key: PageStorageKey('attention'),
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AffairTileWidget(data[index]);
                  },
                );
              },
              onEmpty: NothingPage(
                top: 100,
                text: "去关注一些人叭~",
              ),
            ),
          );
        },
      ),
    );
  }
}
