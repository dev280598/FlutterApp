import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/blocs/MovieBloc.dart';
import 'package:flutter_app/common/app.dart';
import 'package:flutter_app/domain/repository/data_repo.dart';
import 'package:flutter_app/models/thumb.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'common/theme.dart';
import 'di/injection.dart';
import 'di/router.dart';
import 'models/cart_model.dart';
import 'models/categories.dart';
import 'screens/cart.dart';
import 'screens/catalog.dart';
import 'screens/login.dart';

void main() {
  configureDependencies();
  runApp(const MyApp());
}
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  final StreamController _streamController = StreamController();

  final WebSocketChannel _channel =
      WebSocketChannel.connect(Uri.parse('wss://echo.websocket.events'));

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    countStream().listen((event) {});
    _streamController.stream.listen((event) {
      print("=====yield${event}");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: StreamBuilder(
            stream: _channel.stream,
            builder: (context, snapShot) {
              print("=====${snapShot}");
              return Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Form(
                      child: TextFormField(
                        controller: _controller,
                        decoration:
                            const InputDecoration(labelText: 'Send a message'),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      snapShot.hasData ? snapShot.data : "",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Increment',
        child: const Icon(Icons.send_rounded),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(_controller.text);
    }
  }

  Stream<int> countStream() async* {
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 1));
      _streamController.add(i);
      _streamController.sink.add(i);
      // yield i;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// update code
    // Using MultiProvider is convenient when providing multiple objects.
    return MultiProvider(
      providers: [
        // In this sample app, CatalogModel never changes, so a simple Provider
        // is sufficient.
        Provider(create: (context) => CatalogModel()),
        // CartModel is implemented as a ChangeNotifier, which calls for the use
        // of ChangeNotifierProvider. Moreover, CartModel depends
        // on CatalogModel, so a ProxyProvider is needed.
        ChangeNotifierProxyProvider<CatalogModel, CartModel>(
          create: (context) => CartModel(),
          update: (context, catalog, cart) {
            if (cart == null) throw ArgumentError.notNull('cart');
            cart.catalog = catalog;
            return cart;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Provider Demo',
        theme: appTheme,
        initialRoute: "/login",
        onGenerateRoute: (settings) {
          print("settings.name ${settings}");
          return HomeRouter.I.onGenRoute(settings);
        },
        // routes: {
        //   "/login": (context) {
        //     return MyLogin();
        //   },
        //   "cart": (context) {
        //     return MyCart();
        //   },
        //   "/myCatalog": (context) {
        //     return MyCatalog(
        //       photos: [],
        //     );
        //   }
        // },
      ),
    );
  }
}
