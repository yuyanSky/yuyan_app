import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:yuyan_app/config/service/api_repository.dart';
import 'package:yuyan_app/config/viewstate/view_state_widget.dart';
import 'package:yuyan_app/controller/organization/doc/upload_controller.dart';
import 'package:yuyan_app/util/util.dart';
import 'package:yuyan_app/views/home_tabs/dashboard/note_editor/view/push_note_icon.dart';

class SmallNoteEditor extends StatefulWidget {
  @override
  _SmallNoteEditorState createState() => _SmallNoteEditorState();
}

class _SmallNoteEditorState extends State<SmallNoteEditor> {
  QuillController _controller = QuillController.basic();

  ScrollController _scrollController = ScrollController();
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Get.put(NoteStatusController());
  }

  @override
  Widget build(BuildContext context) {
    final loading = Scaffold(appBar: AppBar());
    // final toolbar =
    return GetBuilder<NoteStatusController>(
      builder: (c) => c.stateBuilder(
        onLoading: loading,
        onIdle: () {
          return Scaffold(
            appBar: AppBar(
              // title: Text('小记'),
              actions: [_publish(c.value!.mirror!.id!)],
            ),
            body: Column(
              children: [
                QuillToolbar.basic(
                  controller: _controller,
                  multiRowsDisplay: false,
                  onImagePickCallback: (file) async {
                    var controller = Get.find<NoteStatusController>();
                    var res = await ApiRepository.postAttachFile(
                      path: file.path,
                      attachableType: 'Doclet',
                      attachableId: controller.value!.mirror!.docletId,
                    );
                    // Get.lazyPut(() => ImageUploadController(file.path, attachId),
                    //     tag: '${file.path}');
                    // return file.path;
                    return res.url;
                  },
                ),
                Expanded(
                  child: QuillEditor(
                    scrollController: _scrollController,
                    autoFocus: false,
                    padding: const EdgeInsets.all(8),
                    controller: _controller,
                    readOnly: false,
                    scrollable: true,
                    expands: true,
                    focusNode: _focusNode,
                    onLaunchUrl: (url) {
                      debugPrint('launch url => $url');
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _publish(int mirrorId) {
    return GetBuilder<PostNoteController>(
      init: PostNoteController(mirrorId),
      builder: (pub) {
        if (pub.isLoadingState) return ViewLoadingWidget();
        return PushNoteIcon(
          onPressed: () async {
            debugPrint('发布');
            var delta = _controller.document.toDelta();
            var res = await pub.postNote(delta);
            Util.toast(res ? '发布成功' : '发布失败');
            if (res) Get.back();
          },
        );
      },
    );
  }
}
