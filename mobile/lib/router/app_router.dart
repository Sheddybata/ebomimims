import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../bootstrap/app_bootstrap.dart';
import '../providers/auth_provider.dart';
import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/inbox_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/report_resubmit_screen.dart';
import '../screens/report_review_screen.dart';
import '../screens/submit_report_screen.dart';
import '../widgets/inbox_notification_bridge.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final _routerRefresh = _GoRouterRefresh();

final goRouterProvider = Provider<GoRouter>((ref) {
  ref.listen(authProvider, (previous, next) => _routerRefresh.refresh());

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppBootstrap.initialLocation,
    refreshListenable: _routerRefresh,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final user = ref.read(authProvider);
      final loggingIn = loc == '/login';
      if (user == null && !loggingIn && _isProtectedShellRoute(loc)) {
        return '/login';
      }
      if (user != null && loggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'home'),
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'inbox'),
            routes: [
              GoRoute(
                path: '/inbox',
                builder: (context, state) => const InboxScreen(),
                routes: [
                  GoRoute(
                    path: 'review/:reportId',
                    builder: (context, state) => ReportReviewScreen(
                      reportId: state.pathParameters['reportId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'resubmit/:reportId',
                    builder: (context, state) => ReportResubmitScreen(
                      reportId: state.pathParameters['reportId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'submit'),
            routes: [
              GoRoute(
                path: '/submit',
                builder: (context, state) => const SubmitReportScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'history'),
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'profile'),
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _GoRouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

bool _isProtectedShellRoute(String loc) {
  return loc == '/home' ||
      loc == '/inbox' ||
      loc == '/submit' ||
      loc == '/history' ||
      loc == '/profile';
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return InboxNotificationBridge(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: navigationShell.goBranch,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.inbox_outlined),
              selectedIcon: Icon(Icons.inbox),
              label: 'Inbox',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Submit',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
