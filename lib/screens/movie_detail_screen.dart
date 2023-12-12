import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/movie.dart';
import 'package:get/get.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            floating: true,
            pinned: true,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            snap: true,
            elevation: 50,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl:
                    'https://image.tmdb.org/t/p/w185${movie.backdrop_path}',
                height: 220,
                width: Get.width,
                fit: BoxFit.cover,
              ),
              centerTitle: true,
              title: Text(
                movie.original_title ?? '',
                style: Get.textTheme.titleMedium?.apply(color: Colors.white),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0).copyWith(bottom: 0),
              child: Text(
                movie.original_title ?? '',
                style: Get.textTheme.titleMedium,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0).copyWith(top: 0),
              child: Text(
                'Vote count : ${movie.vote_count}',
                style: Get.textTheme.titleMedium,
                textAlign: TextAlign.end,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0).copyWith(top: 0),
              child: Text(
                movie.overview ?? '',
                style: Get.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
