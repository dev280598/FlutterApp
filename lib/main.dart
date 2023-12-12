import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/blocs/movie_bloc.dart';
import 'package:flutter_app/common/app.dart';
import 'package:flutter_app/common/theme.dart';
import 'package:flutter_app/controller/main_controller.dart';
import 'package:flutter_app/di/injection.dart';
import 'package:flutter_app/di/router.dart';
import 'package:flutter_app/domain/repository/data_repo.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/lang/localization_service.dart';
import 'package:flutter_app/models/cart_model.dart';
import 'package:flutter_app/models/categories.dart';
import 'package:flutter_app/screens/view/drawing_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

bool shouldUseFirebaseEmulator = false;

late final FirebaseApp app;
late final FirebaseAuth auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);

  if (shouldUseFirebaseEmulator) {
    await auth.useAuthEmulator('localhost', 9099);
  }
  configureDependencies();
  runApp(const MyApp());
}

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

  final MainController controller = Get.find();

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    countStream().listen((event) {});
    _streamController.stream.listen((event) {
      debugPrint('=====yield$event');
    });
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
            debugPrint('=====$snapShot');
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
                    snapShot.hasData ? snapShot.data : '',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            );
          },
        ),
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
        Provider(
          create: (_) => MoviesBloc(
            repository: appInject.get<Repository>(),
          ),
        ),
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
      child: GetMaterialApp(
        title: 'Provider Demo',
        theme: appTheme,
        translations: LocalizationService(),
        locale: LocalizationService.locale,
        fallbackLocale: LocalizationService.fallback,
        // initialRoute: "/login",
        onGenerateRoute: (settings) {
          debugPrint('settings.name $settings');
          return HomeRouter.I.onGenRoute(settings);
        },
      ),
    );
  }
}
const html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Grant Access to Flutter</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    html, body { margin: 0; padding: 0; }
    main {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      font-family: -apple-system,BlinkMacSystemFont,Segoe UI,Helvetica,Arial,sans-serif,Apple Color Emoji,Segoe UI Emoji,Segoe UI Symbol;
    }
    #icon {
      font-size: 96pt;
    }
    #text {
      padding: 2em;
      max-width: 260px;
      text-align: center;
    }
    #button a {
      display: inline-block;
      padding: 6px 12px;
      color: white;
      border: 1px solid rgba(27,31,35,.2);
      border-radius: 3px;
      background-image: linear-gradient(-180deg, #34d058 0%, #22863a 90%);
      text-decoration: none;
      font-size: 14px;
      font-weight: 600;
    }
    #button a:active {
      background-color: #279f43;
      background-image: none;
    }
  </style>
</head>
<body>
  <main>
    <div id="icon">&#x1F3C7;</div>
    <div id="text">Press the button below to sign in using your Localtest.me account.</div>
    <div id="button"><a href="foobarmobile://success?code=1337">Sign in</a></div>
  </main>
</body>
</html>
''';