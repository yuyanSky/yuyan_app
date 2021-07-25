import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smart_color/smart_color.dart';
import 'package:yuyan_app/config/app.dart';
import 'package:yuyan_app/config/route_manager.dart';
import 'package:yuyan_app/config/service/api_repository.dart';
import 'package:yuyan_app/controller/organization/topic/topic_controller.dart';
import 'package:yuyan_app/model/document/commen/comment_detail.dart';
import 'package:yuyan_app/model/meta/ability.dart';
import 'package:yuyan_app/model/topic/labels.dart';
import 'package:yuyan_app/model/topic/topic_detail_seri.dart';
import 'package:yuyan_app/model/user/user.dart';
import 'package:yuyan_app/util/styles/app_ui.dart';
import 'package:yuyan_app/util/util.dart';
import 'package:yuyan_app/views/widget/editor/comment_widget.dart';
import 'package:yuyan_app/views/widget/lake/cards/mention.dart';
import 'package:yuyan_app/views/widget/lake/lake_render.dart';
import 'package:yuyan_app/views/widget/menu_item.dart';
import 'package:yuyan_app/views/widget/user_widget.dart';

class TopicDetailPage extends StatefulWidget {
  final int commentId;
  final int groupId;

  TopicDetailPage({
    Key key,
    this.commentId,
    this.groupId,
  }) : super(key: key);

  @override
  _TopicDetailPageState createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  // final _textController = TextEditingController();
  final _refreshController = RefreshController();

  int _commentId;
  var _hintText = '评论千万条，友善第一条';

  String get tag => '${widget.groupId}';

  initState() {
    super.initState();

    Get.put(
      TopicDetailController(widget.commentId, widget.groupId),
      tag: tag,
    );
  }

