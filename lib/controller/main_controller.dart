import 'dart:io' show HttpServer;
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/common/app.dart';
import 'package:flutter_app/domain/repository/data_repo.dart';
import 'package:flutter_app/lang/localization_service.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/models/movie.dart';
import 'package:flutter_app/models/thumb.dart';
import 'package:flutter_app/screens/view/drawing_page.dart';
import 'package:flutter_app/screens/widget/chat_message_widget.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;


class MainController extends GetxController {
  Repository get repository => appInject.get();

  final _moviesFetcher = rx_dart.PublishSubject<ItemModel>();

  Stream<ItemModel> get allMovies => _moviesFetcher.stream;

  var count = 0.obs;

  var isFetching = false.obs;

  var listMess = <ChatMessage>[].obs;

  var isComposing = false.obs;

  var isLogged = false.obs;

   Rx<Widget> contentView = Container().obs;

  var currentLang =
      (LocalizationService.langs[Get.deviceLocale?.languageCode] ?? '').obs;

  @override
  void onInit() {
    super.onInit();
    startServer();
  }

  Future<void> startServer() async {
    final server = await HttpServer.bind('127.0.0.1', 43823);
    server.listen((req) async {
      // isLogged.value = true;
      // contentView.value = const DrawingPage();
      debugPrint('=====startServer callback : $req');
      req.response.headers.add('Content-Type', 'text/html');
      req.response.write(html);
      req.response.close();
    });
  }
  void increment() {
    var photo = Photo(
      albumId: 1,
      id: 1,
      title: 'title',
      url: 'url',
      thumbnailUrl: 'thumbnailUrl',
    );
    photo.url = '';

    count.value++;
  }

  void fetchAllMovies() async {
    await repository.fetchAllMovies().then((value) {
      value.fold((l) => null, (r) {
        _moviesFetcher.sink.add(r);
      });
    });
  }

  Future<List<Photo>> getPhotos() async {
    return await repository.fetchPhotos().then((value) {
      return value.fold((l) => [], (r) => r);
    });
  }

  Future<void> onSignIn(String email, String password) async {
    fetchPhotos(() async {
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        isFetching.value = false;

        if (userCredential.user == null) {
          Get.showSnackbar(
            const GetSnackBar(
              title: 'Đăng nhập thất bại',
              message: 'Kiểm tra lại thông tin đăng nhập',
            ),
          ).show();
        }
      } catch (e) {
        isFetching.value = false;
        Get.showSnackbar(
          GetSnackBar(
            title: 'Đăng nhập thất bại',
            message: e.toString(),
          ),
        ).show();
      }
    });
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  var photos = <Photo>[].obs;

  Future<List<Photo>> fetchPhotos(Function fetchDone) async {
    ReceivePort port = ReceivePort();

    try {
      final isolate = await Isolate.spawn(parsePhotosReUsing, port.sendPort);

      port.listen((message) {
        if (message[1] is SendPort) {
          if (message[0] is List<dynamic>) {
            message[1].send(message[0]);
          }
        }
        if (message is List<Map<String, dynamic>>) {
          final listPhoto = message.map((e) => Photo.fromJson(e)).toList();
          photos.addAll(listPhoto);
          fetchDone.call();
          isolate.kill(priority: Isolate.immediate);
        }
      });
    } catch (e) {
      port.close();
    }
    return photos;
  }

  static void parsePhotosReUsing(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    final response = await Dio().getUri<List<dynamic>>(
      Uri.parse('https://jsonplaceholder.typicode.com/photos'),
    );

    receivePort.listen((message) {
      if (message is List<dynamic>) {
        var response = message
            .map((dynamic i) => Photo.fromJson(i as Map<String, dynamic>))
            .toList();
        final photos = response.map((photo) {
          return photo.toJson();
        }).toList();

        sendPort.send(photos);
      }
    });

    sendPort.send([response.data, receivePort.sendPort]);
  }

  @override
  void dispose() {
    super.dispose();
    _moviesFetcher.close();
  }
}
