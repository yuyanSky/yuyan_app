import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yuyan_app/config/app.dart';
import 'package:yuyan_app/controller/organization/organization_controller.dart';
import 'package:yuyan_app/views/organization/widget/org_spacet.dart';
import 'package:yuyan_app/views/search/search_action_widget.dart';
import 'tabs/attention_page.dart';

class DiscoverTab extends StatefulWidget {
  final Key key;

  DiscoverTab({this.key}) : super(key: key);

  _DiscoverTabState createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CurrSpaceProvider>(
      init: App.currentSpaceProvider,
      builder: (c) => Scaffold(
        appBar: AppBar(
          toolbarOpacity: 1.0,
          bottomOpacity: 5.0,
          leading: OrgSpaceLeadingWidget(),
          actions: [
            SearchActionWidget(),
          ],
          elevation: 0.0,
          title: Tab(text: "关注"),

          // TabBar(
          //   controller: _tabController,
          //   labelColor: Colors.white,
          //   indicatorColor: Colors.white.withOpacity(0.95),
          //   indicatorSize: TabBarIndicatorSize.label,
          //   indicatorWeight: 3.0,
          //   tabs: [
          //     Tab(text: "关注"),
          //     Tab(text: "精选").onlyIf(
          //       c.isDefault,
          //       elseif: () => Tab(
          //         text: '空间',
          //       ),
          //     ),
          //   ],
          // ),
        ),
        body: AttentionPage(),

        // TabBarView(
        //   key: PageStorageKey('tab1_page'),
        //   controller: _tabController,
        //   children: [
        //     AttentionPage(),
        //     SelectionPage().onlyIf(
        //       c.isDefault,
        //       elseif: () => SpacePubPage(),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
