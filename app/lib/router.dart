import 'package:digital_signage/views/slide_view/slide_view_route.dart';
import 'package:go_router/go_router.dart';

import 'views/device_view/device_view_route.dart';
import 'views/overview/overview_route.dart';
import 'views/screen_view/screen_view_route.dart';

final router = GoRouter(routes: [
  GoRoute(path: '/', builder: (context, state) => const OverviewRoute()),
  GoRoute(
      path: '/devices/:deviceId',
      builder: (context, state) {
        final deviceId = state.pathParameters['deviceId']!;

        return DeviceViewRoute(deviceId: deviceId);
      }),
  GoRoute(
      path: '/screens/:screenId',
      builder: (context, state) {
        final screenId = state.pathParameters['screenId']!;

        return ScreenViewRoute(screenId: screenId);
      }),
  GoRoute(
      path: '/slides/:slideId',
      builder: (context, state) {
        final slideId = state.pathParameters['slideId']!;

        return SlideViewRoute(slideId: slideId);
      }),
]);
