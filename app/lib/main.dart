import 'package:digital_signage/api/clients/device_api_client.dart';
import 'package:digital_signage/api/clients/layers_api_client.dart';
import 'package:digital_signage/api/clients/screen_api_client.dart';
import 'package:digital_signage/api/clients/slide_api_client.dart';
import 'package:digital_signage/router.dart';
import 'package:digital_signage/states/devices_state.dart';
import 'package:digital_signage/states/overview_state.dart';
import 'package:digital_signage/states/screens_state.dart';
import 'package:digital_signage/states/server_state.dart';
import 'package:digital_signage/states/slides_state.dart';
import 'package:digital_signage/views/server_selector/server_selection_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'api/clients/http_client.dart';
import 'offline_editor_route.dart';

void main() {
  runApp(const DigitalSignageApp());
}

class DigitalSignageApp extends StatelessWidget {
  const DigitalSignageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ServerCubit()),
        RepositoryProvider(create: (context) => HttpClient(context.read())),
        RepositoryProvider(
            create: (context) => DevicesApiClient(httpClient: context.read())),
        RepositoryProvider(
            create: (context) => ScreensApiClient(httpClient: context.read())),
        RepositoryProvider(
            create: (context) => SlidesApiClient(httpClient: context.read())),
        RepositoryProvider(
            create: (context) => LayersApiClient(httpClient: context.read())),
        BlocProvider(create: (context) => DevicesCubit(context.read())),
        BlocProvider(create: (context) => ScreensCubit(context.read())),
        BlocProvider(create: (context) => SlidesCubit(context.read(), context.read())),
        BlocProvider(create: (context) => OverviewCubit()),
      ],
      child: BlocBuilder<ServerCubit, ServerState>(builder: (context, state) {
        var theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple, brightness: Brightness.dark),
          useMaterial3: true,
        );
        if (state.offline) {
          return MaterialApp(
            title: 'Digital Signage',
            theme: theme,
            home: OfflineEditorRoute(),
          );
        } else if (state.selectedServer == null) {
          return MaterialApp(
            title: 'Digital Signage',
            theme: theme,
            builder: (context, child) {
              return const ServerSelectionRoute();
            },
          );
        } else {
          return MaterialApp.router(
            routerConfig: router,
            title: 'Digital Signage',
            theme: theme,
          );
        }
      }),
    );
  }
}
