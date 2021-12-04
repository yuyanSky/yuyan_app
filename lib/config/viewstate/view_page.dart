import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:yuyan_app/config/viewstate/view_controller.dart';
import 'package:yuyan_app/config/viewstate/view_state.dart';

class FetchRefreshListViewBuilder<T extends FetchListValueController>
    extends StatelessWidget {
  final bool nested;
  final String tag;
  final Widget Function(T) builder;
  final Widget onLoading;
  final Widget onEmpty;
  final Widget Function(ViewError error) onError;

  final Key key;

  FetchRefreshListViewBuilder({
    // Key key,
    this.key,
    this.builder,
    this.tag,
    this.onLoading,
    this.onError,
    this.onEmpty,
    this.nested = false,
  });
  // : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      tag: tag,
      autoRemove: false,
      builder: (c) {
        if (c == null) {
          return Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
              ),
            ),
            child: Text(
              'get controller: ${T.toString()} with tag: $tag'
              'resulted in a null controller'
              'did you forget to Get.put'
              'or, you just messed up with tag',
            ),
          );
        }
        return c.stateBuilder(
          onIdle: () {
            var child = Scrollbar(
              child: SmartRefresher(
                controller: c.refreshController,
                onRefresh: c.refreshCallback,
                onLoading: c.loadMoreCallback,
                enablePullUp: true,
                child: builder(c),
              ),
            );
            if (!nested) {
              return child;
            }
            return extended.NestedScrollViewInnerScrollPositionKeyWidget(
                key, child);
          },
          onLoading: onLoading,
          onEmpty: onEmpty,
          onError: onError,
        );
      },
    );
  }
}

abstract class FetchRefreshListViewPage<T extends FetchSavableController>
    extends GetView<T> {
  final String title;
  final Key key;

  FetchRefreshListViewPage({
    this.key,
    required this.title,
  }) : super(key: key);

  Widget buildChild();

  Widget buildEmpty() => null;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (c) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: controller.builder(
          (state) => AnimationLimiter(
            child: Scrollbar(
              child: SmartRefresher(
                controller: controller.refreshController,
                onRefresh: controller.onRefreshCallback,
                enablePullUp: true,
                onLoading: controller.onLoadMoreCallback,
                child: buildChild(),
              ),
            ),
          ),
          onEmpty: buildEmpty(),
        ),
      ),
    );
  }
}
