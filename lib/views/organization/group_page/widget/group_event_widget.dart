import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yuyan_app/controller/organization/group/group_controller.dart';
import 'package:yuyan_app/model/user/events/user_event_seri.dart';
import 'package:yuyan_app/util/util.dart';
import 'package:yuyan_app/views/widget/event/user_affair.dart';

class GroupEventWidget extends StatefulWidget {
  final int? blockId;

  GroupEventWidget({
    Key? key,
    this.blockId,
  }) : super(key: key);

  @override
  _GroupEventWidgetState createState() => _GroupEventWidgetState();
}

class _GroupEventWidgetState extends State<GroupEventWidget>
    with AutomaticKeepAliveClientMixin {
  String? tag;

  @override
  void initState() {
    super.initState();
    tag = '${widget.blockId}';
    Get.lazyPut(
      () => GroupViewBlockController(widget.blockId),
      tag: tag,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<GroupViewBlockController>(
      tag: tag,
      autoRemove: false,
      builder: (c) => c.stateBuilder(
        onEmpty: Container(
          child: Text('当前团队暂无动态'),
        ),
        onIdle: () {
          List<UserEventSeri> data = c.value!;
          return Column(
            children: [
              ...data.mapWidget(
                (item) => UserAffairTileWidget(item),
              ),
              if (c.hasMore)
                Container(
                  child: ElevatedButton(
                    onPressed: c.loadMoreCallback,
                    child: Text('加载更多'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
