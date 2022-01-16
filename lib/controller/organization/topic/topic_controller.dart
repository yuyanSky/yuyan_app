import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:yuyan_app/config/service/api_repository.dart';
import 'package:yuyan_app/config/viewstate/view_controller.dart';
import 'package:yuyan_app/config/viewstate/view_state.dart';
import 'package:yuyan_app/model/document/commen/comment_detail.dart';
import 'package:yuyan_app/model/meta/ability.dart';
import 'package:yuyan_app/model/topic/topic_detail_seri.dart';
import 'package:yuyan_app/util/util.dart';

class TopicDetailController extends FetchValueController<TopicDetailSeri> {
  final int? iid;
  final int? groupId;

  TopicDetailController(this.iid, this.groupId);

  MetaAbilitySeri? abilities;

  @override
  Future<TopicDetailSeri> fetch() async {
    final res =
        await ApiRepository.getTopicDetailRes(iid: iid, groupId: groupId);
    abilities = MetaAbilitySeri.fromJson(res.meta!['abilities']);
    return TopicDetailSeri.fromJson(res.data);
  }
}

class TopicCommentsController
    extends FetchListValueController<CommentDetailSeri> {
  final int? commentId;

  TopicCommentsController(this.commentId);

  @override
  Future<List<CommentDetailSeri>> fetch() {
    return ApiRepository.getCommentsList(
      commentId: commentId,
      commentType: 'Topic',
    );
  }
}

class CommentDeleteController extends FetchValueController<CommentDetailSeri> {
  final int commentId;

  CommentDeleteController(this.commentId)
      : super(
          initialFetch: false,
          initialState: ViewState.idle,
        );

  @override
  Future<CommentDetailSeri> fetch() {
    return ApiRepository.deleteComment(commentId);
  }
}

class CommentPostController extends FetchValueController<CommentDetailSeri> {
  final int? commentId;
  final String commentType;

  CommentPostController(
    this.commentId, {
    this.commentType = 'Topic',
  }) : super(
          initialFetch: false,
          initialState: ViewState.idle,
        );

  String? _comment;
  int? _parentId;

  postComment({
    required String comment,
    int? parentId,
    VoidCallback? success,
    VoidCallback? error,
    bool convert = false,
  }) async {
    _comment = comment;
    _parentId = parentId;
    if (convert) {
      _comment = await ApiRepository.convertLake(markdown: comment);
    }
    await onRefresh(force: true);
    if (isErrorState) {
      error?.call();
    } else {
      success?.call();
    }
  }

  @override
  onError() {
    Util.toast('出错了：${error!.content}');
  }

  @override
  Future<CommentDetailSeri> fetch() {
    return ApiRepository.postComment(
      commentType: commentType,
      commentId: commentId,
      parentId: _parentId,
      comment: _comment,
    );
  }
}
