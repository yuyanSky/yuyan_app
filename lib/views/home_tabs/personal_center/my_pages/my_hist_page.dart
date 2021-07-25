import 'package:flutter/material.dart';
import 'package:yuyan_app/config/viewstate/view_page.dart';
import 'package:yuyan_app/controller/home/personal/my_controller.dart';
import 'package:yuyan_app/model/document/doc.dart';
import 'package:yuyan_app/views/home_tabs/discover/widget/doc_tile_widget.dart';

class MyHistPage extends FetchRefreshListViewPage<MyHistController> {
  MyHistPage() : super(title: "我的团队");

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
    Key key,
    this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${item.title}'),
    );
  }
}
