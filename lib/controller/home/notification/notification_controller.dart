import 'package:get/get.dart';
import 'package:yuyan_app/config/service/api_repository.dart';
import 'package:yuyan_app/config/storage_manager.dart';
import 'package:yuyan_app/config/viewstate/view_controller.dart';
import 'package:yuyan_app/config/viewstate/view_state.dart';
import 'package:yuyan_app/model/notification/notification.dart';
import 'package:yuyan_app/model/notification/notification_item.dart';
import 'package:yuyan_app/util/util.dart';

abstract class NotificationProvider
    extends BaseSaveListJson<NotificationItemSeri?> {
  @override
  List<NotificationItemSeri> convert(json) {
    return (json as List).map((e) => NotificationItemSeri.fromJson(e)).toList();
  }
}

class NotificationAllProvider extends NotificationProvider {
  @override
  String get key => 'all_notification';
}

class NotificationAllController
    extends FetchSavableController<NotificationAllProvider> {
  ///三种通知类似， unread, readed, system

  NotificationAllController()
      : super(
          initialRefresh: true,
          state: ViewState.loading,
          initData: NotificationAllProvider(),
        ) {
    //防止 null 错误
    unread = _default;
    readed = _default;
    system = _default;
  }

  var _default = NotificationSeri(
    normalCount: 0,
    notifications: [],
    listType: '',
  );

  late NotificationSeri unread;
  late NotificationSeri readed;
  NotificationSeri? system;

  bool get hasUnread {
    return unread.normalCount! > 0;
  }

  void readAll() async {
    safeHandler(() async {
      ApiRepository.putNotification();
    });
    var i = 0;
    while (hasUnread) {
      value!.data![i++]!.readAt = DateTime.now().toIso8601String();
      unread.normalCount = unread.normalCount! - 1;
      update();
      await Future.delayed(Duration(milliseconds: 80));
    }
  }

  void delAll() async {
    Util.showConfirmDialog(
      Get.context!,
      content: '删除全部消息',
      confirmCallback: () {
        safeHandler(() async {
          await ApiRepository.delNotification();
          refreshController.requestRefresh();
        });
      },
    );
  }

  @override
  Future fetchData() async {
    unread = await ApiRepository.getNotificationList(type: 'unread');
    readed = await ApiRepository.getNotificationList(type: 'seen');
    // system = await ApiRepository.getNotificationList(type: 'system');

    return [
      ...unread.notifications!,
      ...readed.notifications!,
      // ...system.notifications,
    ];
  }

  @override
  Future? fetchMore() {
    return super.fetchMore();
  }
}