  // _buildCommentButton(int commentId, [int reply]) {
  //   return GetBuilder<CommentPostController>(
  //     init: CommentPostController(commentId),
  //     tag: tag,
  //     builder: (c) {
  //       if (c.isLoadingState) {
  //         return SizedBox(
  //           width: 18,
  //           height: 18,
  //           child: CircularProgressIndicator(),
  //         );
  //       }
  //       return TextButton(
  //         onPressed: () {
  //           if (_textController.text.trim().isNotEmpty) {
  //             c.postComment(
  //               parentId: reply,
  //               comment: _textController.text,
  //               success: () {
  //                 var comments = Get.find<TopicCommentsController>(tag: tag);
  //                 comments.onRefresh();
  //                 _textController.text = '';
  //                 if (Get.isBottomSheetOpen) {
  //                   Get.back();
  //                 }
  //                 if (Get.focusScope.hasFocus) {
  //                   Get.focusScope.unfocus();
  //                 }
  //                 BotToast.showText(text: '成功');
  //               },
  //               error: () {
  //                 BotToast.showText(text: '${c.error.content}');
  //               },
  //             );
  //           }
  //         },
  //         child: Text(
  //           reply != null ? '回复' : '评论',
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.blue,
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  _openBottomSheet([int reply, String replyHint]) async {
    var postController = CommentPostController(_commentId);
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentModalSheet(
        hintText: replyHint,
        onPublish: (mark) async {
          if (mark.trim().isEmpty) {
            Util.toast('说点什么吗？');
            return false;
          }
          var success = false;
          await postController.safeHandler(() async {
            await postController.postComment(
              parentId: reply,
              comment: mark,
              convert: true,
              success: () {
                success = true;
                Util.toast('🎉 成功');
              },
              error: () {
                Util.toast('💔 失败');
              },
            );
          });
          return success;
        },
      ),
    ).then((_) {
      var comments = Get.find<TopicCommentsController>(tag: tag);
      comments.onRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TopicDetailController>(
      tag: tag,
      builder: (c) => c.stateBuilder(
        scaffold: true,
        onIdle: () {
          _commentId = c.value.id;
          return Scaffold(
            appBar: AppBar(
              title: Text('话题详情'),
              actions: [
                //TODO(@dreamer2q): 添加话题控制panel
                PopupMenuButton<VoidCallback>(
                  itemBuilder: (_) => [
                    if (c.abilities.update)
                      PopupMenuItem(
                        value: () {
                          Util.toast('敬请期待');
                        },
                        child: MenuItemWidget(
                          title: '编辑',
                        ),
                      ),
                    if (c.abilities.update)
                      PopupMenuItem(
                        value: () => Util.safeHandler(
                          ApiRepository.putTopicAction(
                            id: c.value.id,
                            type: c.value.closedAt == null ? 'close' : 'reopen',
                          ),
                          onData: (_) => [c.onRefresh(), Util.toast('成功')],
                        ),
                        child: MenuItemWidget(
                          title: c.value.closedAt == null ? '关闭' : '重新开启',
                        ),
                      ),
                    if (c.abilities.block)
                      PopupMenuItem(
                        value: () => Util.safeHandler(
                          ApiRepository.putTopicAction(
                            id: c.value.id,
                            type:
                                c.value.blockedAt == null ? 'block' : 'unblock',
                          ),
                          onData: (_) => [c.onRefresh(), Util.toast('成功')],
                        ),
                        child: MenuItemWidget(
                          title: '屏蔽'.onlyIf(
                            c.value.blockedAt == null,
                            elseif: () => '取消屏蔽',
                          ),
                        ),
                      ),
                    if (c.abilities.pin)
                      PopupMenuItem(
                        value: () => Util.safeHandler(
                          ApiRepository.putTopicAction(
                            id: c.value.id,
                            type: c.value.pinnedAt == null ? 'pin' : 'unpin',
                          ),
                          onData: (_) => [c.onRefresh(), Util.toast('成功')],
                        ),
                        child: MenuItemWidget(
                          title: c.value.pinnedAt == null ? '置顶' : '取消置顶',
                        ),
                      ),

                    /// comment operations
                    PopupMenuItem(
                      value: () =>
                          Util.goUrl('/${c.groupId}/topics/${c.value.iid}'),
                      child: MenuItemWidget(
                        iconData: Icons.open_in_browser,
                        title: '打开网页版',
                      ),
                    ),
                  ],
                  onSelected: (_) => _?.call(),
                ),
                // IconButton(
                //   icon: Icon(Icons.more_horiz),
                //   onPressed: () {
                //     showModalBottomSheet(
                //       context: context,
                //       builder: (_) => Container(
                //         child: Column(
                //           children: [
                //             ElevatedButton(
                //               onPressed: () {},
                //               child: Text('取消订阅'),
                //             ),
                //           ],
                //         ),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: SmartRefresher(
                    controller: _refreshController,
                    onRefresh: () async {
                      var comments =
                          Get.find<TopicCommentsController>(tag: tag);
                      await Future.wait([c.onRefresh(), comments.onRefresh()]);
                      if (c.isIdleState) {
                        _refreshController.refreshCompleted();
                      } else {
                        _refreshController.refreshFailed();
                      }
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TopicDescWidget(
                            data: c.value,
                            abilities: c.abilities,
                          ),
                          _buildCommentList(c.value.id),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 0, left: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withOpacity(0.5),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _openBottomSheet,
                          child: Container(
                            child: Text(
                              _hintText,
                              style: AppStyles.textStyleC,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          '回复',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _buildCommentList(int commentId) {
    return GetBuilder<TopicCommentsController>(
      tag: tag,
      init: TopicCommentsController(commentId),
      builder: (comments) => comments.stateBuilder(
        onEmpty: Container(
          alignment: Alignment.center,
          height: 150,
          child: Text('还没有人评论，来做第一个评论的吧！'),
        ),
        onIdle: () {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.only(left: 16, top: 20, bottom: 2),
                child: Text(
                  "${comments.value.length} 条评论",
                  style: AppStyles.textStyleBBB,
                ),
              ),
              SizedBox(height: 10),
              ...comments.value.mapWidget((e) {
                return CommentDetailItemWidget(
                  current: e,
                  comments: comments.value,
                  onTap: () {
                    var hint = '回复 ${e.user.name}: ';
                    _openBottomSheet(e.id, hint);
                  },
                  onLongPressed: () {
                    if (e.userId == App.userProvider.data.id) {
                      Util.showConfirmDialog(
                        context,
                        content: '删除这条评论吗?',
                        confirmCallback: () {
                          Util.futureWrap(
                            ApiRepository.deleteComment(e.id),
                            onData: (data) {
                              Get.find<TopicCommentsController>(
                                tag: tag,
                              ).onRefresh(force: true);
                              Util.toast('删除成功');
                            },
                            onError: (err) {
                              Util.toast('删除失败: $err');
                            },
                          );
                        },
                      );
                    }
                  },
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class CommentDetailItemWidget extends StatefulWidget {
  final List<CommentDetailSeri> comments;
  final CommentDetailSeri current;
  final VoidCallback onTap;
  final VoidCallback onLongPressed;

  CommentDetailItemWidget({
    Key key,
    @required this.current,
    @required this.comments,
    this.onTap,
    this.onLongPressed,
  }) : super(key: key);

  @override
  _CommentDetailItemWidgetState createState() =>
      _CommentDetailItemWidgetState();
}

class _CommentDetailItemWidgetState extends State<CommentDetailItemWidget> {
  UserSeri parent;

  @override
  void initState() {
    super.initState();
    if (widget.current.parentId != null) {
      parent = widget.comments
          .firstWhere((item) => item.id == widget.current.parentId,
              orElse: () => null) // 这个 orElse 坑死我了orz
          ?.user;
    }
  }

  @override
  Widget build(BuildContext context) {
    String tag = Util.genHeroTag();
    return Material(
      child: InkWell(
        highlightColor: Colors.black12,
        onTap: widget.onTap,
        onLongPress: widget.onLongPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26, width: 0.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Hero(
                      tag: tag,
                      child: UserAvatarWidget(
                        avatar: widget.current.user.avatarUrl,
                        height: 28,
                      ),
                    ),
                    onTap: () {
                      MyRoute.user(user: widget.current.user.toUserLiteSeri());
                    },
                  ),
                  SizedBox(width: 8),
                  Text(widget.current.user.name, style: AppStyles.textStyleB),
                  Spacer(),
                  Text(
                    Util.timeCut(widget.current.updatedAt),
                    style: AppStyles.textStyleCC,
                  ),
                ],
              ),
              if (parent != null)
                Container(
                  margin: const EdgeInsets.only(left: 32),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: Colors.grey.withOpacity(0.5), width: 0.1),
                  ),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('回复 '),
                        LakeMentionWidget(
                          name: parent.name,
                          login: parent.login,
                          showLogin: false,
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 18,
                  top: 8,
                  bottom: 4,
                ),
                child: LakeRenderWidget(
                  data: widget.current.bodyAsl,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TopicDescWidget extends StatelessWidget {
  final TopicDetailSeri data;
  final MetaAbilitySeri abilities;

  const TopicDescWidget({
    Key key,
    this.data,
    this.abilities,
  }) : super(key: key);

  Widget _labels(List<LabelSeri> labels) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      text: TextSpan(
        children: labels.map((e) {
          return WidgetSpan(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
              decoration: BoxDecoration(
                color: SmartColor.parse(e.color),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${e.name}',
                style: AppStyles.textStyleCC.copyWith(color: Colors.white),
              ),
            ),
          );
          return TextSpan(
            text: ' ${e.name} ',
            style: TextStyle(
              backgroundColor: SmartColor.parse(e.color),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final closedBadge = WidgetSpan(
      child: Container(
        margin: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '已关闭',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
    final blockedBadge = WidgetSpan(
      child: Container(
        margin: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '已屏蔽',
          style: TextStyle(
            color: Colors.redAccent,
          ),
        ),
      ),
    );
    final lock = Row(
      children: [
        Icon(Icons.lock, size: 11),
        Text('私密', style: AppStyles.textStyleCC),
        SizedBox(width: 8),
      ],
    );

    Widget child = Container(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 20),
      color: AppColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文档标题
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: Text.rich(
              TextSpan(
                text: data.title,
                children: [
                  TextSpan(
                    text: '\t\t#${data.iid}',
                    style: AppStyles.textStyleCB,
                  ),
                  if (data.closedAt != null) closedBadge,
                  if (data.blockedAt != null && abilities.block) blockedBadge,
                ],
              ),
              style: AppStyles.textStyleA,
            ),
          ),
          Row(
            children: [
              UserAvatarWidget(
                avatar: data.user.avatarUrl,
              ),
              SizedBox(width: 10),
              Text(
                data.user.name,
                style: AppStyles.textStyleB,
              ),
              Spacer(),
              if (data.public == 0) lock,
              Text(
                Util.timeCut(data.createdAt),
                style: AppStyles.textStyleC,
              ),
            ],
          ),
          SizedBox(height: 18),
          LakeRenderWidget(
            data: data.bodyAsl,
          ),
          DefaultTextStyle(
            style: AppStyles.textStyleC,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (data.assignee != null)
                  Row(
                    children: [
                      Text('指派给：'),
                      Text(data.user.name),
                    ],
                  ).paddingOnly(top: 32),
                if (data.milestone != null)
                  Row(
                    children: [
                      Text('看板：'),
                      Text('${data.milestone.title}'),
                    ],
                  ),
                if (data.labels != null)
                  _labels(data.labels).paddingOnly(top: 12),
              ],
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        child,
        if (data.pinnedAt != null)
          Positioned(
            left: 8,
            top: 4,
            child: ClipPath(
              clipper: TriangleClipper(),
              child: Container(
                color: Colors.green,
                width: 15,
                height: 15,
              ),
            ),
          ),
      ],
    );
  }
}
