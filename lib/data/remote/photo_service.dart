import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_app/common/app.dart';
import 'package:flutter_app/models/thumb.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import 'api_client.dart';

part 'photo_service.g.dart';

@RestApi()
@injectable
abstract class PhotoApiProvider {
  factory PhotoApiProvider(Dio dio) = _PhotoApiProvider;

  @factoryMethod
  factory PhotoApiProvider.create() {
    return PhotoApiProvider(appInject.get<ApiClient>().getTestClient());
  }

  @GET('/photos')
  Future<HttpResponse<List<Photo>>> fetchPhotos();
}
