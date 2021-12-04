import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yuyan_app/config/route_manager.dart';
import 'package:yuyan_app/config/viewstate/view_page.dart';
import 'package:yuyan_app/controller/home/personal/my_controller.dart';
import 'package:yuyan_app/model/document/doc.dart';
import 'package:yuyan_app/util/styles/app_ui.dart';
import 'package:yuyan_app/util/util.dart';
import 'package:yuyan_app/views/home_tabs/discover/widget/doc_tile_widget.dart';

class MyHistPage extends FetchRefreshListViewPage<MyHistController> {
  MyHistPage() : super(title: "最近浏览");

  @override
  Widget buildChild() {
    var data = controller.value.data;
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (_, index) {
        final item = data[index];
        DocTileWidget();
        return DocHistWidget(
          item: item,
        );
      },
    );
  }
}

class DocHistWidget extends StatelessWidget {
  final DocSeri item;

  DocHistWidget({
    Key? key,
    this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AppIcon.svg(item.type, size: 28).paddingOnly(left: 8, top: 4),
      title: Text('${item.title}'),
      subtitle: Text('${Util.timeCut(item.updatedAt)}'),
      onTap: () => MyRoute.docDetailWebview(
        bookId: item.book.id,
        slug: item.slug,
        login: item.book.user.login,
        book: item.book.slug,
      ),
    );
  }
}
