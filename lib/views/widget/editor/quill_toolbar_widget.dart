import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:delta_markdown/delta_markdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/models/documents/nodes/embed.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/toolbar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yuyan_app/config/service/api_repository.dart';
import 'package:yuyan_app/util/util.dart';

class CommentToolbarWidget extends StatefulWidget {
  final QuillController controller;
  final Future<bool> Function(String mark) onPublish;
  final FocusNode focusNode;
  final VoidCallback update;

  const CommentToolbarWidget({
    Key key,
    this.controller,
    this.onPublish,
    this.focusNode,
    this.update,
  }) : super(key: key);

  @override
  _CommentToolbarWidgetState createState() => _CommentToolbarWidgetState();
}

class _CommentToolbarWidgetState extends State<CommentToolbarWidget>
    with WidgetsBindingObserver {
  final expanded = false.obs;
  final publishing = false.obs;
  final extraView = false.obs;
  final emojiView = false.obs;

  QuillController get controller => widget.controller;

  double _keyHeight = 300;

  Future<String> _imageUpload(File file) async {
    var res = await ApiRepository.postAttachFile(
      path: file.path,
    );
    return res.url;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  _buildBottom() {
    final emojis = [
      "https://gw.alipayobjects.com/mdn/rms_15e52e/afts/img/A*UHsnTpLQ48gAAAAAAAAAAAAAARQnAQ",
      "https://gw.alipayobjects.com/mdn/rms_15e52e/afts/img/A*pm-hQY3BLV8AAAAAAAAAAAAAARQnAQ",
      "https://gw.alipayobjects.com/mdn/rms_15e52e/afts/img/A*9T62QYqFFhYAAAAAAAAAAAAAARQnAQ",
      "https://gw.alipayobjects.com/mdn/rms_15e52e/afts/img/A*BHK1RpChRAwAAAAAAAAAAAAAARQnAQ",
      "https://gw.alipayobjects.com/mdn/rms_15e52e/afts/img/A*2eERTp0nd5IAAAAAAAAAAAAAARQnAQ",
      "https://gw.alipayobjects.com/mdn/rms_15e52e/afts/img/A*b8hcRpIQ-QUAAAAAAAAAAAAAARQnAQ",
      "https://gw.alipayobjects.com/mdn/rms_15e52e/afts/img/A*TJ7dTIRWjVoAAAAAAAAAAAAAARQnAQ",
      "https://gw.alipayobjects.com/mdn/rms_15e52e/afts/img/A*qOVbRIyytEIAAAAAAAAAAAAAARQnAQ",
      "https://gw.alipayobjects.com/mdn/rms_15e52e/afts/img/A*uJPyRLbsRS4AAAAAAAAAAAAAARQnAQ",
    ];
    return Obx(
      () => Visibility(
        visible: extraView.value,
        child: Container(
          height: _keyHeight,
          child: GridView.count(
            crossAxisCount: 3,
            children: emojis.mapWidget((item) {
              // final emoji = String.fromCharCode(item);
              final child = Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(4),
                child: CachedNetworkImage(
                  imageUrl: item,
                  // width: 50,
                  // height: 50,
                  // emoji,
                  // style: TextStyle(
                  // fontSize: 20,
                  // ),
                ),
              );
              return GestureDetector(
                onTap: () {
                  final index = controller.selection.baseOffset;
                  // controller.document.insert(
                  //   index,
                  //   BlockEmbed.image(item),
                  // );
                  controller.replaceText(
                    index,
                    0,
                    BlockEmbed.image(item),
                    null,
                  );
                  controller.updateSelection(
                    TextSelection.collapsed(
                      offset: controller.selection.baseOffset + 1,
                    ),
                    ChangeSource.REMOTE,
                  );
                  // widget.update?.call();
                },
                child: child,
              );
            }),
          ),
        ),
      ),
    );
  }

  _buildBarIcons() {
    final iconSize = 18.0;
    final height = Get.mediaQuery.viewInsets.bottom;
    if (height > 150 && extraView.value) {
      extraView.value = false;
    }
    return QuillToolbar(
      multiRowsDisplay: false,
      children: [
        QuillIconButton(
          icon: Icon(
            Icons.emoji_emotions,
            size: iconSize,
          ),
          size: iconSize * 1.77,
          onPressed: () {
            extraView.value = !extraView.value;
            if (extraView.value) {
              widget.focusNode.unfocus();
            } else {
              widget.focusNode.requestFocus();
            }
          },
        ),
        SizedBox(width: 0.6),
        ToggleStyleButton(
          attribute: Attribute.bold,
          icon: Icons.format_bold,
          controller: controller,
        ),
        SizedBox(width: 0.6),
        ToggleStyleButton(
          attribute: Attribute.italic,
          icon: Icons.format_italic,
          controller: controller,
        ),
        SizedBox(width: 0.6),
        ToggleStyleButton(
          attribute: Attribute.underline,
          icon: Icons.format_underline,
          controller: controller,
        ),
        SizedBox(width: 0.6),
        // ImageButton(
        //   icon: Icons.image,
        //   controller: controller,
        //   imageSource: ImageSource.gallery,
        //   onImagePickCallback: _imageUpload,
        // ),
        // SizedBox(width: 0.6),
        // ImageButton(
        //   icon: Icons.photo_camera,
        //   controller: controller,
        //   imageSource: ImageSource.camera,
        //   onImagePickCallback: _imageUpload,
        // ),
        VerticalDivider(
          indent: 16,
          endIndent: 16,
          color: Colors.grey.shade400,
        ),
        ToggleStyleButton(
          attribute: Attribute.ol,
          controller: controller,
          icon: Icons.format_list_numbered,
        ),
        SizedBox(width: 0.6),
        ToggleStyleButton(
          attribute: Attribute.ul,
          controller: controller,
          icon: Icons.format_list_bulleted,
        ),
        SizedBox(width: 0.6),
        ToggleCheckListButton(
          attribute: Attribute.unchecked,
          controller: controller,
          icon: Icons.check_box,
        ),
        SizedBox(width: 0.6),
        ToggleStyleButton(
          attribute: Attribute.codeBlock,
          controller: controller,
          icon: Icons.code,
        ),
        SizedBox(width: 0.6),
        ToggleStyleButton(
          attribute: Attribute.blockQuote,
          controller: controller,
          icon: Icons.format_quote,
        ),
        VerticalDivider(
          indent: 16,
          endIndent: 16,
          color: Colors.grey.shade400,
        ),
        LinkStyleButton(
          controller: controller,
        ),
      ],
    );
  }

  _doPublish() async {
    try {
      publishing.value = true;
      var delta = controller.document.toDelta();
      var deltaStr = jsonEncode(delta.toJson());
      var markdown = deltaToMarkdown(deltaStr);
      var result = await widget.onPublish.call(markdown);
      publishing.value = false;
      if (result) Get.back();
    } catch (e) {
      debugPrint('convert to markdown: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: QuillToolbar.basic(
                controller: controller,
                multiRowsDisplay: false,
                onImagePickCallback: _imageUpload,
              ),
            ),
            Obx(
              () => TextButton(
                child: Text('发布'),
                onPressed: _doPublish,
              ).onlyIf(
                !publishing.value,
                elseif: () => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 22,
                  ),
                  child: CupertinoActivityIndicator(),
                ),
              ),
            ).onlyIf(widget.onPublish != null),
          ],
        ),
        _buildBottom(),
      ],
    );
  }
}
