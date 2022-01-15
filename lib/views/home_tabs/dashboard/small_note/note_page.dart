import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:yuyan_app/config/route_manager.dart';
import 'package:yuyan_app/config/service/api_repository.dart';
import 'package:yuyan_app/controller/home/personal/my_controller.dart';
import 'package:yuyan_app/controller/organization/user/user_controller.dart';
import 'package:yuyan_app/model/document/note/note.dart';
import 'package:yuyan_app/util/styles/app_ui.dart';
import 'package:yuyan_app/util/util.dart';
import 'package:yuyan_app/views/widget/lake/lake_render.dart';
import 'package:yuyan_app/views/widget/menu_item.dart';

class SmallNotePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarOpacity: 1.0,
        bottomOpacity: 5.0,
        elevation: 1,
        title: Text("小记"),
      ),
      floatingActionButton: GestureDetector(
        child: FloatingActionButton(
          onPressed: () {
            Get.toNamed(RouteName.editNote);
          },
          child: Icon(Icons.add),
        ),
      ),
      body: GetBuilder<MyNoteController>(
        init: MyNoteController(),
        builder: (c) => c.builder(
          (state) => SmartRefresher(
            controller: c.refreshController,
            onRefresh: c.onRefreshCallback,
            onLoading: c.onLoadMoreCallback,
            enablePullUp: true,
            child: ListView.builder(
              itemCount: state!.data!.length,
              itemBuilder: (_, i) {
                return _NoteItemWidget(
                  key: Key('${state.data![i].id}'),
                  item: state.data![i],
                );
              },
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}

class _NoteItemWidget extends StatelessWidget {
  final NoteSeri? item;

  const _NoteItemWidget({
    Key? key,
    this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(25, 0, 0, 0),
            offset: Offset(1, 1),
            blurRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: _buildNoteContent(item!),
    );
  }

  _buildNoteContent(NoteSeri item) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 8),
            AppIcon.svg('notes-icon-default', size: 16),
            SizedBox(width: 8),
            Text(
              Util.timeCut(item.updatedAt!),
              style: AppStyles.countTextStyle,
            ),
            Spacer(),
            PopupMenuButton(
              icon: Icon(Icons.more_horiz),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: () {
                    BotToast.showText(text: '敬请期待');
                  },
                  child: MenuItemWidget(
                    iconData: Icons.edit,
                    title: '编辑',
                  ),
                ),
                PopupMenuItem(
                  value: () {
                    // MyRoute.webview(webUrl);
                    ApiRepository.deleteNote(item.id).then((_) {
                      if (_!) {
                        MyNoteController.to.remove(item);
                        BotToast.showText(text: '成功');
                      }
                    }).catchError((e) {
                      BotToast.showText(text: '失败');
                    });
                  },
                  child: MenuItemWidget(
                    iconData: Icons.delete,
                    title: '删除',
                  ),
                ),
              ],
              onSelected: (dynamic _) => _?.call(),
            ),
          ],
        ),
        LakeRenderWidget(
          data: item.description,
          docId: item.id,
        ),
        TextButton(
          onPressed: () {
            Get.to(
              MyNoteDetailPage(),
              binding: BindingsBuilder.put(
                () => NoteDetailController(item.id),
              ),
            );
          },
          child: Text('查看全部'),
        ).onlyIf(
          item.description!.endsWith('<!-- note-viewmore -->'),
          elseif: () => SizedBox(height: 8),
        ),
      ],
    );
  }
}

class MyNoteDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('小记详情'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: GetBuilder<NoteDetailController>(
                builder: (c) => c.stateBuilder(
                  onIdle: () => Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 4,
                    ),
                    child: LakeRenderWidget(
                      data: c.value!.doclet!.bodyAsl,
                      docId: c.value!.docletId,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
