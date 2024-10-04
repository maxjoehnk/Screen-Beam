import 'package:digital_signage/states/server_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServerSelector extends StatefulWidget {
  const ServerSelector({super.key});

  @override
  State<ServerSelector> createState() => _ServerSelectorState();
}

class _ServerSelectorState extends State<ServerSelector> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServerCubit, ServerState>(
        builder: (context, state) => Scaffold(
              appBar: AppBar(
                title: const Text("Select Server"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => context.read<ServerCubit>().refresh(),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                  onPressed: () => context.read<ServerCubit>().offline(),
                  label: Text("Open Offline Editor"),
                  icon: const Icon(Icons.edit)),
              body: Column(mainAxisSize: MainAxisSize.min, children: [
                for (var server in state.availableServers)
                  ListTile(
                    title: Text(server.name),
                    subtitle: Text(server.baseUrl),
                    onTap: () =>
                        context.read<ServerCubit>().selectServer(server),
                  ),
              ]),
            ));
  }
}
