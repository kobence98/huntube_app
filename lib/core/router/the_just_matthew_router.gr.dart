// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:flutter/material.dart' as _i5;
import 'package:huntube_app/domain/models/part_collection.dart' as _i6;
import 'package:huntube_app/domain/models/part_files.dart' as _i7;
import 'package:huntube_app/presentation/features/collection_parts/collection_parts_screen.dart'
    as _i1;
import 'package:huntube_app/presentation/features/home/home_screen.dart' as _i2;
import 'package:huntube_app/presentation/features/one_part_list/one_part_list_screen.dart'
    as _i3;

abstract class $TheJustMatthewRouter extends _i4.RootStackRouter {
  $TheJustMatthewRouter({super.navigatorKey});

  @override
  final Map<String, _i4.PageFactory> pagesMap = {
    CollectionPartsRoute.name: (routeData) {
      final args = routeData.argsAs<CollectionPartsRouteArgs>();
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i1.CollectionPartsScreen(
          key: args.key,
          collection: args.collection,
          parts: args.parts,
          easterEggActivated: args.easterEggActivated,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.HomeScreen(),
      );
    },
    OnePartListRoute.name: (routeData) {
      final args = routeData.argsAs<OnePartListRouteArgs>();
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i3.OnePartListScreen(
          key: args.key,
          partFiles: args.partFiles,
          easterEggActivated: args.easterEggActivated,
        ),
      );
    },
  };
}

/// generated route for
/// [_i1.CollectionPartsScreen]
class CollectionPartsRoute extends _i4.PageRouteInfo<CollectionPartsRouteArgs> {
  CollectionPartsRoute({
    _i5.Key? key,
    required _i6.PartCollection collection,
    required List<_i7.PartFiles> parts,
    required bool easterEggActivated,
    List<_i4.PageRouteInfo>? children,
  }) : super(
          CollectionPartsRoute.name,
          args: CollectionPartsRouteArgs(
            key: key,
            collection: collection,
            parts: parts,
            easterEggActivated: easterEggActivated,
          ),
          initialChildren: children,
        );

  static const String name = 'CollectionPartsRoute';

  static const _i4.PageInfo<CollectionPartsRouteArgs> page =
      _i4.PageInfo<CollectionPartsRouteArgs>(name);
}

class CollectionPartsRouteArgs {
  const CollectionPartsRouteArgs({
    this.key,
    required this.collection,
    required this.parts,
    required this.easterEggActivated,
  });

  final _i5.Key? key;

  final _i6.PartCollection collection;

  final List<_i7.PartFiles> parts;

  final bool easterEggActivated;

  @override
  String toString() {
    return 'CollectionPartsRouteArgs{key: $key, collection: $collection, parts: $parts, easterEggActivated: $easterEggActivated}';
  }
}

/// generated route for
/// [_i2.HomeScreen]
class HomeRoute extends _i4.PageRouteInfo<void> {
  const HomeRoute({List<_i4.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i4.PageInfo<void> page = _i4.PageInfo<void>(name);
}

/// generated route for
/// [_i3.OnePartListScreen]
class OnePartListRoute extends _i4.PageRouteInfo<OnePartListRouteArgs> {
  OnePartListRoute({
    _i5.Key? key,
    required _i7.PartFiles partFiles,
    required bool easterEggActivated,
    List<_i4.PageRouteInfo>? children,
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

  static const _i4.PageInfo<OnePartListRouteArgs> page =
      _i4.PageInfo<OnePartListRouteArgs>(name);
}

class OnePartListRouteArgs {
  const OnePartListRouteArgs({
    this.key,
    required this.partFiles,
    required this.easterEggActivated,
  });

  final _i5.Key? key;

  final _i7.PartFiles partFiles;

  final bool easterEggActivated;

  @override
  String toString() {
    return 'OnePartListRouteArgs{key: $key, partFiles: $partFiles, easterEggActivated: $easterEggActivated}';
  }
}
