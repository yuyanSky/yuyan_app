import 'package:get/get.dart';
import 'package:yuyan_app/config/app.dart';
import 'package:yuyan_app/config/service/api_repository.dart';
import 'package:yuyan_app/config/storage_manager.dart';
import 'package:yuyan_app/config/viewstate/view_controller.dart';
import 'package:yuyan_app/config/viewstate/view_state.dart';
import 'package:yuyan_app/model/document/action.dart';
import 'package:yuyan_app/model/document/book.dart';
import 'package:yuyan_app/model/document/doc.dart';
import 'package:yuyan_app/model/document/note/note.dart';
import 'package:yuyan_app/model/topic/topic.dart';
import 'package:yuyan_app/model/user/group/group.dart';
import 'package:yuyan_app/model/user/mine/mine_seri.dart';
import 'package:yuyan_app/model/user/org/organization.dart';
import 'package:yuyan_app/model/user/user.dart';

class MyUserProvider extends BaseSaveJson<MineSeri> {
  OrganizationSeri get defaultSpace {
    return OrganizationSeri(
      name: data.name,
      logo: data.avatarUrl,
      login: data.login,
    );
  }

  @override
  MineSeri convert(json) {
    return MineSeri.fromJson(json);
  }

  @override
  String get key => 'current_user';
}

class MyUserController extends FetchSavableController<MyUserProvider> {
  MyUserController()
      : super(
          initialRefresh: true,
          initData: App.userProvider,
        );

  @override
  Future fetchData() {
    return ApiRepository.getMineInfo();
  }
}

class MyGroupProvider extends BaseSaveListJson<GroupSeri> {
  @override
  List<GroupSeri> convert(json) {
    return (json as List).map((e) => GroupSeri.fromJson(e)).toList();
  }

  @override
  String get key => 'user_group';
}

class MyGroupController extends FetchSavableController<MyGroupProvider> {
  MyGroupController()
      : super(
          initialRefresh: true,
          fetchData: s,
          initData: MyGroupProvider(),
        );

  // @override
  // Future fetchData() {
  //   return ApiRepository.getGroupList();
  // }

  // @override
  // Future fetchMore() {
  //   return ApiRepository.getGroupList();
  // }
}

class MyFollowingProvider extends BaseSaveListJson<UserSeri> {
  @override
  List<UserSeri> convert(json) {
    return (json as List).map((e) => UserSeri.fromJson(e)).toList();
  }

  @override
  String get key => 'user_my_following';
}

class MyFollowingController
    extends FetchSavableController<MyFollowingProvider> {
  MyFollowingController()
      : super(
          initData: MyFollowingProvider(),
          initialRefresh: true,
        );

  int get userId => App.userProvider.data.id;

  @override
  Future fetchData() {
    return ApiRepository.getFollowingList(userId: userId);
  }

  @override
  Future fetchMore() {
    return ApiRepository.getFollowingList(
      userId: userId,
      offset: value.length,
    );
  }
}

class MyFollowerProvider extends BaseSaveListJson<UserSeri> {
  @override
  List<UserSeri> convert(json) {
    return (json as List).map((e) => UserSeri.fromJson(e)).toList();
  }

  @override
  String get key => 'user_my_follower';
}

class MyFollowerController extends FetchSavableController<MyFollowerProvider> {
  MyFollowerController()
      : super(
          initData: MyFollowerProvider(),
          initialRefresh: true,
        );

  int get userId => App.userProvider.data.id;

  @override
  Future fetchData() {
    return ApiRepository.getFollowerList(userId: userId);
  }

  @override
  Future fetchMore() {
    return ApiRepository.getFollowerList(
      userId: userId,
      offset: value.data.length,
    );
  }
}

class MyBookProvider extends BaseSaveListJson<BookSeri> {
  @override
  List<BookSeri> convert(json) {
    return (json as List).map((e) => BookSeri.fromJson(e)).toList();
  }

  @override
  String get key => 'user_my_book';
}

class MyBookController extends FetchSavableController<MyBookProvider> {
  MyBookController()
      : super(
          initData: MyBookProvider(),
          initialRefresh: true,
        );

  @override
  Future fetchData() {
    return ApiRepository.getBookList(userId: App.userProvider.data.id);
  }
}

class MyMarkProvider extends BaseSaveListJson<ActionSeri> {
  @override
  List<ActionSeri> convert(json) {
    return (json as List).map((e) => ActionSeri.fromJson(e)).toList();
  }

  @override
  String get key => 'user_my_mark';
}

class MyMarkController extends FetchSavableController<MyMarkProvider> {
  MyMarkController()
      : super(
          initData: MyMarkProvider(),
          initialRefresh: true,
        );

  @override
  Future fetchData() {
    return ApiRepository.getMarkList();
  }
}

class MyFollowBookProvider extends BaseSaveListJson<ActionSeri> {
  @override
  List<ActionSeri> convert(json) {
    return (json as List).map((e) => ActionSeri.fromJson(e)).toList();
  }

  @override
  String get key => 'user_follow_book';
}

class MyFollowBookController
    extends FetchSavableController<MyFollowBookProvider> {
  MyFollowBookController()
      : super(
          initData: MyFollowBookProvider(),
          initialRefresh: true,
        );

  @override
  Future fetchData() {
    return ApiRepository.getFollowBookList();
  }
}

class MyTopicProvider extends BaseSaveListJson<TopicSeri> {
  final String saveKey;

  MyTopicProvider(this.saveKey);

  @override
  List<TopicSeri> convert(json) {
    return (json as List).map((e) => TopicSeri.fromJson(e)).toList();
  }

  @override
  String get key => saveKey;
}

class MyTopicController extends FetchSavableController<MyTopicProvider> {
  final String topicState;

  MyTopicController({
    required this.topicState,
  }) : super(
          initData: MyTopicProvider('my_user_topic_$topicState'),
          initialRefresh: true,
        );

  @override
  Future fetchData() {
    return ApiRepository.getMyTopics(
      type: 'participated',
      state: topicState,
    );
  }
}

class MyNoteProvider extends BaseSaveListJson<NoteSeri> {
  @override
  List<NoteSeri> convert(json) {
    return (json as List).map((e) => NoteSeri.fromJson(e)).toList();
  }

  @override
  String get key => 'user_notes';
}

class MyNoteController extends FetchSavableController<MyNoteProvider> {
  static MyNoteController get to => Get.find();

  void remove(NoteSeri item) {
    value.remove(item);
    update();
  }

  MyNoteController()
      : super(
          initialRefresh: true,
          initData: MyNoteProvider(),
        );

  @override
  Future fetchMore() {
    return ApiRepository.getMyNoteList(offset: value.data.length);
  }

  @override
  Future fetchData() {
    return ApiRepository.getMyNoteList();
  }
}

class MyHistProvider extends BaseSaveListJson<DocSeri> {
  @override
  List<DocSeri> convert(json) {
    return (json as List).map((e) => DocSeri.fromJson(e)).toList();
  }

  @override
  String get key => 'user_docs_recent_read';
}

class MyHistController extends FetchSavableController<MyHistProvider> {
  MyHistController()
      : super(
          initData: MyHistProvider(),
          initialRefresh: true,
          state: ViewState.loading,
        );

  @override
  Future fetchData() {
    return ApiRepository.getMineDocs();
  }

  @override
  Future fetchMore() {
    return ApiRepository.getMineDocs(offset: value.length);
  }
}
