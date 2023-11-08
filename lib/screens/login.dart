// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/common/app.dart';
import 'package:flutter_app/models/thumb.dart';

abstract class AbsState<T extends StatefulWidget> extends State<T> {

  static final Color route = generateRandomColor();
  abstract double height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            contentView(context),
          ],
        ),
      ),
    );
  }

  Widget contentView(BuildContext context) {
    return Container(
      height: height,
      color: Colors.red,
    );
  }
}

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() {
    return _MyLoginState();
  }
}

class _MyLoginState extends AbsState<MyLogin> {
  List<Photo> photos = [];

  @override
  Widget contentView(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(80.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Username',
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
              onPressed: () async {
                fetchPhotos(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
              ),
              child: const Text('ENTER'),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Photo>> fetchPhotos(BuildContext context) async {
    ReceivePort port = ReceivePort();

    try {
      final response = await dio
          .get<List<dynamic>>('https://jsonplaceholder.typicode.com/photos');

      final isolate = await Isolate.spawn(parsePhotosReUsing, port.sendPort);

      isolate.kill(priority: Isolate.immediate);

      port.listen((message) {
        if (message is SendPort) {
          message.send(jsonEncode(response.data));
        }
        if (message is List<dynamic>) {
          photos.addAll(message as List<Photo>);
          Navigator.of(context).pushNamed(
            "/myCatalog",
            arguments: photos.sublist(0, 50),
          );
        }
      });
    } catch (e) {
      port.close();
      debugPrint("Isolate Failed $e");
    }
    return photos;
  }

  static void parsePhotosReUsing(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    receivePort.listen((message) {
      print("===== listen main Isolate: $message");
      final parsed = jsonDecode(message).cast<Map<String, dynamic>>();
      sendPort.send(parsed.map<Photo>((json) => Photo.fromJson(json)).toList());
    });
  }

  @override
  double height = 100;
}

Color generateRandomColor() {
  // biến random sẽ giúp ta tạo ra 1 số ngẫu nhiên
  final Random random = Random();
  print("generateRandomColor");

  // Màu sắc được tạo nên từ RGB, là một số ngẫu nhiên từ 0 -> 255 và opacity = 1
  return Color.fromRGBO(
      random.nextInt(255), random.nextInt(255), random.nextInt(255), 1);
}
