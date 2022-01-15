import 'package:flutter/material.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:get/get.dart';
import 'package:yuyan_app/util/styles/app_ui.dart';
import 'package:yuyan_app/views/widget/editor/quill_toolbar_widget.dart';

class CommentModalSheet extends StatefulWidget {
  final Future<bool> Function(String mark) onPublish;
  final String hintText;

  CommentModalSheet({
    Key key,
    this.onPublish,
    this.hintText,
  }) : super(key: key);

  @override
  _CommentModalSheetState createState() => _CommentModalSheetState();
}

class _CommentModalSheetState extends State<CommentModalSheet> {
  final _controller = QuillController.basic();
  final _scrollController = ScrollController();
  final focusNode = FocusNode();
  final expanded = false.obs;
  final publishing = false.obs;

  @override
  Widget build(BuildContext context) {
    var editHeight = Get.height - Get.mediaQuery.viewInsets.bottom - 100;

    final editor = Obx(
      () => Container(
        constraints: BoxConstraints(
          maxHeight: editHeight,
        ),
        height: expanded.value ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
        child: QuillEditor(
          placeholder: widget.hintText,
          controller: _controller,
          padding: const EdgeInsets.only(top: 4),
          scrollController: _scrollController,
          enableInteractiveSelection: true,
          focusNode: focusNode,
          showCursor: true,
          scrollable: true,
          autoFocus: false,
          readOnly: false,
          expands: false,
        ),
      ),
    );

    final child = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: editor,
            ),
            IconButton(
              icon: Obx(
                () => Icon(
                  expanded.value ? Icons.expand_more : Icons.expand_less,
                ),
              ),
              onPressed: () {
                expanded.value = !expanded.value;
              },
            ),
          ],
        ),
        CommentToolbarWidget(
          controller: _controller,
          onPublish: widget.onPublish,
          focusNode: focusNode,
          update: () => expanded.update((_) {}),
        ),
      ],
    );

    return SafeArea(
      bottom: false,
      maintainBottomViewPadding: false,
      minimum: Get.mediaQuery.viewInsets,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(12),
          ),
        ),
        child: child,
      ),
    );
  }
}
