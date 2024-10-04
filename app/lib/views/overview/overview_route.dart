import 'package:digital_signage/states/devices_state.dart';
import 'package:digital_signage/states/overview_state.dart';
import 'package:digital_signage/states/slides_state.dart';
import 'package:digital_signage/views/overview/device_list.dart';
import 'package:digital_signage/views/overview/dialogs/add_slide_dialog.dart';
import 'package:digital_signage/views/overview/screen_list.dart';
import 'package:digital_signage/views/overview/slide_list.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../states/screens_state.dart';
import 'dialogs/add_screen_dialog.dart';

final _availableTabs = [
  const OverviewTab(
      icon: Icons.devices, label: "Devices", widget: DeviceList()),
  OverviewTab(
      icon: Icons.screenshot_monitor,
      label: "Screens",
      widget: const ScreenListPage(),
      fabBuilder: (context) => FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text("Add Screen"),
          onPressed: () async {
            String? name = await showDialog(
                context: context,
                builder: (context) => const AddScreenDialog());
            if (name == null) {
              return;
            }
            if (!context.mounted) {
              return;
            }
            await context.read<ScreensCubit>().addScreen(name);
          })),
  OverviewTab(
      icon: Icons.layers,
      label: "Slides",
      widget: const SlideList(),
      actions: [
        (context) => TextButton(
          child: const Text("Import"),
          onPressed: () async {
            var file = await openFile(acceptedTypeGroups: [XTypeGroup(
              label: 'zip',
              extensions: ['zip'],
            )]);
            if (file == null) {
              return;
            }
            var data = await file.readAsBytes();
            if (!context.mounted) {
              return;
            }
            context.read<SlidesCubit>().import(data);
          },
        )
      ],
      fabBuilder: (context) => FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text("Add Slide"),
          onPressed: () async {
            String? name = await showDialog(
                context: context, builder: (context) => const AddSlideDialog());
            if (name == null) {
              return;
            }
            if (!context.mounted) {
              return;
            }
            await context.read<SlidesCubit>().addSlide(name);
          })),
];

class OverviewTab {
  final IconData icon;
  final String label;
  final Widget widget;
  final Widget Function(BuildContext)? fabBuilder;
  final List<WidgetBuilder> actions;

  const OverviewTab(
      {required this.icon,
      required this.label,
      required this.widget,
      this.actions = const [],
      this.fabBuilder});
}

class OverviewRoute extends StatefulWidget {
  const OverviewRoute({super.key});

  @override
  State<OverviewRoute> createState() => _OverviewRouteState();
}

class _OverviewRouteState extends State<OverviewRoute> {
  late final PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: context.read<OverviewCubit>().state.currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digital Signage"),
        actions: [
          for (var action in currentTab.actions) action(context),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DevicesCubit>().fetchDevices();
              context.read<ScreensCubit>().fetchScreens();
              context.read<SlidesCubit>().fetchSlides();
            },
          )
        ],
      ),
      body: Row(
        children: [
          if (!isMobile) NavigationRail(
            labelType: NavigationRailLabelType.all,
            destinations: _availableTabs
                .map((tab) =>
                NavigationRailDestination(icon: Icon(tab.icon), label: Text(tab.label)))
                .toList(),
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              _pageController
                  .animateToPage(index,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut)
                  .then((value) {
                    setState(() {});
                    context.read<OverviewCubit>().changeTab(index);
                  });
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: _availableTabs.map((tab) => tab.widget).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: currentTab.fabBuilder == null
          ? null
          : currentTab.fabBuilder!(context),
      bottomNavigationBar: isMobile ? BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          _pageController
              .animateToPage(index,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut)
              .then((value) {
                setState(() {});
                context.read<OverviewCubit>().changeTab(index);
              });
        },
        items: _availableTabs
            .map((tab) =>
                BottomNavigationBarItem(icon: Icon(tab.icon), label: tab.label))
            .toList(),
      ) : null,
    );
  }

  int get currentIndex {
    return _pageController.positions.isEmpty
        ? _pageController.initialPage
        : _pageController.page?.round() ?? _pageController.initialPage;
  }

  OverviewTab get currentTab {
    return _availableTabs[currentIndex];
  }
}
