import 'package:digital_signage/api/models/device.dart';
import 'package:digital_signage/api/models/screen.dart';
import 'package:digital_signage/states/devices_state.dart';
import 'package:digital_signage/states/screens_state.dart';
import 'package:digital_signage/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'dialogs/rename_device_dialog.dart';
import 'dialogs/select_screen_dialog.dart';

class DeviceViewRoute extends StatelessWidget {
  final String deviceId;

  const DeviceViewRoute({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevicesCubit, DevicesState>(
      builder: (context, state) {
        var device = state.getDeviceById(deviceId);

        if (device == null) {
          return Scaffold(
            appBar:
                AppBar(leading: const BackButton(), title: Text("Loading...")),
            body: Container(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.go('/')),
            title: Text(device.name ?? device.hostname),
            actions: [
              TextButton(
                  onPressed: () async {
                    String? name = await showDialog(
                        context: context,
                        builder: (context) => RenameDeviceDialog(
                            name: device.name ?? device.hostname));
                    if (name == null) {
                      return;
                    }
                    if (!context.mounted) {
                      return;
                    }
                    context.read<DevicesCubit>().rename(device.id, name);
                  },
                  child: const Text("Rename")),
              TextButton(
                  onPressed: () {
                    ConfirmDialog.show(context, "Delete Device",
                            "Delete Device ${device.name ?? device.hostname}?")
                        .then((confirmed) {
                      if (confirmed) {
                        context.read<DevicesCubit>().delete(device.id);
                        context.go('/');
                      }
                    });
                  },
                  child: const Text("Delete")),
            ],
          ),
          body: ListView(children: [
            const SectionHeader("Device"),
            ListTile(
              title: Text(device.name ?? ""),
              subtitle: const Text("Name"),
            ),
            ListTile(
              title: Text(device.hostname),
              subtitle: const Text("Hostname"),
            ),
            ListTile(
              title: Text(device.address),
              subtitle: const Text("IP Address"),
            ),
            ListTile(
              title: Text(device.version),
              subtitle: const Text("Version"),
            ),
            const SectionHeader("Monitors"),
            ...device.monitors.map((m) => MonitorListItem(
                  m,
                  device: device,
                )),
          ]),
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String label;

  const SectionHeader(
    this.label, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 4, top: 4),
      child: Text(label,
          style: textTheme.labelMedium!.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}

class MonitorListItem extends StatelessWidget {
  final DeviceModel device;
  final DeviceMonitorModel monitor;

  const MonitorListItem(this.monitor, {required this.device, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(monitor.identifier),
      subtitle: Text("${monitor.width}x${monitor.height}"),
      trailing: Text(monitor.screen?.name ?? "No Screen"),
      onTap: () async {
        var screens = context.read<ScreensCubit>().state.screens;
        ScreenModel? screen = await showDialog(
            context: context,
            builder: (context) => SelectScreenDialog(screens: screens));
        if (screen != null) {
          if (!context.mounted) {
            return;
          }
          context
              .read<DevicesCubit>()
              .setScreen(device.id, monitor.identifier, screen.id);
        }
      },
    );
  }
}
