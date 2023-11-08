
import 'package:flutter/material.dart';

abstract class RouteModule {
  Route<dynamic>? onGenRoute(RouteSettings? settings);
}