import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:yuyan_app/config/route_manager.dart';
import 'package:yuyan_app/config/service/api_repository.dart';
import 'package:yuyan_app/controller/home/notification/notification_controller.dart';
import 'package:yuyan_app/model/document/book.dart';
import 'package:yuyan_app/model/document/doc.dart';
import 'package:yuyan_app/model/notification/notification_item.dart';
import 'package:yuyan_app/model/topic/topic.dart';
import 'package:yuyan_app/model/user/org/organization_lite.dart';
import 'package:yuyan_app/model/user/user.dart';
import 'package:yuyan_app/model/user/user_lite_seri.dart';
import 'package:yuyan_app/util/styles/app_ui.dart';
import 'package:yuyan_app/util/util.dart';
import 'package:yuyan_app/views/widget/lake/lake_render.dart';
import 'package:yuyan_app/views/widget/user_widget.dart';

class NotificationItemWidget extends StatelessWidget {
  // 几种通知
  final Map<String, String> newsType = {
    "invite_collaborator": "邀请你协作",
    "update_doc": "更新了文档",
    "like_doc": "打赏了稻谷",
    "comment": "评论了话题",
    "mention": "在评论中@了你",
    "new_topic": "新建了讨论",
    "new_book": "新建了知识库",
    "topic_assign": "指派了话题",
    "publish_doc": "发布了文章",
    "watch_book": "关注了知识库",
    "delete_book": "删除了知识库",
    "public_book": "公开了知识库",
    "private_book": "取消公开了知识库",
    "rename_book": "重命名了知识库",
    "follow_user": "关注了你",
    "like_artboard": "赞赏了画板稻谷",
    "upload_artboards": "更新了画板",
    "apply_join_group": "申请加入团队",
    "apply_organization_user": "申请加入空间",
    "new_group_member": "邀请新成员加入团队",
    "join_organization_user": "加入了组织成员",
    "join_group_user": "加入了团队成员",
    "joined_a_group": "将你添加到了团队",
    "join_collaborator": "加入了协作",
    "group_invitation": "邀请你加入团队",
    "close_topic": "关闭了话题",
    "reopen_topic": "重新开启了话题",
    "user_member_will_expire": "会员即将到期",
    "system": "系统通知",
    "apply_collaborator": "申请文档协作",
    "remove_from_a_group": "移出了团队",
    "use_gift_promo": "兑换权益"
  };

  final NotificationItemSeri data;
  final bool unread;
  final VoidCallback beforeTab;

  bool get deleted => data.subject == null;

  deleteItem() {
    final c = Get.find<NotificationAllController>();
    c.value.remove(data);
    c.update();
    return futureResolver(
      ApiRepository.delNotification(ids: '${data.id}'),
      onData: (_) => ScaffoldMessenger.of(Get.context).showSnackBar(
        SnackBar(content: Text('已移除')),
      ),
      onError: (err) {
        // fetch previous data
        c.onRefreshCallback();
        return ScaffoldMessenger.of(Get.context).showSnackBar(
          SnackBar(content: Text('失败: $err')),
        );
      },
    );
  }

