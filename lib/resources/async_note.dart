

import 'dart:io';

import 'package:flutter/material.dart';

Iterable<int> onTest(int n) sync* {
  var k = 1;
  while (k <= n) {
    yield k++;
  }
}

Stream<int> onTestAsync(int n) async* {
  var k = 1;
  while (k <= n) {
    yield k++;
  }
}

Future<int> sumOfStream(Stream<int> values) async {
  var total = 0;
  await for (final v in values) {
    total += v;
  }
  return total;
}

void run() {
  /// hàm đồng bộ
  onTest(3).forEach((element) {
    sleep(const Duration(milliseconds: 1000));
    debugPrint('$element');
  });

  /// hàm bất đồng bộ
  onTestAsync(3).forEach((element) {
    sleep(const Duration(milliseconds: 1000));
    debugPrint('$element');
  });

  sumOfStream(onTestAsync(3)).then((element) => debugPrint('$element'));
}