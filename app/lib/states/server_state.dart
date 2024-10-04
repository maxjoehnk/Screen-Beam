import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:multicast_dns/multicast_dns.dart';

class ServerState {
  final List<Server> availableServers;
  final Server? selectedServer;
  final bool offline;

  ServerState({required this.availableServers, this.selectedServer, this.offline = false});

  factory ServerState.empty() {
    return ServerState(availableServers: []);
  }
}

class ServerCubit extends Cubit<ServerState> {
  final MDnsClient _mdns = MDnsClient();

  ServerCubit() : super(ServerState.empty()) {
    refresh();
  }

  refresh() {
    _mdns.stop();
    _mdns.start().then((_) {
      return _mdns
          .lookup<PtrResourceRecord>(
          ResourceRecordQuery.serverPointer("_digital_signage._tcp"))
          .asyncMap((ptr) {
        log("Found $ptr");
        var server = _mdns
            .lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(ptr.domainName))
            .first
            .then((value) {
          log("port: $value");
          return InternetAddress.lookup(value.target).then((addresses) {
            log("addresses: $addresses");

            var address = addresses.firstWhereOrNull((element) => element.type == InternetAddressType.IPv4);

            if (address == null) {
              return null;
            }

            return Server(
                value.target,
                address,
                value.port);
          });
        });

        return server;
      }).forEach((server) {
        if (server == null) {
          return;
        }
        emit(ServerState(
          availableServers:
          _removeDuplicates([...state.availableServers, server]),
        ));
      });
    });
  }

  selectServer(Server server) {
    emit(ServerState(
      availableServers: state.availableServers,
      selectedServer: server,
    ));
  }

  offline() {
    emit(ServerState(
      availableServers: state.availableServers,
      selectedServer: null,
      offline: true,
    ));
  }

  closeOfflineEditor() {
    emit(ServerState(
      availableServers: state.availableServers,
      selectedServer: null,
      offline: false,
    ));
  }
}

class Server {
  final String name;
  final InternetAddress host;
  final int port;

  Server(this.name, this.host, this.port);

  @override
  String toString() {
    return 'Host{name: $name, host: $host, port: $port}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Server &&
        other.name == name &&
        other.host == host &&
        other.port == port;
  }

  String get baseUrl {
    return 'http://${host.address}:$port/api';
  }

  @override
  int get hashCode => name.hashCode ^ host.hashCode ^ port.hashCode;
}

List<Server> _removeDuplicates(List<Server> servers) {
  return servers.toSet().toList();
}
