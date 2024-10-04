import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:digital_signage/api/clients/device_api_client.dart';
import 'package:digital_signage/api/models/device.dart';

class DevicesState {
  final List<DeviceModel> devices;
  final bool isLoading;
  final bool hasError;

  DevicesState(
      {required this.devices, this.isLoading = false, this.hasError = false});

  factory DevicesState.empty() {
    return DevicesState(devices: []);
  }

  DeviceModel? getDeviceById(String id) {
    return devices.firstWhereOrNull((device) => device.id == id);
  }
}

class DevicesCubit extends Cubit<DevicesState> {
  final DevicesApiClient _devicesApiClient;

  DevicesCubit(this._devicesApiClient) : super(DevicesState.empty()) {
    fetchDevices();
  }

  void fetchDevices() async {
    emit(DevicesState(devices: [], isLoading: true));
    _devicesApiClient.fetchDevices().then((devices) {
      emit(DevicesState(devices: devices));
    }).catchError((error) {
      log(error: error, error.toString());
      emit(DevicesState(devices: [], hasError: true));
    });
  }

  void setScreen(String deviceId, String monitorIdentifier, String screenId) async {
    await _devicesApiClient.setScreen(deviceId, monitorIdentifier, screenId);
    fetchDevices();
  }

  void rename(String deviceId, String name) async {
    await _devicesApiClient.renameDevice(deviceId, name);
    fetchDevices();
  }

  void delete(String deviceId) async {
    await _devicesApiClient.deleteDevice(deviceId);
    fetchDevices();
  }
}
