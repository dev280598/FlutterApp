import 'package:flutter/material.dart';
import 'package:flutter_app/common/app.dart';
import 'package:flutter_app/domain/repository/data_repo.dart';
import 'package:flutter_app/screens/catalog.dart';
import 'package:provider/provider.dart';

import '../blocs/MovieBloc.dart';
import '../core/route_module.dart';
import '../models/thumb.dart';
import '../screens/cart.dart';
import '../screens/login.dart';

class HomeRouter extends RouteModule {
  HomeRouter._();

  static final HomeRouter I = HomeRouter._();

  @override
  Route? onGenRoute(RouteSettings? settings) {
    switch (settings?.name) {
      case "/cart":
        {
          return MaterialPageRoute(
            builder: (_) {
              return MyCart();
            },
            settings: settings,
          );
        }
      case "/myCatalog":
        {
          return MaterialPageRoute(
            builder: (_) {
              return Provider(
                  create: (_) => MoviesBloc(repository: appInject.get<Repository>()),
                  builder: (_, __) {
                    return MyCatalog(
                      photos: settings?.arguments as List<Photo>,
                    );
                  });
            },
            settings: settings,
          );
        }
      default:
        {
          return MaterialPageRoute(
            builder: (_) {
              return  MyLogin();
            },
            settings: settings,
          );
        }
    }
  }

}