  NotificationItemWidget({
    Key key,
    @required this.data,
    this.beforeTab,
    this.unread = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // String lastSub = clearSub(data);
    String tag = Util.genHeroTag();

    final userAvatar = GestureDetector(
      onTap: () {
        beforeTab?.call();
        if (data.actor != null) {
          MyRoute.user(
            user: data.actor.toUserLiteSeri(),
            heroTag: tag,
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 18),
        child: Hero(
          tag: tag,
          child: UserAvatarWidget(
            avatar: data.actor?.avatarUrl,
            height: 45,
          ),
        ),
      ),
    );

    final titleWidget = Row(
      children: [
        Expanded(
          child: Text(
            "系统消息".onlyIf(
              data.actor == null,
              elseif: () => "${data.actor.name}",
            ),
            style: AppStyles.textStyleB,
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 12),
          child: Text(
            "${Util.timeCut(data.createdAt)}",
            style: AppStyles.textStyleCC,
          ),
        )
      ],
    );
    final notifySub = deleted ? '相关内容已删除' : getNotificationSub();
    final contentWidget = Row(
      children: [
        Expanded(
          child: Text(
            "${newsType[data.notifyType] ?? data.notifyType}"
            "${notifySub.onlyIf(notifySub == '', elseif: () => ' [$notifySub]')}",
            style: AppStyles.textStyleC.copyWith(
              decoration: deleted ? TextDecoration.lineThrough : null,
              decorationThickness: 1.5,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 15),
          child: CircleAvatar(
            radius: 3,
            backgroundColor: unread ? Colors.red : Colors.transparent,
          ),
        )
      ],
    );

    Widget child = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          userAvatar,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: titleWidget,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 2,
                  ),
                  child: contentWidget,
                )
              ],
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        beforeTab?.call();
        if (deleted) {
          return Get.dialog(
            AlertDialog(
              content: Text('此消息已被删除，是否删除记录？'),
              actions: [
                TextButton(
                  onPressed: () => [Get.back(), deleteItem()],
                  child: Text('删除'),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('取消'),
                ),
              ],
            ),
          );
        }
        if (data.params != null) {
          switch (data.notifyType) {
            case 'system':
              return Get.dialog(
                AlertDialog(
                  content: LakeRenderWidget(
                    data: data.params['html'],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        Util.goUrl('/go/notification/${data.id}');
                      },
                      child: Text('详情'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('确认'),
                    ),
                  ],
                ),
              );
            case 'use_gift_promo':
              return Util.goUrl('/settings/member');
          }
        }
        switch (data.subjectType) {
          case 'User':
            return MyRoute.user(
              user: data.subject.serialize<UserLiteSeri>('user_lite'),
              heroTag: tag,
            );
          case 'Doc':
            var doc = data.subject.serialize<DocSeri>();
            var book = data.secondSubject.serialize<BookSeri>();
            return MyRoute.docDetailWebview(
              bookId: data.secondSubjectId,
              slug: doc.slug,
              login: book.user.login,
              book: book.slug,
            );
          case 'Topic':
            var topic = data.subject.serialize<TopicSeri>();
            return MyRoute.topic(topic.iid, topic.groupId);
          case 'Comment':
            if (data.secondSubjectType == 'Topic') {
              var item = data.secondSubject.serialize<TopicSeri>();
              return MyRoute.topic(item.iid, item.groupId);
            }
        }
        return Util.goUrl('/go/notification/${data.id}');
      },
      child: Dismissible(
        key: Key('${data.id}'),
        background: Container(color: Colors.red),
        onDismissed: (_) => deleteItem(),
        child: child,
      ),
    );
  }

  String getNotificationSub() {
    if (data.params != null) {
      switch (data.notifyType) {
        case 'system':
          final content = htmlparser.parseFragment(data.params['html']);
          return content.text.replaceAll('\n', '');
        case 'use_gift_promo':
          final expired = DateTime.tryParse(data.params['expiredTime']);
          return '语雀会员延长至 ${expired.year}-${expired.month}-${expired.day}';
      }
    }
    switch (data.subjectType) {
      case 'User':
        return data.subject.serialize<UserSeri>().name;
      case 'Doc':
        return data.subject.serialize<DocSeri>().title;
      case 'Book':
        return data.subject.serialize<BookSeri>().name;
      case 'Topic':
        var topic = data.subject.serialize<TopicSeri>();
        return topic.title;
      case 'OrganizationUser':
        var org = data.secondSubject.serialize<OrganizationLiteSeri>();
        return org.name;
      case 'Comment':
        if (data.secondSubjectType == 'Topic') {
          var item = data.secondSubject?.serialize<TopicSeri>();
          return item?.title ?? '';
        } else if (data.secondSubjectType == 'Doc') {
          var item = data.secondSubject?.serialize<DocSeri>();
          return item?.title ?? '';
        }
    }
    return '';
  }
}
