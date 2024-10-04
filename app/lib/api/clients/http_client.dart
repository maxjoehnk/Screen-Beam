import 'dart:convert';
import 'dart:developer';

import 'package:digital_signage/states/server_state.dart';
import 'package:http/http.dart' as http;

class HttpClient {
  final http.Client _client = http.Client();
  final ServerCubit serverState;

  HttpClient(this.serverState);

  Future<http.Response> get(String url) async {
    log('get $url');
    var baseUrl = serverState.state.selectedServer?.baseUrl;
    return _client.get(Uri.parse('$baseUrl/$url'));
  }

  Future<http.Response> post(String url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    log('post $url');
    var baseUrl = serverState.state.selectedServer?.baseUrl;
    return _client.post(Uri.parse('$baseUrl/$url'), headers: headers, body: body, encoding: encoding);
  }

  Future<http.Response> put(String url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    log('put $url');
    var baseUrl = serverState.state.selectedServer?.baseUrl;
    return _client.put(Uri.parse('$baseUrl/$url'), headers: headers, body: body, encoding: encoding);
  }

  Future<http.Response> delete(String url, {Map<String, String>? headers}) {
    log('delete $url');
    var baseUrl = serverState.state.selectedServer?.baseUrl;
    return _client.delete(Uri.parse('$baseUrl/$url'), headers: headers);
  }
}
