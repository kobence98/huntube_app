// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i3;
import 'package:flutter/material.dart' as _i4;
import 'package:huntube_app/domain/models/part_files.dart' as _i5;
import 'package:huntube_app/presentation/features/home/home_screen.dart' as _i1;
import 'package:huntube_app/presentation/features/one_part_list/one_part_list_screen.dart'
    as _i2;

abstract class $TheJustMatthewRouter extends _i3.RootStackRouter {
  $TheJustMatthewRouter({super.navigatorKey});

  @override
  final Map<String, _i3.PageFactory> pagesMap = {
    HomeRoute.name: (routeData) {
      return _i3.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.HomeScreen(),
      );
    },
    OnePartListRoute.name: (routeData) {
      final args = routeData.argsAs<OnePartListRouteArgs>();
      return _i3.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.OnePartListScreen(
          key: args.key,
          partFiles: args.partFiles,
          easterEggActivated: args.easterEggActivated,
        ),
      );
    },
  };
}

/// generated route for
/// [_i1.HomeScreen]
class HomeRoute extends _i3.PageRouteInfo<void> {
  const HomeRoute({List<_i3.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i3.PageInfo<void> page = _i3.PageInfo<void>(name);
}

/// generated route for
/// [_i2.OnePartListScreen]
class OnePartListRoute extends _i3.PageRouteInfo<OnePartListRouteArgs> {
  OnePartListRoute({
    _i4.Key? key,
    required _i5.PartFiles partFiles,
    required bool easterEggActivated,
    List<_i3.PageRouteInfo>? children,
  }) : super(
          OnePartListRoute.name,
          args: OnePartListRouteArgs(
            key: key,
            partFiles: partFiles,
            easterEggActivated: easterEggActivated,
          ),
          initialChildren: children,
        );

  static const String name = 'OnePartListRoute';

  static const _i3.PageInfo<OnePartListRouteArgs> page =
      _i3.PageInfo<OnePartListRouteArgs>(name);
}

class OnePartListRouteArgs {
  const OnePartListRouteArgs({
    this.key,
    required this.partFiles,
    required this.easterEggActivated,
  });

  final _i4.Key? key;

  final _i5.PartFiles partFiles;

  final bool easterEggActivated;

  @override
  String toString() {
    return 'OnePartListRouteArgs{key: $key, partFiles: $partFiles, easterEggActivated: $easterEggActivated}';
  }
}
