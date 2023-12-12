import 'package:dartz/dartz.dart';
import 'package:flutter_app/models/thumb.dart';

import '../../data/network/interceptor.dart';
import '../../models/movie.dart';

typedef Predicate<T> = bool Function(T value);
abstract class Repository {
  Future<Either<Failure, ItemModel>> fetchAllMovies();

  Future<Either<Failure, List<Photo>>> fetchPhotos();

}
