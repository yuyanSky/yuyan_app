import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:yuyan_app/config/app.dart';
import 'package:yuyan_app/util/styles/app_ui.dart';
import 'package:yuyan_app/config/service/api_repository.dart';
import 'package:yuyan_app/controller/organization/doc/doc_controller.dart';
import 'package:yuyan_app/controller/organization/topic/topic_controller.dart';
import 'package:yuyan_app/model/document/commen/comment_detail.dart';
import 'package:yuyan_app/util/util.dart';
import 'package:yuyan_app/views/organization/topic_page/topic_detail_page.dart';
import 'package:yuyan_app/views/widget/editor/comment_widget.dart';

class DocCommentsWidget extends StatefulWidget {
  final String? tag;
  final ScrollController? scrollController;

  DocCommentsWidget({
    Key? key,
    this.tag,
    this.scrollController,
  }) : super(key: key);

  @override
  _DocCommentsWidgetState createState() => _DocCommentsWidgetState();
}

class _DocCommentsWidgetState extends State<DocCommentsWidget>
    with AutomaticKeepAliveClientMixin {
  final _editController = TextEditingController();

  void _onReplyTo(DocCommentsController c, CommentDetailSeri? data) {
    var postController = Get.find<CommentPostController>(tag: widget.tag);
    var reply = data != null;
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentModalSheet(
        hintText: reply ? '回复：${data!.user!.name}' : null,
        onPublish: (mark) async {
          if (mark.trim().isEmpty) {
            Util.toast('说点什么吗？');
            return false;
          }
          var success = false;
          await postController.safeHandler(() async {
            await postController.postComment(
              parentId: reply ? data!.userId : null,
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
      c.onRefresh();
    });
  }

  void _onDeleteComment(DocCommentsController c, CommentDetailSeri data) {
    if (data.userId == App.userProvider.data!.id) {
      Util.showConfirmDialog(
        context,
        content: '删除这条评论吗?',
        confirmCallback: () {
          Util.futureWrap(
            ApiRepository.deleteComment(data.id),
            onData: (dynamic data) {
              c.onRefresh();
              Util.toast('删除成功');
            },
            onError: (err) {
              Util.toast('删除失败: $err');
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GetBuilder<DocCommentsController>(
        tag: widget.tag,
        builder: (c) {
          final commentWidget = c.stateBuilder(
            onIdle: () => Scrollbar(
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                controller: widget.scrollController,
                child: Column(
                  children: c.comments!.mapWidget(
                    (data) => CommentDetailItemWidget(
                      current: data,
                      comments: c.comments,
                      onTap: () => _onReplyTo(c, data),
                      onLongPressed: () => _onDeleteComment(c, data),
                    ),
                  ),
                ),
              ),
            ),
          );
          return Container(
            margin: EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    bottom: 4,
                  ),
                  child: Text(
                    "评论 ${c.comments!.length}",
                    style: AppStyles.textStyleBp,
                  ),
                ),
                Expanded(
                  child: commentWidget.onlyIf(
                    !GetUtils.isNullOrBlank(c.comments)!,
                    animation: false,
                    elseif: () => Text(
                      '还没有人评论呢！\n'
                      '来做第一个评论的吧',
                      style: AppStyles.textStyleC,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                _buildCommentEditor(c),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentEditor(DocCommentsController c) {
    return GetBuilder<CommentPostController>(
      tag: widget.tag,
      init: CommentPostController(c.commentableId, commentType: 'Doc'),
      builder: (comment) => Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () => _onReplyTo(c, null),
                child: Container(
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    '说点什么吧...',
                    style: AppStyles.textStyleC,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                onPressed: () {
                  if (_editController.text.trim() == '') {
                    Util.toast('说点什么呢？');
                    return;
                  }
                  comment.postComment(
                    comment: _editController.text,
                    success: () {
                      Util.toast('发布成功');
                      c.onRefresh();
                      _editController.text = '';
                      Get.focusScope!.unfocus();
                    },
                    error: () {
                      Util.toast('失败了，发生什么了呢？');
                    },
                  );
                },
                child: Text(
                  "发表",
                  style: TextStyle(
                    fontFamily: "sans_bold",
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ReplyBottomSheetWidget extends StatelessWidget {
  final String hintText;
  final int? replyTo;
  final CommentPostController? postController;
  final TextEditingController? editingController;

  const ReplyBottomSheetWidget({
    Key? key,
    this.replyTo,
    this.hintText = '评论千万条，友善第一条',
    this.postController,
    this.editingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor.withOpacity(0.9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8),
          CommentTextField(
            hintText: hintText,
            controller: editingController,
            autoFocus: true,
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.centerRight,
            child: _buildCommentButton(),
          ),
        ],
      ),
    );
  }

  _buildCommentButton() {
    return GetBuilder<CommentPostController>(
      init: postController,
      autoRemove: false,
      global: false,
      builder: (c) {
        if (c.isLoadingState) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoActivityIndicator(),
          );
        }
        return TextButton(
          onPressed: () {
            if (editingController!.text.trim() == '') {
              Util.toast('😶 你要说什么呢？');
              return;
            }
            c.postComment(
              parentId: replyTo,
              comment: editingController!.text,
              success: () {
                editingController!.text = '';
                if (Get.isBottomSheetOpen!) {
                  Get.back();
                }
                if (Get.focusScope!.hasFocus) {
                  Get.focusScope!.unfocus();
                }
                Util.toast('🎉 成功');
              },
              error: () {
                Util.toast('💔 失败');
              },
            );
          },
          child: Text(
            replyTo != null ? '回复' : '评论',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        );
      },
    );
  }
}

class CommentTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final FocusNode? focusNode;
  final int maxLines;
  final bool autoFocus;

  CommentTextField({
    Key? key,
    this.hintText = "说点什么吧⋯⋯",
    this.controller,
    this.focusNode,
    this.autoFocus = false,
    this.maxLines = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      maxLines: maxLines,
      autofocus: autoFocus,
      // 是否自动更正
      autocorrect: true,
      // 是否自动对焦
      // autofocus: autofocus,
      focusNode: focusNode,
      decoration: InputDecoration(
        // labelText: "标 题",
        // labelStyle: TextStyle(textBaseline: TextBaseline.alphabetic),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        contentPadding: EdgeInsets.all(15.0),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.black26,
          fontSize: 16,
        ),
      ),
      // 输入样式
      style: AppStyles.textStyleBBB,
    );
  }
}
