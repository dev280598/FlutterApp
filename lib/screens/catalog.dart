// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/controller/main_controller.dart';
import 'package:flutter_app/models/cart_model.dart';
import 'package:flutter_app/models/categories.dart';
import 'package:flutter_app/models/movie.dart';
import 'package:flutter_app/models/thumb.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MyCatalog extends StatefulWidget {
  final List<Photo> photos;

  const MyCatalog({super.key, required this.photos});

  @override
  State<MyCatalog> createState() => _MyCatalogState();
}

class _MyCatalogState extends State<MyCatalog> {
  MainController get controller => Get.find();

  @override
  Widget build(BuildContext context) {
    controller.fetchAllMovies();
    // final data = context.read<CartModel>();
    return StreamBuilder(
      stream: controller.allMovies,
      builder: (context, AsyncSnapshot<ItemModel> snapshot) {
        if (snapshot.hasData) {
          return buildList(snapshot, controller.count.value);
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget buildList(AsyncSnapshot<ItemModel> snapshot, [int size = 0]) {
    return GridView.builder(
      itemCount: (snapshot.data?.results.length ?? 0),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              '/detailMovie',
              arguments: snapshot.data?.results[index],
            );
          },
          child: CachedNetworkImage(
            imageUrl:
                'https://image.tmdb.org/t/p/w185${snapshot.data?.results[index].poster_path}',
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        );
      },
    );
  }
}

class _AddButton extends StatelessWidget {
  final Item item;

  const _AddButton({required this.item});

  @override
  Widget build(BuildContext context) {
    // The context.select() method will let you listen to changes to
    // a *part* of a model. You define a function that "selects" (i.e. returns)
    // the part you're interested in, and the provider package will not rebuild
    // this widget unless that particular part of the model changes.
    //
    // This can lead to significant performance improvements.
    var isInCart = context.select<CartModel, bool>(
      // Here, we are only interested whether [item] is inside the cart.
      (cart) => cart.items.contains(item),
    );

    return TextButton(
      onPressed: isInCart
          ? null
          : () {
              // If the item is not in cart, we let the user add it.
              // We are using context.read() here because the callback
              // is executed whenever the user taps the button. In other
              // words, it is executed outside the build method.
              var cart = context.read<CartModel>();
              cart.add(item);
            },
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.pressed)) {
            return Theme.of(context).primaryColor;
          }
          return null; // Defer to the widget's default.
        }),
      ),
      child: isInCart
          ? const Icon(Icons.check, semanticLabel: 'ADDED')
          : const Text('ADD'),
    );
  }
}

class _MyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text('Catalog', style: Theme.of(context).textTheme.displayLarge),
      floating: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => Navigator.of(context).pushNamed('/cart'),
        ),
      ],
    );
  }
}

class _MyListItem extends StatelessWidget {
  final Item item;
  final Photo? photo;

  const _MyListItem(this.item, this.photo);

  @override
  Widget build(BuildContext context) {
    var mItem = Item(item.id, item.name);

    var textTheme = Theme.of(context).textTheme.titleLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LimitedBox(
        maxHeight: 48,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(photo?.url ?? ''),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(mItem.name, style: textTheme),
            ),
            const SizedBox(width: 24),
            _AddButton(item: mItem),
          ],
        ),
      ),
    );
  }
}
