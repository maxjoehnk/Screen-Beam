import 'package:digital_signage/api/models/device.dart';
import 'package:digital_signage/states/devices_state.dart';
import 'package:digital_signage/widgets/text_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DeviceList extends StatelessWidget {
  const DeviceList({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<DevicesCubit>().fetchDevices();
    return BlocBuilder<DevicesCubit, DevicesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return _buildShimmerList();
        }

        if (state.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Text("Error fetching devices")),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<DevicesCubit>().fetchDevices(),
                child: Text("Retry"),
              ),
            ],
          );
        }

        return _buildDeviceList(state.devices);
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => _buildShimmer(),
    );
  }

  Widget _buildShimmer() {
    return const ListTile(
      title: TextShimmer("Device Name"),
      subtitle: TextShimmer("255.255.255.255"),
    );
  }

  Widget _buildDeviceList(List<DeviceModel> devices) {
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) => DeviceListItem(device: devices[index]),
    );
  }
}

class DeviceListItem extends StatelessWidget {
  final DeviceModel device;

  const DeviceListItem({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(device.name ?? device.hostname),
      subtitle: Text(device.address),
      trailing: Text("${device.monitors.length} Monitor(s)"),
      onTap: () => context.go('/devices/${device.id}'),
    );
  }
}
