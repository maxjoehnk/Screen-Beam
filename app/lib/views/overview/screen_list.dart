import 'package:digital_signage/api/models/screen.dart';
import 'package:digital_signage/states/screens_state.dart';
import 'package:digital_signage/widgets/text_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ScreenListPage extends StatelessWidget {
  const ScreenListPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ScreensCubit>().fetchScreens();
    return BlocBuilder<ScreensCubit, ScreensState>(
      builder: (context, state) {
        if (state.isLoading) {
          return _buildShimmerList();
        }

        if (state.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Text("Error fetching screens")),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<ScreensCubit>().fetchScreens(),
                child: Text("Retry"),
              ),
            ],
          );
        }

        return _buildScreenList(state.screens);
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
      title: TextShimmer("Screen"),
      subtitle: TextShimmer("2 Slide(s)"),
    );
  }

  Widget _buildScreenList(List<ScreenModel> screens) {
    return ListView.builder(
      itemCount: screens.length,
      itemBuilder: (context, index) => ScreenListItem(screen: screens[index]),
    );
  }
}

class ScreenListItem extends StatelessWidget {
  final ScreenModel screen;

  const ScreenListItem({super.key, required this.screen});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(screen.name),
      subtitle: Text("${screen.slides.length} Slide(s)"),
      trailing: Text("Used by ${screen.monitorUsage} Monitor(s)"),
      onTap: () => context.go('/screens/${screen.id}'),
    );
  }
}
