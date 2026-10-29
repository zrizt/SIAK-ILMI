import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/presentation/pin_auth_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';

/// App router: checks [authRoleProvider] and renders either
/// [PinAuthScreen] or [DashboardScreen] accordingly.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authRoleProvider);
    return role == null ? const PinAuthScreen() : const DashboardScreen();
  }
}

/// Simple [RouterConfig] that always renders [AppShell].
/// Navigation between features uses imperative [Navigator.push].
/// This will be replaced with go_router in a future phase.
final appRouter = RouterConfig<Object>(
  routerDelegate: _AppRouterDelegate(),
  routeInformationParser: _AppRouteParser(),
  backButtonDispatcher: RootBackButtonDispatcher(),
);

class _AppRouteParser extends RouteInformationParser<Object> {
  @override
  Future<Object> parseRouteInformation(RouteInformation info) async =>
      info.uri;
  @override
  RouteInformation? restoreRouteInformation(Object c) =>
      RouteInformation(uri: c as Uri);
}

class _AppRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: const [MaterialPage(child: AppShell())],
      onDidRemovePage: (page) {},
    );
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}
