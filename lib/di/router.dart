import 'package:flutter/material.dart';
import 'package:flutter_app/models/movie.dart';
import 'package:flutter_app/screens/catalog.dart';
import 'package:flutter_app/screens/chat_screen.dart';
import 'package:flutter_app/screens/drawing_screen.dart';
import 'package:flutter_app/screens/learn/note_screen.dart';
import 'package:flutter_app/screens/movie_detail_screen.dart';
import 'package:flutter_app/screens/sign_up.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import 'package:flutter_app/controller/main_controller.dart';
import 'package:flutter_app/core/route_module.dart';
import 'package:flutter_app/models/thumb.dart';
import 'package:flutter_app/screens/cart.dart';
import 'package:flutter_app/screens/login.dart';

class HomeRouter extends RouteModule {
  HomeRouter._();

  static final HomeRouter I = HomeRouter._();

  @override
  Route? onGenRoute(RouteSettings? settings) {
    switch (settings?.name) {
      case '/cart':
        {
          return MaterialPageRoute(
            builder: (_) {
              return const MyCart();
            },
            settings: settings,
          );
        }
      case '/myCatalog':
        {
          return MaterialPageRoute(
            builder: (_) {
              return MyCatalog(
                photos: settings?.arguments as List<Photo>,
              );
            },
            settings: settings,
          );
        }

      case '/signup':
        {
          return MaterialPageRoute(
            builder: (_) {
              return const SignupScreen();
            },
            settings: settings,
          );
        }
      case '/detailMovie':
        {
          return MaterialPageRoute(
            builder: (_) {
              return MovieDetailScreen(movie: settings?.arguments as Movie);
            },
            settings: settings,
          );
        }
      case '/chat':
        {
          return MaterialPageRoute(
            builder: (_) {
              return const ChatScreen();
            },
            settings: settings,
          );
        }

      case '/drawing':
        {
          return MaterialPageRoute(
            builder: (_) {
              return const DrawingScreen();
            },
            settings: settings,
          );
        }
      // case '/auth_web':
      //   {
      //     return MaterialPageRoute(
      //       builder: (_) {
      //         return  WebAuthScreen();
      //       },
      //       settings: settings,
      //     );
      //   }
      default:
        {
          return MaterialPageRoute(
            builder: (_) {
              return GetBuilder<MainController>(
                init: MainController(),
                builder: (ctrl) {
                  return MyLogin();
                },
              );
            },
            settings: settings,
          );
        }
    }
  }
}
