import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import 'package:flutter_app/common/app.dart';
import 'package:flutter_app/models/movie.dart';
import 'package:flutter_app/data/remote/api_client.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: 'http://api.themoviedb.org/3/movie/popular?api_key=')
@injectable
abstract class MovieApiProvider {
  factory MovieApiProvider(Dio dio) = _MovieApiProvider;

  @factoryMethod
  factory MovieApiProvider.create() {
    return MovieApiProvider(appInject.get<ApiClient>().getCoreClient());
  }

  @GET(apiKey)
  Future<HttpResponse<ItemModel>> fetchMovieList();

}
