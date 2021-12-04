import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:yuyan_app/views/component/image_page/image_view_page.dart';

import '../lake_render.dart';

class LakeImageWidget extends StatelessWidget {
  final Map json;
  final List<String> others;
  final Size size;
  final EdgeInsets margin;

  const LakeImageWidget({
    Key? key,
    this.json,
    this.others,
    this.size,
    this.margin = const EdgeInsets.all(4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var imageUrl = json['src'] as String;
    if (imageUrl.startsWith('//')) {
      imageUrl = 'https:' + imageUrl;
    }
    if (json['status'] != null && json['status'] != 'done') {
      return SizedBox.shrink();
    }
    var isSvg = imageUrl.endsWith('.svg');
    if (!isSvg) others?.add(imageUrl);
    var width = HtmlUtil.parseDouble(json['width']);
    var height = HtmlUtil.parseDouble(json['height']);
    if (width != null && height != null) {
      var ratio = width / height;
      width = width.clamp(0, Get.width);
      height = width / ratio;
    }
    if (width == null && height == null && size != null) {
      width = size.width;
      height = size.height;
    }
    Widget child;
    if (isSvg) {
      child = SvgPicture.network(
        imageUrl,
        fit: BoxFit.contain,
        width: width,
        height: height,
      );
    } else {
      child = CachedNetworkImage(
        fit: BoxFit.contain,
        imageUrl: imageUrl,
        width: width,
        height: height,
      );
    }
    return GestureDetector(
      onTap: () {
        if (!isSvg) {
          Get.dialog(
            ImageViewerPage(
              initUrl: imageUrl,
              imageUrls: others,
            ),
          );
        }
      },
      child: Container(
        margin: margin,
        child: child,
      ),
    );
  }
}

class CachedImageWidget extends StatelessWidget {
  final String url;

  const CachedImageWidget({
    Key? key,
    this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => FlareActor(
        "assets/flares/progress.flr",
        animation: "active",
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
      fit: BoxFit.contain,
    );
  }
}
