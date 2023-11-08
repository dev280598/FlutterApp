import 'package:dartz/dartz.dart';

import '../../data/network/interceptor.dart';
import '../../models/movie.dart';

abstract class Repository {
  Future<Either<Failure, ItemModel>> fetchAllMovies();
}
