// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../blocs/movie_bloc.dart' as _i8;
import '../data/remote/api_client.dart' as _i3;
import '../data/remote/api_service.dart' as _i4;
import '../data/remote/photo_service.dart' as _i5;
import '../data/repository/data_repo_impl.dart' as _i7;
import '../domain/repository/data_repo.dart' as _i6;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i3.ApiClient>(() => _i3.ApiClient());
    gh.factory<_i4.MovieApiProvider>(() => _i4.MovieApiProvider.create());
    gh.factory<_i5.PhotoApiProvider>(() => _i5.PhotoApiProvider.create());
    gh.factory<_i6.Repository>(() => _i7.RepositoryImpl(
          photoService: gh<_i5.PhotoApiProvider>(),
          service: gh<_i4.MovieApiProvider>(),
        ));
    gh.factory<_i8.MoviesBloc>(
        () => _i8.MoviesBloc(repository: gh<_i6.Repository>()));
    return this;
  }
}
