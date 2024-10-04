import 'dart:convert';

import 'package:digital_signage/api/models/device.dart';

import 'http_client.dart';

class DevicesApiClient {
  final HttpClient httpClient;

  DevicesApiClient({required this.httpClient});

  Future<List<DeviceModel>> fetchDevices() async {
    final response = await httpClient.get('devices');

    if (response.statusCode != 200) {
      throw Exception('error getting devices');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return json.map((device) => DeviceModel.fromJson(device)).toList();
  }

  Future<void> setScreen(String deviceId, String monitorIdentifier, String screenId) async {
    final response = await httpClient.post(
      'devices/$deviceId/monitors/${Uri.encodeComponent(monitorIdentifier)}/screen',
      body: jsonEncode({'screenId': screenId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 204) {
      throw Exception('error setting screen');
    }
  }

  Future<void> renameDevice(String deviceId, String name) async {
    final response = await httpClient.post(
      'devices/$deviceId/name',
      body: jsonEncode({'name': name}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 204) {
      throw Exception('error setting screen');
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    final response = await httpClient.delete('devices/$deviceId');

    if (response.statusCode != 204) {
      throw Exception('error setting screen');
    }
  }
}
