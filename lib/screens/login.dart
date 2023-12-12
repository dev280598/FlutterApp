// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/blocs/movie_bloc.dart';
import 'package:flutter_app/controller/main_controller.dart';
import 'package:flutter_app/lang/localization_service.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screens/drawing_screen.dart';
import 'package:flutter_app/screens/view/drawing_page.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

abstract class AbsState<T extends StatefulWidget> extends State<T> {
  static final Color route = generateRandomColor();
  abstract double height;

  late MoviesBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read();
  }

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

class MyLogin extends GetView<MainController> {
  MyLogin({super.key});

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  static Map<String, String> listLangApp = LocalizationService.langs;



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        debugPrint('=====GetX snapshot');
         controller.contentView.value = login(context);
        if (snapshot.hasData) {
          if(!controller.isLogged.value) {
            authenticate();
          }
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              snapshot.hasData && snapshot.data?.email == _emailCtrl.text
                  ? 'popular_movie'.tr
                  : '',
            ),
            centerTitle: true,
            actions: [
              if (snapshot.hasData)
                TextButton(
                  onPressed: () => controller.signOut(),
                  child: Text(
                    'Logout',
                    style: Get.textTheme.labelMedium
                        ?.apply(color: Get.theme.colorScheme.error),
                  ),
                ),
            ],
          ),
          body: GetX<MainController>(
            builder: (ctrl) {
              debugPrint('=====GetX rebuild');

              return ctrl.contentView.value;
            },
          ),
          floatingActionButton: (snapshot.hasData)
              ? FloatingActionButton(
                  child: const Icon(Icons.chat),
                  onPressed: () {
                    Navigator.pushNamed(context, '/chat');
                  },
                )
              : null,
        );
      },
    );
  }

  void authenticate() async {
    // final url = 'http://localtest.me:43823/';
    // Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
    var verifier = '${const Uuid().v4()}a673b49ba7f7b04a';
    // var verifier = "c775e7b757ede630cd0aa1113bd102661ab38829ca52a6422ab782862f268646";

    List<int> bytesVerifier = utf8.encode(verifier);
    // var sha256_verifier = sha256.convert(bytes_verifier);
    Digest digest = sha256.convert(bytesVerifier);
    // String code_challenge = "51FaJvQFsiNdiFWIq2EMWUKeAqD47dqU_cHzJpfHl-Q";
    String codeChallenge = base64Url.encode(digest.bytes).replaceAll('=', '');
    debugPrint(base64Url.encode(digest.bytes));
    final url =
        'http://127.0.0.1:43823/connect/authorize?client_id=mobile_spa&response_type=code&scope=openid api.read&redirect_uri=foobarmobile://success?code=1337&code_challenge=$codeChallenge&code_challenge_method=S256';

    const callbackUrlScheme = 'foobarmobile';

    try {
      final result = await FlutterWebAuth.authenticate(url: url, callbackUrlScheme: callbackUrlScheme);
      final code = Uri.parse(result).queryParameters['code'];
      const urlGetAccessToken = 'http://127.0.0.1:43823/connect/token';


      controller.isLogged.value = true;
      controller.contentView = mainWidget().obs;

      var map = <String, dynamic>{};
      map['grant_type'] = 'authorization_code';
      map['client_id'] = 'mobile_spa';
      map['code'] = code;
      map['code_verifier'] = verifier;
      map['redirect_uri'] = 'foobarmobile://?success?code=1337';
      debugPrint(url);
      debugPrint(code);
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      rethrow;
    }

    //
    // var resultToken = await http.post(
    //   Uri.http(urlGetAccessToken),
    //   // body: json.encode(map),
    //   body: map,
    //   headers: {'content-type': 'application/x-www-form-urlencoded'},
    // );
    //
    // debugPrint('hahahahahhahha ====> $resultToken');

  }

  Widget mainWidget() {
    return const DrawingScreen();
  }

  Widget login(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'str_title_login'.tr,
            style: Get.textTheme.displayLarge,
          ),
          TextFormField(
            controller: _emailCtrl,
            decoration: InputDecoration(
              hintText: 'user_name'.tr,
              hintStyle: Get.textTheme.bodyMedium
                  ?.apply(color: Get.theme.colorScheme.outline),
            ),
          ),
          TextFormField(
            controller: _passCtrl,
            decoration: InputDecoration(
              hintText: 'pass_word'.tr,
              hintStyle: Get.textTheme.bodyMedium
                  ?.apply(color: Get.theme.colorScheme.outline),
            ),
            obscureText: true,
          ),
          const SizedBox(
            height: 24,
          ),
          ElevatedButton(
            onPressed: () async {
              controller.increment();
              controller.isFetching.value = true;
              await controller.onSignIn(_emailCtrl.text, _passCtrl.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColorDark,
            ),
            child: GetX<MainController>(
              builder: (ctrl) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ctrl.isFetching.value == true)
                      Container(
                        height: 20,
                        width: 20,
                        margin: const EdgeInsets.only(right: 6),
                        child: CircularProgressIndicator(
                          color: Get.theme.colorScheme.onPrimary,
                          strokeWidth: 2,
                        ),
                      ),
                    Text(
                      'str_btn_login'.tr,
                      style: Get.textTheme.labelMedium
                          ?.apply(color: Get.theme.colorScheme.background),
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/signup');
                },
                child: Text(
                  'str_btn_sign_up'.tr,
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(width: 50),
              TextButton(
                onPressed: () {
                  Get.bottomSheet(
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: listLangApp.values.toList().map((e) {
                        return ListTile(
                          title: Text(e.toString()),
                          onTap: () {
                            controller.currentLang.value =
                                listLangApp.values.elementAt(
                              listLangApp.values.toList().indexOf(e),
                            );
                            var key = listLangApp.keys.firstWhere(
                              (k) =>
                                  listLangApp[k] ==
                                  controller.currentLang.value,
                              orElse: () => '',
                            );
                            LocalizationService.changeLocale(key);

                            Get.back();
                          },
                        );
                      }).toList(),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 4,
                    ignoreSafeArea: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                  );
                },
                child: GetX<MainController>(
                  builder: (ctrl) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ctrl.currentLang.value,
                          style: const TextStyle(color: Colors.blue),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color generateRandomColor() {
  // biến random sẽ giúp ta tạo ra 1 số ngẫu nhiên
  final Random random = Random();

  // Màu sắc được tạo nên từ RGB, là một số ngẫu nhiên từ 0 -> 255 và opacity = 1
  return Color.fromRGBO(
    random.nextInt(255),
    random.nextInt(255),
    random.nextInt(255),
    1,
  );
}
