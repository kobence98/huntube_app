import 'package:huntube_app/core/router/the_just_matthew_router.gr.dart';
import 'package:auto_route/auto_route.dart';

@AutoRouterConfig()
class TheJustMatthewRouter extends $TheJustMatthewRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: OnePartListRoute.page),
      ];
}
