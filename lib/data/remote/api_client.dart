
import 'package:dio/dio.dart';
import 'package:flutter_app/common/app.dart';
import 'package:flutter_app/data/network/interceptor.dart';
import 'package:injectable/injectable.dart';

@injectable
 class ApiClient  {
  Dio getCoreClient() {
    return DioFactory().getDio();
  }

  Dio getTestClient() {
    return DioFactory().getDio(isCore: false);
  }
}