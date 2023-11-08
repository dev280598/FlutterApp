


import 'package:flutter_app/di/injection.config.dart';
import 'package:injectable/injectable.dart';

import '../common/app.dart';

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => appInject.init();