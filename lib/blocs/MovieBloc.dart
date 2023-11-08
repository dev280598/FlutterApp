import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../domain/repository/data_repo.dart';
import '../models/movie.dart';

@injectable
class MoviesBloc  {
  final Repository repository;

  MoviesBloc({required this.repository});

  final _moviesFetcher = PublishSubject<ItemModel>();

  Stream<ItemModel> get allMovies => _moviesFetcher.stream;

  fetchAllMovies() async {

    await repository.fetchAllMovies().then((value) {
      value.fold((l) => null, (r) {
        _moviesFetcher.sink.add(r);
      });
    });
  }

  dispose() {
    _moviesFetcher.close();
  }
}
