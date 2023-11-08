// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_app/models/thumb.dart';
import 'package:provider/provider.dart';

import '../blocs/MovieBloc.dart';
import '../models/cart_model.dart';
import '../models/categories.dart';
import '../models/movie.dart';

class MyCatalog extends StatelessWidget {
  final List<Photo> photos;

  const MyCatalog({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MoviesBloc>();
    bloc.fetchAllMovies();
    final data = context.read<CartModel>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Popular Movies'),
        ),
        body:
        StreamBuilder(
          stream: bloc.allMovies,
          builder: (context, AsyncSnapshot<ItemModel> snapshot) {
            if (snapshot.hasData) {
              return buildList(snapshot);
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        );
  }

  Widget buildList(AsyncSnapshot<ItemModel> snapshot) {
    return GridView.builder(
        itemCount: snapshot.data?.results.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (BuildContext context, int index) {
          return Image.network(
            'https://image.tmdb.org/t/p/w185${snapshot.data?.results[index].poster_path}',
            fit: BoxFit.cover,
          );
        });
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
    var _item = Item(item.id, item.name);

    var textTheme = Theme.of(context).textTheme.titleLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LimitedBox(
        maxHeight: 48,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                child: Image.network(photo?.url ?? ""),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(_item.name, style: textTheme),
            ),
            const SizedBox(width: 24),
            _AddButton(item: _item),
          ],
        ),
      ),
    );
  }
}
// CustomScrollView(
// slivers: [
// _MyAppBar(),
// SliverList(
// delegate: SliverChildBuilderDelegate(
// (ctx, index) {
// return Builder(builder: (context) {
// final item = context.select<CatalogModel, Item>(
// (cart) => cart.getByPosition(index));
// return _MyListItem(item, null);
// });
// },
// ),
// )
// ],
// )