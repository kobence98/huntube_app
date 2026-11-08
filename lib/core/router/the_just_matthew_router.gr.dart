// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i6;
import 'package:huntube_app/domain/models/part_collection.dart' as _i7;
import 'package:huntube_app/domain/models/part_files.dart' as _i8;
import 'package:huntube_app/presentation/features/collection_parts/collection_parts_screen.dart'
    as _i1;
import 'package:huntube_app/presentation/features/favourites/favourites_screen.dart'
    as _i2;
import 'package:huntube_app/presentation/features/home/home_screen.dart' as _i3;
import 'package:huntube_app/presentation/features/one_part_list/one_part_list_screen.dart'
    as _i4;

abstract class $TheJustMatthewRouter extends _i5.RootStackRouter {
  $TheJustMatthewRouter({super.navigatorKey});

  @override
  final Map<String, _i5.PageFactory> pagesMap = {
    CollectionPartsRoute.name: (routeData) {
      final args = routeData.argsAs<CollectionPartsRouteArgs>();
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i1.CollectionPartsScreen(
          key: args.key,
          collection: args.collection,
          parts: args.parts,
          easterEggActivated: args.easterEggActivated,
        ),
      );
    },
    FavouritesRoute.name: (routeData) {
      final args = routeData.argsAs<FavouritesRouteArgs>(
          orElse: () => const FavouritesRouteArgs());
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.FavouritesScreen(
          key: args.key,
          easterEggActivated: args.easterEggActivated,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.HomeScreen(),
      );
    },
    OnePartListRoute.name: (routeData) {
      final args = routeData.argsAs<OnePartListRouteArgs>();
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i4.OnePartListScreen(
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
class CollectionPartsRoute extends _i5.PageRouteInfo<CollectionPartsRouteArgs> {
  CollectionPartsRoute({
    _i6.Key? key,
    required _i7.PartCollection collection,
    required List<_i8.PartFiles> parts,
    required bool easterEggActivated,
    List<_i5.PageRouteInfo>? children,
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

  static const _i5.PageInfo<CollectionPartsRouteArgs> page =
      _i5.PageInfo<CollectionPartsRouteArgs>(name);
}

class CollectionPartsRouteArgs {
  const CollectionPartsRouteArgs({
    this.key,
    required this.collection,
    required this.parts,
    required this.easterEggActivated,
  });

  final _i6.Key? key;

  final _i7.PartCollection collection;

  final List<_i8.PartFiles> parts;

  final bool easterEggActivated;

  @override
  String toString() {
    return 'CollectionPartsRouteArgs{key: $key, collection: $collection, parts: $parts, easterEggActivated: $easterEggActivated}';
  }
}

/// generated route for
/// [_i2.FavouritesScreen]
class FavouritesRoute extends _i5.PageRouteInfo<FavouritesRouteArgs> {
  FavouritesRoute({
    _i6.Key? key,
    bool easterEggActivated = false,
    List<_i5.PageRouteInfo>? children,
  }) : super(
          FavouritesRoute.name,
          args: FavouritesRouteArgs(
            key: key,
            easterEggActivated: easterEggActivated,
          ),
          initialChildren: children,
        );

  static const String name = 'FavouritesRoute';

  static const _i5.PageInfo<FavouritesRouteArgs> page =
      _i5.PageInfo<FavouritesRouteArgs>(name);
}

class FavouritesRouteArgs {
  const FavouritesRouteArgs({
    this.key,
    this.easterEggActivated = false,
  });

  final _i6.Key? key;

  final bool easterEggActivated;

  @override
  String toString() {
    return 'FavouritesRouteArgs{key: $key, easterEggActivated: $easterEggActivated}';
  }
}

/// generated route for
/// [_i3.HomeScreen]
class HomeRoute extends _i5.PageRouteInfo<void> {
  const HomeRoute({List<_i5.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i5.PageInfo<void> page = _i5.PageInfo<void>(name);
}

/// generated route for
/// [_i4.OnePartListScreen]
class OnePartListRoute extends _i5.PageRouteInfo<OnePartListRouteArgs> {
  OnePartListRoute({
    _i6.Key? key,
    required _i8.PartFiles partFiles,
    required bool easterEggActivated,
    List<_i5.PageRouteInfo>? children,
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

  static const _i5.PageInfo<OnePartListRouteArgs> page =
      _i5.PageInfo<OnePartListRouteArgs>(name);
}

class OnePartListRouteArgs {
  const OnePartListRouteArgs({
    this.key,
    required this.partFiles,
    required this.easterEggActivated,
  });

  final _i6.Key? key;

  final _i8.PartFiles partFiles;

  final bool easterEggActivated;

  @override
  String toString() {
    return 'OnePartListRouteArgs{key: $key, partFiles: $partFiles, easterEggActivated: $easterEggActivated}';
  }
}
