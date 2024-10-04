import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/states/slides_state.dart';
import 'package:digital_signage/widgets/slide_preview.dart';
import 'package:digital_signage/widgets/text_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SlideList extends StatelessWidget {
  const SlideList({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<SlidesCubit>().fetchSlides();
    return BlocBuilder<SlidesCubit, SlidesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return _buildShimmerList();
        }

        if (state.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(child: Text("Error fetching slides")),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<SlidesCubit>().fetchSlides(),
                child: const Text("Retry"),
              ),
            ],
          );
        }

        return _buildSlideList(context, state.slides);
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
      title: TextShimmer("Slide"),
      subtitle: TextShimmer("2 Slide(s)"),
    );
  }

  Widget _buildSlideList(BuildContext context, List<SlideModel> slides) {
    var size = MediaQuery.sizeOf(context);
    if (size.width < 600) {
      return ListView.builder(
        itemCount: slides.length,
        itemBuilder: (context, index) => SlideListItem(slide: slides[index]),
      );
    } else {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 500,
          childAspectRatio: 1.3,
        ),
        itemCount: slides.length,
        itemBuilder: (context, index) => SlideListItem(slide: slides[index]),
      );
    }
  }
}

class SlideListItem extends StatelessWidget {
  final SlideModel slide;

  const SlideListItem({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.go('/slides/${slide.id}');
        },
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SlidePreview(slide),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide.name,
                      style: textTheme.titleLarge,
                    ),
                    Text("${slide.layers.length} Layer(s)",
                        style: textTheme.bodyMedium),
                    Text("Used by ${slide.screenUsage} Screen(s)",
                        style: textTheme.bodySmall!.copyWith(color: Colors.white54)),
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
