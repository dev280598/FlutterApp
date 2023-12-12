import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/data/network/interceptor.dart';
import 'package:flutter_app/data/remote/api_service.dart';
import 'package:flutter_app/data/remote/photo_service.dart';
import 'package:flutter_app/domain/repository/data_repo.dart';
import 'package:flutter_app/models/movie.dart';
import 'package:flutter_app/models/thumb.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: Repository)
class RepositoryImpl extends Repository {
  final MovieApiProvider service;
  final PhotoApiProvider photoService;

  RepositoryImpl({required this.photoService, required this.service});

  @override
  Future<Either<Failure, ItemModel>> fetchAllMovies() async {
    return await service.fetchMovieList().then((value) async {
      if (value.response.statusCode == 200) {
        debugPrint('Movies : ${value.data.toJson()}');
        var data = await compute(
          ItemModel.fromJson,
          jsonDecode(jsonEncode(value.response.data)) as Map<String, dynamic>,
        );
        return Right(data);
      } else {
        return Left(
          Failure(
            value.response.statusCode!,
            value.response.statusMessage ?? 'Failed to load post',
          ),
        );
      }
    });
  }

  @override
  Future<Either<Failure, List<Photo>>> fetchPhotos() async {
    return await photoService.fetchPhotos().then((value) {
      if (value.response.statusCode == 200) {
        return Right(value.data);
      } else {
        return Left(
          Failure(
            value.response.statusCode!,
            value.response.statusMessage ?? 'Failed to load post',
          ),
        );
      }
    });
  }
}
